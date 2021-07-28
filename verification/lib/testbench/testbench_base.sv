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
    virtual barvinn_interface barvinn_intf;
    virtual pito_interface pito_intf;
    rv32_pkg::rv32_data_q instr_q;
    pito_monitor monitor;
    int hart_ids_q[$]; // hart id to monitor
    rv32_utils::RV32IDecoder rv32i_dec;
    test_stats_t test_stat;
    tb_config cfg;

    function new (Logger logger, virtual barvinn_interface barvinn_intf, virtual pito_interface pito_intf, int hart_mon_en[$]={});
        super.new(logger);
        cfg = new(logger);
        void'(cfg.parse_args());
        this.firmware = cfg.firmware;
        this.barvinn_intf = barvinn_intf;
        this.pito_intf = pito_intf;
        // read hex file and store the first n words to the ram
        instr_q = process_hex_file(firmware, logger, `NUM_INSTR_WORDS); 
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
        monitor = new(this.logger, this.instr_q, this.pito_intf, this.hart_ids_q, this.test_stat);
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
        barvinn_intf.cb.mvu_wrc_addr <= addr;
        barvinn_intf.cb.mvu_wrc_word <= word;
        barvinn_intf.cb.mvu_wrc_en[mvu] <= 1'b1;
        @(posedge barvinn_intf.clk)
        barvinn_intf.cb.mvu_wrc_en[mvu] <= 1'b0;
    endtask

    task write_mvu_weights(int mvu, unsigned[BWBANKW-1 : 0] word, unsigned[BWBANKA-1 : 0] addr);
        checkmvu(mvu);
        $display($sformatf("write_weight_data: writing %16h at %12h", word, addr));
        barvinn_intf.cb.mvu_wrw_addr[mvu*BWBANKA +: BWBANKA] <= addr;
        barvinn_intf.cb.mvu_wrw_word[mvu*BWBANKW +: BWBANKW] <= word;
        barvinn_intf.cb.mvu_wrw_en[mvu] <= 1'b1;
        @(posedge barvinn_intf.clk)
        barvinn_intf.cb.mvu_wrw_en[mvu] <= 1'b0;
    endtask

    task automatic readData(int mvu, logic unsigned [BDBANKA-1 : 0] addr, ref logic unsigned [BDBANKW-1 : 0] word, ref logic unsigned [NMVU-1 : 0] grnt);
        checkmvu(mvu);
        barvinn_intf.cb.mvu_rdc_addr[mvu*BDBANKA +: BDBANKA] <= addr;
        barvinn_intf.cb.mvu_rdc_en[mvu] <= 1;
        @(posedge barvinn_intf.clk)
        grnt[mvu] = barvinn_intf.cb.mvu_rdc_grnt[mvu];
        barvinn_intf.cb.mvu_rdc_en[mvu] <= 0;
        @(posedge barvinn_intf.clk)
        @(posedge barvinn_intf.clk)
        word = barvinn_intf.mvu_rdc_word[mvu*BDBANKW +: BDBANKW];
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

    task write_data_to_ram(rv32_data_q data_q);
        for (int i=0; i<data_q.size(); i++) begin
            `hdl_path_dmem[i] = data_q[i];
        end
    endtask

    task write_instr_to_ram(int backdoor, int log_to_console);
        if(log_to_console) begin
            logger.print_banner($sformatf("Writing %6d instructions to the RAM", this.instr_q.size()));
            logger.print($sformatf(" ADDR  INSTRUCTION          INSTR TYPE       OPCODE          DECODING"));
        end
        if (backdoor == 1) begin
            for (int addr=0 ; addr<this.instr_q.size(); addr++) begin
                `hdl_path_imem[addr] = this.instr_q[addr];
                if(log_to_console) begin
                    logger.print($sformatf("[%4d]: 0x%8h     %s", addr, this.instr_q[addr], rv32_utils::get_instr_str(rv32i_dec.decode_instr(this.instr_q[addr]))));
                end
            end
        end else begin
            @(posedge barvinn_intf.clk);
            barvinn_intf.cb.pito_io_imem_w_en <= 1'b1;
            @(posedge barvinn_intf.clk);
            for (int addr=0; addr<instr_q.size(); addr++) begin
                @(posedge barvinn_intf.clk);
                barvinn_intf.cb.pito_io_imem_data <= instr_q[addr];
                barvinn_intf.cb.pito_io_imem_addr <= addr;
                if(log_to_console) begin
                    logger.print($sformatf("[%4d]: 0x%8h     %s", addr, instr_q[addr], rv32_utils::get_instr_str(rv32i_dec.decode_instr(instr_q[addr]))));
                end
            end
            @(posedge barvinn_intf.clk);
            barvinn_intf.cb.pito_io_imem_w_en <= 1'b0;
        end
    endtask

    task pito_init();
        barvinn_intf.cb.rst_n             <= 1'b1;
        barvinn_intf.cb.pito_io_dmem_w_en <= 1'b0;
        barvinn_intf.cb.pito_io_imem_w_en <= 1'b0;
        barvinn_intf.cb.pito_io_imem_addr <= 32'b0;
        barvinn_intf.cb.pito_io_dmem_addr <= 32'b0;
        barvinn_intf.cb.pito_io_program   <= 0;
        // barvinn_intf.mvu_irq_i         = 0;

        @(posedge barvinn_intf.clk);
        barvinn_intf.cb.rst_n <= 1'b0;
        @(posedge barvinn_intf.clk);

        this.write_instr_to_ram(1, 0);
        this.write_data_to_ram(instr_q);

        @(posedge barvinn_intf.clk);
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
        @(posedge barvinn_intf.clk);
        barvinn_intf.cb.rst_n <= 1'b1;
        // @(posedge barvinn_intf.clk);
    endtask 

    virtual task report();
        test_stats_t test_stat = this.monitor.get_results();
        logger.print_banner("Testbench Report phase");
        print_result(test_stat, VERB_LOW, logger);
    endtask 

endclass
