import utils::*;
import rv32_utils::*;
import pito_pkg::*;

module accel_tester ();
//==================================================================================================
// Global Variables
    localparam CLOCK_SPEED          = 50; // 10MHZ
    Logger logger;
    rv32_utils::RV32IDecoder rv32i_dec;
    rv32_utils::RV32IPredictor rv32i_pred;
    string program_hex_file = "test.hex";
    string sim_log_file     = "accel_tester.log";
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
    logic [pito_pkg::HART_CNT_WIDTH-1:0] mvu_irq;
    accelerator accelerator(
                    .io_clk         (clk            ),
                    .io_rst_n       (rst_n          ),
                    .io_imem_addr   (imem_addr      ),
                    .io_imem_data   (imem_data      ),
                    .io_dmem_addr   (dmem_addr      ),
                    .io_dmem_data   (dmem_data      ),
                    .io_imem_w_en   (imem_w_en      ),
                    .io_dmem_w_en   (dmem_w_en      ),
                    .io_pito_program(pito_program   )
                );

    task write_to_dram(rv32_data_q instr_q);
        for (int i=0; i<instr_q.size(); i++) begin
            accelerator.pito_rv32_core.d_mem.bram_32Kb_inst.inst.native_mem_module.blk_mem_gen_v8_4_3_inst.memory[i] = instr_q[i];
        end
    endtask

    task write_instr_to_ram(rv32_data_q instr_q, int backdoor, int log_to_console);
        if(log_to_console) begin
            logger.print_banner($sformatf("Writing %6d instructions to the RAM", instr_q.size()));
            logger.print($sformatf(" ADDR  INSTRUCTION          INSTR TYPE       OPCODE          DECODING"));
        end
        if (backdoor == 1) begin
            for (int addr=0 ; addr<instr_q.size(); addr++) begin
                accelerator.pito_rv32_core.i_mem.bram_32Kb_inst.inst.native_mem_module.blk_mem_gen_v8_4_3_inst.memory[addr] = instr_q[addr];
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
            0: return accelerator.pito_rv32_core.regfile.genblk1[0].regfile.data[reg_num];
            1: return accelerator.pito_rv32_core.regfile.genblk1[1].regfile.data[reg_num];
            2: return accelerator.pito_rv32_core.regfile.genblk1[2].regfile.data[reg_num];
            3: return accelerator.pito_rv32_core.regfile.genblk1[3].regfile.data[reg_num];
            4: return accelerator.pito_rv32_core.regfile.genblk1[4].regfile.data[reg_num];
            5: return accelerator.pito_rv32_core.regfile.genblk1[5].regfile.data[reg_num];
            6: return accelerator.pito_rv32_core.regfile.genblk1[6].regfile.data[reg_num];
            7: return accelerator.pito_rv32_core.regfile.genblk1[7].regfile.data[reg_num];
            default : return 0;
        endcase
    endfunction 

    function rv32_regfile_t read_regs(int hart_id);
        rv32_regfile_t regs;
        for (int i=0; i<`NUM_REGS; i++) begin
            regs[i] = read_hart_reg_val(hart_id, i);
        end
        return regs;
    endfunction

    function rv32_csrfile_t read_csrs(int hart_id);
        rv32_csrfile_t csrs;
        pito_pkg::csr_t csr_addr;
        for (int csr=0; csr<`NUM_CSR; csr++) begin
            csr_addr = pito_pkg::csr_t'(csr);
            case (csr_addr)
                pito_pkg::CSR_MVENDORID      : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.mvendorid;
                pito_pkg::CSR_MARCHID        : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.marchid;
                pito_pkg::CSR_MIMPID         : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.mimpid;
                pito_pkg::CSR_MHARTID        : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.mhartdid;
                pito_pkg::CSR_MSTATUS        : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.mstatus_q;
                pito_pkg::CSR_MISA           : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.misa;
                pito_pkg::CSR_MIE            : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.mie_q;
                pito_pkg::CSR_MTVEC          : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.mtvec_q;
                pito_pkg::CSR_MEPC           : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.mepc_q;
                pito_pkg::CSR_MCAUSE         : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.mcause_q;
                pito_pkg::CSR_MTVAL          : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.mtval_q;
                pito_pkg::CSR_MIP            : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.mip_q;
                pito_pkg::CSR_MCYCLE         : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.mcycle_q[31:0];
                pito_pkg::CSR_MINSTRET       : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.minstret_q[31:0];
                pito_pkg::CSR_MCYCLEH        : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.mcycle_q[63:32];
                pito_pkg::CSR_MINSTRETH      : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.minstret_q[63:32];
                pito_pkg::CSR_MVU_MUL_MODE   : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_mul_mode_q;
                pito_pkg::CSR_MVU_COUNTDOWN  : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_countdown_q;
                pito_pkg::CSR_MVU_WPRECISION : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_wprecision_q;
                pito_pkg::CSR_MVU_IPRECISION : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_iprecision_q;
                pito_pkg::CSR_MVU_OPRECISION : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_oprecision_q;
                pito_pkg::CSR_MVU_WBASEADDR  : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_wbaseaddr_q;
                pito_pkg::CSR_MVU_IBASEADDR  : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_ibaseaddr_q;
                pito_pkg::CSR_MVU_OBASEADDR  : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_obaseaddr_q;
                pito_pkg::CSR_MVU_WSTRIDE_0  : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_wstride_0_q;
                pito_pkg::CSR_MVU_WSTRIDE_1  : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_wstride_1_q;
                pito_pkg::CSR_MVU_WSTRIDE_2  : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_wstride_2_q;
                pito_pkg::CSR_MVU_ISTRIDE_0  : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_istride_0_q;
                pito_pkg::CSR_MVU_ISTRIDE_1  : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_istride_1_q;
                pito_pkg::CSR_MVU_ISTRIDE_2  : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_istride_2_q;
                pito_pkg::CSR_MVU_OSTRIDE_0  : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_ostride_0_q;
                pito_pkg::CSR_MVU_OSTRIDE_1  : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_ostride_1_q;
                pito_pkg::CSR_MVU_OSTRIDE_2  : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_ostride_2_q;
                pito_pkg::CSR_MVU_WLENGTH_0  : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_wlength_0_q;
                pito_pkg::CSR_MVU_WLENGTH_1  : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_wlength_1_q;
                pito_pkg::CSR_MVU_WLENGTH_2  : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_wlength_2_q;
                pito_pkg::CSR_MVU_ILENGTH_0  : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_ilength_0_q;
                pito_pkg::CSR_MVU_ILENGTH_1  : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_ilength_1_q;
                pito_pkg::CSR_MVU_ILENGTH_2  : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_ilength_2_q;
                pito_pkg::CSR_MVU_OLENGTH_0  : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_olength_0_q;
                pito_pkg::CSR_MVU_OLENGTH_1  : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_olength_1_q;
                pito_pkg::CSR_MVU_OLENGTH_2  : csrs[csr] = accelerator.pito_rv32_core.csr.genblk1[0].csrfile.csr_mvu_olength_2_q;
                default : csrs[csr] = 0;
            endcase
        end
        return csrs;
    endfunction 


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
        return accelerator.pito_rv32_core.d_mem.bram_32Kb_inst.inst.native_mem_module.blk_mem_gen_v8_4_3_inst.memory[addr];
    endfunction : read_dmem_word

    function automatic print_imem_region(int addr_from, int addr_to, string radix);
        string mem_val_str="";
        int mem_val;
        addr_from = addr_from - `PITO_DATA_MEM_OFFSET;
        addr_to   = addr_to   - `PITO_DATA_MEM_OFFSET;
        for (int addr=addr_from; addr<=addr_to; addr+=4) begin
            mem_val = accelerator.pito_rv32_core.d_mem.bram_32Kb_inst.inst.native_mem_module.blk_mem_gen_v8_4_3_inst.memory[addr];
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
            logger.print($sformatf("DECODE :  %s", accelerator.pito_rv32_core.rv32_dec_opcode.name ));
            logger.print($sformatf("EXECUTE:  %s", accelerator.pito_rv32_core.rv32_ex_opcode.name  ));
            logger.print($sformatf("WRITEB :  %s", accelerator.pito_rv32_core.rv32_wb_opcode.name  ));
            logger.print($sformatf("WRITEF :  %s", accelerator.pito_rv32_core.rv32_wf_opcode.name  ));
            logger.print($sformatf("CAP    :  %s", accelerator.pito_rv32_core.rv32_cap_opcode.name  ));
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
            logger.print($sformatf("hart id=%1d", accelerator.pito_rv32_core.rv32_hart_wf_cnt));
            if (hart_ids_q[accelerator.pito_rv32_core.rv32_hart_wf_cnt] == 1) begin
                act_instr       = rv32i_dec.decode_instr(accelerator.pito_rv32_core.rv32_wf_instr);
                // logger.print($sformatf("exp=0x%8h: %s        actual=0x%8h: %s", instr_q[0], exp_instr.opcode.name, accelerator.pito_rv32_core.rv32_wf_instr, act_instr.opcode.name));
                logger.print($sformatf("exp=0x%8h: %s        actual=0x%8h: %s", instr_q[0], exp_instr.opcode.name, accelerator.pito_rv32_core.rv32_wf_instr, act_instr.opcode.name));
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

        while(accelerator.pito_rv32_core.is_end == 1'b0) begin
            // logger.print($sformatf("pc=%d       decode:%s", accelerator.pito_rv32_core.rv32_dec_pc, accelerator.pito_rv32_core.rv32_dec_opcode.name));
            // logger.print($sformatf("%s",read_regs()));
            // logger.print($sformatf("hart id=%1d  is_set=%1d", accelerator.pito_rv32_core.rv32_hart_wf_cnt, hart_ids_q[core.rv32_hart_wf_cnt]));
            if (hart_ids_q[accelerator.pito_rv32_core.rv32_hart_wf_cnt] == 1) begin
                // exp_instr      = instr_q.pop_front();
                pc_cnt         = accelerator.pito_rv32_core.rv32_wf_pc[accelerator.pito_rv32_core.rv32_hart_wf_cnt];
                pc_orig_cnt    = accelerator.pito_rv32_core.rv32_org_wf_pc;
                act_instr      = accelerator.pito_rv32_core.rv32_wf_instr;
                rv32_wf_opcode = accelerator.pito_rv32_core.rv32_wf_opcode;
                // logger.print($sformatf("Decoding %h", accelerator.pito_rv32_core.rv32_wf_instr));
                instr          = rv32i_dec.decode_instr(act_instr);
                hart_valid     = 1;
                hart_id        = accelerator.pito_rv32_core.rv32_hart_wf_cnt;
            end
            @(negedge clk);
            // logger.print($sformatf("mvu_start: %d",accelerator.mvu_start));
            if (hart_valid == 1) begin
                // $display($sformatf("instr: %s",rv32_wf_opcode.name));
                rv32i_pred.predict(act_instr, instr, pc_cnt, pc_orig_cnt, read_regs(hart_id), read_csrs(hart_id), read_dmem_word(instr, hart_id), hart_id);
                // $display("\n");
                // @(posedge clk);
                hart_valid = 0;
            end
        end
        logger.print($sformatf("Exception signal was received code name: %s", accelerator.pito_rv32_core.rv32_wf_opcode.name));
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
