import utils::*;
import rv32_utils::*;

module core_tester ();
//==================================================================================================
// Global Variables
    localparam CLOCK_SPEED          = 50; // 10MHZ
    Logger logger;
    rv32_utils::RV32IDecoder rv32i_dec;
    rv32_utils::RV32IPredictor rv32i_pred;
    string program_hex_file = "test.hex";
    string sim_log_file     = "core_tester.log";
//==================================================================================================
// DUT Signals
    logic              clk;
    logic              rst_n;  // Asynchronous reset active low
    rv32_imem_addr_t   imem_addr;
    rv32_instr_t       imem_data;
    rv32_dmem_addr_t   dmem_addr;
    rv32_data_t        dmem_data;
    logic              imem_w_en;
    logic              dmem_w_en;
    logic              pito_program;

    rv32_core core(
                    .rv32_io_clk       (clk            ),
                    .rv32_io_rst_n     (rst_n          ),
                    .rv32_io_imem_addr (imem_addr      ),
                    .rv32_io_imem_data (imem_data      ),
                    .rv32_io_dmem_addr (dmem_addr      ),
                    .rv32_io_dmem_data (dmem_data      ),
                    .rv32_io_imem_w_en (imem_w_en      ),
                    .rv32_io_dmem_w_en (dmem_w_en      ),
                    .rv32_io_program   (pito_program   )
    );

    task write_to_dram(rv32_data_q instr_q);
        for (int i=0; i<instr_q.size(); i++) begin
            core.d_mem.bram_32Kb_inst.inst.native_mem_module.blk_mem_gen_v8_4_3_inst.memory[i] = instr_q[i];
        end
    endtask

    task write_instr_to_ram(rv32_data_q instr_q, int backdoor, int log_to_console);
        if(log_to_console) begin
            logger.print_banner($sformatf("Writing %6d instructions to the RAM", instr_q.size()));
            logger.print($sformatf(" ADDR  INSTRUCTION          INSTR TYPE       OPCODE          DECODING"));
        end
        if (backdoor == 1) begin
            for (int addr=0 ; addr<instr_q.size(); addr++) begin
                core.i_mem.bram_32Kb_inst.inst.native_mem_module.blk_mem_gen_v8_4_3_inst.memory[addr] = instr_q[addr];
                if(log_to_console) begin
                    logger.print($sformatf("[%4d]: 0x%8h     %s", addr, instr_q[addr], get_instr_str(rv32i_dec.decode_instr(instr_q[addr]))));
                end
            end
        end else begin
            @(posedge clk);
            imem_w_en = 1'b1;
            @(posedge clk);
            for (int addr=0; addr<instr_q.size(); addr++) begin
                @(posedge clk);
                imem_data = instr_q[addr];
                imem_addr = addr;
                if(log_to_console) begin
                    logger.print($sformatf("[%4d]: 0x%8h     %s", addr, instr_q[addr], get_instr_str(rv32i_dec.decode_instr(instr_q[addr]))));
                end
            end
            @(posedge clk);
            imem_w_en = 1'b0;
        end
    endtask

    function int read_hart_reg_val (int hart_id, int reg_num);
        case (hart_id)
            0: return core.regfile.genblk1[0].regfile.data[reg_num];
            1: return core.regfile.genblk1[1].regfile.data[reg_num];
            2: return core.regfile.genblk1[2].regfile.data[reg_num];
            3: return core.regfile.genblk1[3].regfile.data[reg_num];
            4: return core.regfile.genblk1[4].regfile.data[reg_num];
            5: return core.regfile.genblk1[5].regfile.data[reg_num];
            6: return core.regfile.genblk1[6].regfile.data[reg_num];
            7: return core.regfile.genblk1[7].regfile.data[reg_num];
            default : return 0;
        endcase
    endfunction 

    function rv32_regfile_t read_regs(int hart_id);
        rv32_regfile_t regs;
        for (int i=0; i<`NUM_REGS; i++) begin
            regs[i] = read_hart_reg_val(hart_id, i);
        end
        return regs;
    endfunction : read_regs

// TODO: A dirty hack for access values within DUT. A better way is to 
// bind or use interface to correctly access the signals. For memory,
// I do not have any idea :(
    function automatic int read_dmem_word(rv32_inst_dec_t instr, int hart_id);
        rv32_opcode_enum_t    opcode    = instr.opcode   ;
        rv32_imm_t            imm       = instr.imm      ;
        rv32_register_field_t rs1       = instr.rs1      ;
        int                   addr;
        // int reg_val = `read_hart_reg(hart_id, rs1);
        int reg_val = read_hart_reg_val(hart_id, rs1);
        case (opcode)
            // RV32_LB     : begin
            //     addr      = (rs1==0) ? (signed'(imm) - `PITO_DATA_MEM_OFFSET) : (core.regfile.data[rs1]+signed'(imm) - `PITO_DATA_MEM_OFFSET);
            // end
            // RV32_LH     : begin
            //     addr      = (rs1==0) ? (signed'(imm) - `PITO_DATA_MEM_OFFSET) : (core.regfile.data[rs1]+signed'(imm) - `PITO_DATA_MEM_OFFSET);
            // end
            // RV32_LW     : begin
            //     addr      = (rs1==0) ? (signed'(imm) - `PITO_DATA_MEM_OFFSET) : (core.regfile.data[rs1]+signed'(imm) - `PITO_DATA_MEM_OFFSET);
            // end
            // RV32_LBU    : begin
            //     addr      = (rs1==0) ? (signed'(imm) - `PITO_DATA_MEM_OFFSET) : (core.regfile.data[rs1]+signed'(imm) - `PITO_DATA_MEM_OFFSET);
            // end
            // RV32_LHU    : begin
            //     addr      = (rs1==0) ? (signed'(imm) - `PITO_DATA_MEM_OFFSET) : (core.regfile.data[rs1]+signed'(imm) - `PITO_DATA_MEM_OFFSET);
            // end
            RV32_SB     : begin
                addr      = (rs1==0) ? (signed'(imm) - `PITO_DATA_MEM_OFFSET) : (reg_val+signed'(imm) - `PITO_DATA_MEM_OFFSET);
            end
            RV32_SH     : begin
                addr      = (rs1==0) ? (signed'(imm) - `PITO_DATA_MEM_OFFSET) : (reg_val+signed'(imm) - `PITO_DATA_MEM_OFFSET);
            end
            RV32_SW     : begin
                addr      = (rs1==0) ? (signed'(imm) - `PITO_DATA_MEM_OFFSET) : (reg_val+signed'(imm) - `PITO_DATA_MEM_OFFSET);
            end
            endcase
        return core.d_mem.bram_32Kb_inst.inst.native_mem_module.blk_mem_gen_v8_4_3_inst.memory[addr];
    endfunction : read_dmem_word

    function automatic print_imem_region(int addr_from, int addr_to, string radix);
        string mem_val_str="";
        int mem_val;
        addr_from = addr_from - `PITO_DATA_MEM_OFFSET;
        addr_to   = addr_to   - `PITO_DATA_MEM_OFFSET;
        for (int addr=addr_from; addr<=addr_to; addr+=4) begin
            mem_val = core.d_mem.bram_32Kb_inst.inst.native_mem_module.blk_mem_gen_v8_4_3_inst.memory[addr];
            if (radix == "int") begin
                logger.print($sformatf("0x%4h: %8h", addr, mem_val));
            end else begin
                mem_val_str = $sformatf("0x%h: %d  %d  %d  %d",addr, mem_val[31:24], mem_val[23:16], mem_val[15:8], mem_val[7:0]);
                logger.print(mem_val_str);
            end
            // logger.print("test");
        end
    endfunction : print_imem_region

    function show_pipeline ();
            logger.print($sformatf("DECODE :  %s", core.rv32_dec_opcode.name ));
            logger.print($sformatf("EXECUTE:  %s", core.rv32_ex_opcode.name  ));
            logger.print($sformatf("WRITEB :  %s", core.rv32_wb_opcode.name  ));
            logger.print($sformatf("WRITEF :  %s", core.rv32_wf_opcode.name  ));
            logger.print($sformatf("CAP    :  %s", core.rv32_cap_opcode.name  ));
            logger.print("\n");
    endfunction 
    // The dut takes 5 clock cycle to process an instruction.
    // Before analysing the output, we first make sure we are 
    // in-sync with the processor. 
    task automatic sync_with_dut(rv32_data_q instr_q, rv32_data_q hart_ids_q);
        bit time_out = 1;
        int NUM_WAIT_CYCELS = 100*`PITO_NUM_HARTS;
        rv32_inst_dec_t exp_instr = rv32i_dec.decode_instr(instr_q[0]);
        rv32_inst_dec_t act_instr; 
        logger.print($sformatf("Attempt to Sync with DUT hart id %1d...", hart_ids_q));
        for (int cycle=0; cycle<NUM_WAIT_CYCELS; cycle++) begin
            logger.print($sformatf("hart id=%1d", core.rv32_hart_wf_cnt));
            if (hart_ids_q[core.rv32_hart_wf_cnt] == 1) begin
                act_instr       = rv32i_dec.decode_instr(core.rv32_wf_instr);
                // logger.print($sformatf("exp=0x%8h: %s        actual=0x%8h: %s", instr_q[0], exp_instr.opcode.name, core.rv32_wf_instr, act_instr.opcode.name));
                logger.print($sformatf("exp=0x%8h: %s        actual=0x%8h: %s", instr_q[0], exp_instr.opcode.name, core.rv32_wf_instr, act_instr.opcode.name));
                // if (core.rv32_wf_opcode == exp_instr.opcode) begin
                if (exp_instr.opcode.name == act_instr.opcode.name) begin
                    time_out = 0;
                    break;
                end
            end
            @(posedge clk);
        end
        if (time_out) begin
            foreach(hart_ids_q[i]) begin
                if (hart_ids_q[i]==1) begin
                    logger.print_banner($sformatf("Failed to sync with DUT hart id %1d after %4d cycles.", i, NUM_WAIT_CYCELS), "ERROR");
                    $finish;
                end
            end
        end else begin
            foreach(hart_ids_q[i]) begin
                if (hart_ids_q[i]==1) begin
                    logger.print($sformatf("Sync with DUT hart id %1d completed...", i));
                end
            end
        end
    endtask

    task automatic monitor_pito(rv32_data_q instr_q, rv32_data_q hart_ids_q);
        rv32_opcode_enum_t rv32_wf_opcode;
        rv32_inst_dec_t instr;
        rv32_instr_t    exp_instr;
        rv32_instr_t    act_instr;
        rv32_pc_cnt_t   pc_cnt, pc_orig_cnt;
        int hart_id;
        int hart_valid = 0;
        logger.print_banner("Starting Monitor Task");
        logger.print("Monitoring the following harts:");
        sync_with_dut(instr_q, hart_ids_q);

        while(core.is_end == 1'b0) begin
            // logger.print($sformatf("pc=%d       decode:%s", core.rv32_dec_pc, core.rv32_dec_opcode.name));
            // logger.print($sformatf("%s",read_regs()));
            // logger.print($sformatf("hart id=%1d  is_set=%1d", core.rv32_hart_wf_cnt, hart_ids_q[core.rv32_hart_wf_cnt]));
            if (hart_ids_q[core.rv32_hart_wf_cnt] == 1) begin
                // exp_instr      = instr_q.pop_front();
                pc_cnt         = core.rv32_wf_pc[core.rv32_hart_wf_cnt];
                pc_orig_cnt    = core.rv32_org_wf_pc;
                act_instr      = core.rv32_wf_instr;
                rv32_wf_opcode = core.rv32_wf_opcode;
                // logger.print($sformatf("Decoding %h", core.rv32_wf_instr));
                instr          = rv32i_dec.decode_instr(act_instr);
                hart_valid     = 1;
                hart_id        = core.rv32_hart_wf_cnt;
            end
            @(negedge clk);
            if (hart_valid == 1) begin
                // $display($sformatf("instr: %s",rv32_wf_opcode.name));
                rv32i_pred.predict(act_instr, instr, pc_cnt, pc_orig_cnt, read_regs(hart_id), read_dmem_word(instr, hart_id), hart_id);
                // $display("\n");
                // @(posedge clk);
                hart_valid = 0;
            end
        end
        logger.print($sformatf("Exception signal was received code name: %s", core.rv32_wf_opcode.name));
    endtask

    // task automatic monitor_regs();
    //     Logger reg_logger = new("reg_logs.log", 1, 0);
    //     @(posedge clk);
    //     while(1) begin
    //         reg_logger.print($sformatf("\n%s\n", reg_file_to_str(read_regs())));
    //         @(posedge clk);
    //     end
    // endtask

    initial begin
        rv32_data_q instr_q;
        rv32_data_q hart_ids_q; // hart id to monitor
        rst_n        = 1'b1;
        dmem_w_en    = 1'b0;
        imem_w_en    = 1'b0;
        imem_addr    = 32'b0;
        dmem_addr    = 32'b0;
        pito_program = 0;

        // Initialize harts in the system
        for (int i=0; i<`PITO_NUM_HARTS; i++) begin
            hart_ids_q.push_back(0);
        end
        // Enables those to monitor:
        hart_ids_q[0] = 1;

        logger = new(sim_log_file);
        instr_q = process_hex_file(program_hex_file, logger, `NUM_INSTR_WORDS); // read hex file and store the first n words to the ram

        rv32i_dec = new(logger);
        rv32i_pred = new(logger, instr_q, `PITO_NUM_HARTS);

        @(posedge clk);
        rst_n     = 1'b0;
        @(posedge clk);
        write_instr_to_ram(instr_q, 1, 0);
        write_to_dram(instr_q);
        @(posedge clk);
        rst_n     = 1'b1;
        @(posedge clk);
        // print_imem_region(0, 511);
        fork
            monitor_pito(instr_q, hart_ids_q);
            // monitor_regs();
        join_any
        rv32i_pred.report_result(1, hart_ids_q);
        // print_imem_region( int'(`PITO_DATA_MEM_OFFSET), int'(`PITO_DATA_MEM_OFFSET+4), "char");
        $finish();
    end

//==================================================================================================
// Simulation specific Threads

    initial begin 
        $timeformat(-9, 2, " ns", 12);
        clk   = 0;
        forever begin
            #((CLOCK_SPEED)*1ns) clk = !clk;
        end
    end

    initial begin
        #1ms;
        $display("Simulation took more than expected ( more than 600ms)");
        $finish();
    end
endmodule
