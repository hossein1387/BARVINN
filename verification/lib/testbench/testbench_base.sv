`include "rv32_defines.svh"
`include "testbench_macros.svh"
`include "testbench_config.sv"
`include "pito_monitor.sv"

import utils::*;
import rv32_pkg::*;
import rv32_utils::*;
import pito_pkg::*;

class barvinn_testbench_base extends BaseObj;

    string firmware;
    virtual pito_interface inf;
    rv32_pkg::rv32_data_q instr_q;
    pito_monitor monitor;
    int hart_ids_q[$]; // hart id to monitor
    rv32_utils::RV32IDecoder rv32i_dec;
    test_stats_t test_stat;
    tb_config cfg;

    function new (Logger logger, virtual pito_interface inf, int hart_mon_en[$]={});
        super.new(logger);
        cfg = new(logger);
        cfg.parse_args();
        this.firmware = cfg.firmware;
        this.inf = inf;

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
        monitor = new(this.logger, this.instr_q, this.inf, this.hart_ids_q, this.test_stat);
        this.rv32i_dec = new(this.logger);
    endfunction

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
            @(posedge inf.clk);
            inf.pito_io_imem_w_en = 1'b1;
            @(posedge inf.clk);
            for (int addr=0; addr<instr_q.size(); addr++) begin
                @(posedge inf.clk);
                inf.pito_io_imem_data = instr_q[addr];
                inf.pito_io_imem_addr = addr;
                if(log_to_console) begin
                    logger.print($sformatf("[%4d]: 0x%8h     %s", addr, instr_q[addr], rv32_utils::get_instr_str(rv32i_dec.decode_instr(instr_q[addr]))));
                end
            end
            @(posedge inf.clk);
            inf.pito_io_imem_w_en = 1'b0;
        end
    endtask

    virtual task tb_setup();
        logger.print_banner("Testbench Setup Phase");
        // Put DUT to reset and relax memory interface
        logger.print("Putting DUT to reset mode");
        inf.pito_io_rst_n     = 1'b1;
        inf.pito_io_dmem_w_en = 1'b0;
        inf.pito_io_imem_w_en = 1'b0;
        inf.pito_io_imem_addr = 32'b0;
        inf.pito_io_dmem_addr = 32'b0;
        inf.pito_io_program   = 0;
        inf.mvu_irq_i         = 0;

        @(posedge inf.clk);
        inf.pito_io_rst_n = 1'b0;
        @(posedge inf.clk);

        this.write_instr_to_ram(1, 0);
        this.write_data_to_ram(instr_q);

        @(posedge inf.clk);
        inf.pito_io_rst_n = 1'b1;
        @(posedge inf.clk);

        logger.print("Setup Phase Done ...");
    endtask

    virtual task run();
        logger.print_banner("Testbench Run phase");
        logger.print("Run method is not implemented");
        logger.print("Run phase done ...");
    endtask 

    virtual task report();
        test_stats_t test_stat = this.monitor.get_results();
        logger.print_banner("Testbench Report phase");
        print_result(test_stat, VERB_LOW, logger);
    endtask 

endclass
