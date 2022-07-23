`include "rv32_defines.svh"
`include "testbench_macros.svh"
`include "testbench_config.sv"
`include "pito_monitor.sv"

import utils::*;
import rv32_pkg::*;
import rv32_utils::*;
import pito_pkg::*;
import mvu_pkg::*;

class barvinn_testbench_base extends BaseObj;

    string firmware;
    string rodata;
    virtual MVU_EXT_INTERFACE mvu_ext_intf;
    virtual pito_soc_ext_interface pito_ext_intf;
    rv32_pkg::rv32_data_q instr_q;
    rv32_pkg::rv32_data_q rodata_q;
    pito_monitor monitor;
    int hart_ids_q[$]; // hart id to monitor
    rv32_utils::RV32IDecoder rv32i_dec;
    test_stats_t test_stat;
    tb_config cfg;
    logic predictor_silent_mode;


    function new (Logger logger, virtual MVU_EXT_INTERFACE mvu_ext_intf, virtual pito_soc_ext_interface pito_ext_intf, int hart_mon_en[$]={}, logic predictor_silent_mode=0, logic rv_reg_tests=0);
    super.new(logger);
        cfg = new(logger);
        void'(cfg.parse_args());
        this.mvu_ext_intf = mvu_ext_intf;
        this.pito_ext_intf = pito_ext_intf;
        this.predictor_silent_mode = predictor_silent_mode;
        // For RISC-V regression tests, we initialize ram at run stage
        if (rv_reg_tests==0) begin
            this.firmware = cfg.firmware;
            this.rodata = cfg.rodata;
            // read hex file and store the first n words to the ram
            instr_q = process_hex_file(firmware, logger, `NUM_INSTR_WORDS); 
            rodata_q = process_hex_file(rodata, logger, `NUM_INSTR_WORDS); 
        end

        // Check if user has requested to monitor any particular hart/s
        if (hart_mon_en.size()==0) begin
            // Initialize harts in the system
            for (int i=0; i<`PITO_NUM_HARTS; i++) begin
                hart_ids_q.push_back(0);
            end
            // Enables those to monitor:
            hart_ids_q[0] = 1;
        end else begin
            this.hart_ids_q = hart_mon_en;
        end
        monitor = new(this.logger, this.instr_q, this.rodata_q, this.pito_ext_intf, this.hart_ids_q, this.test_stat, predictor_silent_mode);
        this.rv32i_dec = new(this.logger);
    endfunction

    task checkmvu(int mvu);
        if (mvu > N) begin
            logger.print($sformatf("MVU specificed %d is greater than number of MVUs %d", mvu, N), "Error");
            $finish();
        end
    endtask

    task write_mvu_data(int mvu, unsigned[BDBANKW-1 : 0] word, unsigned[BDBANKA-1 : 0] addr);
        checkmvu(mvu);
        mvu_ext_intf.wrc_addr = addr;
        mvu_ext_intf.wrc_word = word;
        mvu_ext_intf.wrc_en[mvu] = 1'b1;
        @(posedge mvu_ext_intf.clk)
        mvu_ext_intf.wrc_en[mvu] = 1'b0;
    endtask

    task write_mvu_weights(int mvu, unsigned[BWBANKW-1 : 0] word, unsigned[BWBANKA-1 : 0] addr);
        checkmvu(mvu);
        mvu_ext_intf.wrw_addr[mvu*BWBANKA +: BWBANKA] = addr;
        mvu_ext_intf.wrw_word[mvu*BWBANKW +: BWBANKW] = word;
        mvu_ext_intf.wrw_en[mvu] = 1'b1;
        @(posedge mvu_ext_intf.clk)
        mvu_ext_intf.wrw_en[mvu] = 1'b0;
    endtask

    task automatic readData(int mvu, logic unsigned [BDBANKA-1 : 0] addr, ref logic unsigned [BDBANKW-1 : 0] word, ref logic unsigned [NMVU-1 : 0] grnt);
        checkmvu(mvu);
        mvu_ext_intf.rdc_addr[mvu*BDBANKA +: BDBANKA] = addr;
        mvu_ext_intf.rdc_en[mvu] = 1;
        @(posedge mvu_ext_intf.clk)
        grnt[mvu] = mvu_ext_intf.rdc_grnt[mvu];
        mvu_ext_intf.rdc_en[mvu] = 0;
        @(posedge mvu_ext_intf.clk)
        @(posedge mvu_ext_intf.clk)
        word = mvu_ext_intf.rdc_word[mvu*BDBANKW +: BDBANKW];
    endtask

    function automatic rv32_data_q process_hex_file(string hex_file, Logger logger, int nwords);
        int fd = $fopen (hex_file, "r");
        string instr_str, temp, line;
        rv32_data_q instr_q;
        int word_cnt = 0;
        if (fd)  begin logger.print($sformatf("%s was opened successfully : %0d", hex_file, fd)); end
        else     begin logger.print($sformatf("%s was NOT opened successfully : %0d", hex_file, fd)); $finish(); end
        while (!$feof(fd) && word_cnt<nwords) begin
            temp = $fgets(line, fd);
            if (line.substr(0, 1) != "//") begin
                instr_str = line.substr(0, 7);
                instr_q.push_back(rv32_instr_t'(instr_str.atohex()));
                word_cnt += 1;
            end
        end
        return instr_q;
    endfunction

    task write_data_to_ram(int backdoor, int log_to_console);
        logger.print($sformatf("Writing %6d data words to the Data RAM", this.rodata_q.size()));
        if (backdoor == 1) begin
            for (int addr=0 ; addr<this.rodata_q.size(); addr++) begin
                `hdl_path_dmem_init[addr] = this.rodata_q[addr];
                if(log_to_console) begin
                    logger.print($sformatf("[%4d]: 0x%8h", addr, this.rodata_q[addr]));
                end
            end
        end else begin
            @(posedge pito_ext_intf.clk);
            pito_ext_intf.dmem_we = 1'b1;
            @(posedge pito_ext_intf.clk);
            for (int addr=0; addr<this.rodata_q.size(); addr++) begin
                @(posedge pito_ext_intf.clk);
                pito_ext_intf.dmem_wdata = this.rodata_q[addr];
                pito_ext_intf.dmem_addr = addr;
                if(log_to_console) begin
                    logger.print($sformatf("[%4d]: 0x%8h", addr, this.rodata_q[addr]));
                end
            end
            @(posedge pito_ext_intf.clk);
            pito_ext_intf.dmem_we = 1'b0;
        end
    endtask

    task write_instr_to_ram(int backdoor, int log_to_console);
        logger.print($sformatf("Writing %6d instruction words to the Instruction RAM", this.instr_q.size()));
        if(log_to_console) begin
            logger.print($sformatf(" ADDR  INSTRUCTION          INSTR TYPE       OPCODE          DECODING"));
        end
        if (backdoor == 1) begin
            for (int addr=0 ; addr<this.instr_q.size(); addr++) begin
                `hdl_path_imem_init[addr] = this.instr_q[addr];
                if(log_to_console) begin
                    logger.print($sformatf("[%4d]: 0x%8h     %s", addr, this.instr_q[addr], rv32_utils::get_instr_str(rv32i_dec.decode_instr(this.instr_q[addr]))));
                end
            end
        end else begin
            @(posedge pito_ext_intf.clk);
            pito_ext_intf.imem_we = 1'b1;
            @(posedge pito_ext_intf.clk);
            for (int addr=0; addr<instr_q.size(); addr++) begin
                @(posedge pito_ext_intf.clk);
                pito_ext_intf.imem_wdata = instr_q[addr];
                pito_ext_intf.imem_addr = addr;
                if(log_to_console) begin
                    logger.print($sformatf("[%4d]: 0x%8h     %s", addr, instr_q[addr], rv32_utils::get_instr_str(rv32i_dec.decode_instr(instr_q[addr]))));
                end
            end
            @(posedge pito_ext_intf.clk);
            pito_ext_intf.imem_we = 1'b0;
        end
    endtask


    task pito_init();
        pito_ext_intf.rst_n        = 1'b1;
        pito_ext_intf.dmem_we      = 1'b0;
        pito_ext_intf.dmem_be      = 4'b1111;
        pito_ext_intf.dmem_req     = 1'b0;
        pito_ext_intf.dmem_addr    = {`PITO_DATA_ADDR_WIDTH{1'b0}};
        pito_ext_intf.dmem_wdata   = 32'b0;
        pito_ext_intf.imem_we      = 1'b0;
        pito_ext_intf.imem_be      = 4'b1111;
        pito_ext_intf.imem_req     = 1'b0;
        pito_ext_intf.imem_addr    = {`PITO_INSTR_ADDR_WIDTH{1'b0}};
        pito_ext_intf.imem_wdata   = 32'b0;

        @(posedge pito_ext_intf.clk);
        pito_ext_intf.rst_n = 1'b0;
        @(posedge pito_ext_intf.clk);

        this.write_instr_to_ram(1, 0);
        this.write_data_to_ram(1, 0);

        @(posedge pito_ext_intf.clk);
        pito_ext_intf.rst_n = 1'b1;
        @(posedge pito_ext_intf.clk);
    endtask

    task mvu_init();

    endtask

    virtual task tb_setup();
        logger.print_banner("Testbench Setup Phase");
        // Put DUT to reset and relax memory interface
        logger.print("Initializing MVUs...");
        mvu_init();
        logger.print("Initializing RISC-V cores ...");
        pito_init();
        logger.print("Setup Phase Done ...");
    endtask

    virtual task run();
        logger.print_banner("Testbench Run phase");
        @(posedge pito_ext_intf.clk);
        pito_ext_intf.rst_n <= 1'b1;
        // @(posedge barvinn_intf.clk);
    endtask 

    virtual task report();
        test_stats_t test_stat = this.monitor.get_results();
        logger.print_banner("Testbench Report phase");
        print_result(test_stat, VERB_LOW, logger);
    endtask 

endclass
