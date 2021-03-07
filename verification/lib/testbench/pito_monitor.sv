import rv32_utils::*;
import utils::*;
import pito_pkg::*;
import rv32_pkg::*;

class pito_monitor extends BaseObj;

    virtual pito_interface inf;
    rv32_utils::RV32IDecoder rv32i_dec;
    rv32_utils::RV32IPredictor rv32i_pred;
    rv32_pkg::rv32_data_q instr_q;
    int hart_ids_q[$]; // hart id to monitor

    function new (Logger logger, rv32_pkg::rv32_data_q instr_q, virtual pito_interface pito_inf, int hart_ids_q[$], test_stats_t test_stat);
        super.new (logger);   // Calls 'new' method of parent class
        this.inf = pito_inf;
        this.instr_q = instr_q;
        this.rv32i_dec = new(this.logger);
        this.rv32i_pred = new(this.logger, this.instr_q, `PITO_NUM_HARTS, test_stat);
        this.hart_ids_q = hart_ids_q;
    endfunction

    function int read_hart_reg_val (int hart_id, int reg_num);
        case (hart_id)
            0: return `hdl_path_regf_0[reg_num];
            1: return `hdl_path_regf_1[reg_num];
            2: return `hdl_path_regf_2[reg_num];
            3: return `hdl_path_regf_3[reg_num];
            4: return `hdl_path_regf_4[reg_num];
            5: return `hdl_path_regf_5[reg_num];
            6: return `hdl_path_regf_6[reg_num];
            7: return `hdl_path_regf_7[reg_num];
            default : return 0;
        endcase
    endfunction 

    function test_stats_t get_results();
        return this.rv32i_pred.get_results();
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
        if (hart_id != 0) begin
            logger.print($sformatf("Only hart 0 is supported, returning csrs for hart 0"));
        end
        for (int csr=0; csr<`NUM_CSR; csr++) begin
            csr_addr = pito_pkg::csr_t'(csr);
            case (csr_addr)
                pito_pkg::CSR_MVENDORID      : csrs[csr] = `hdl_path_csrf_0.mvendorid;
                pito_pkg::CSR_MARCHID        : csrs[csr] = `hdl_path_csrf_0.marchid;
                pito_pkg::CSR_MIMPID         : csrs[csr] = `hdl_path_csrf_0.mimpid;
                pito_pkg::CSR_MHARTID        : csrs[csr] = `hdl_path_csrf_0.mhartdid;
                pito_pkg::CSR_MSTATUS        : csrs[csr] = `hdl_path_csrf_0.mstatus_q;
                pito_pkg::CSR_MISA           : csrs[csr] = `hdl_path_csrf_0.misa;
                pito_pkg::CSR_MIE            : csrs[csr] = `hdl_path_csrf_0.mie_q;
                pito_pkg::CSR_MTVEC          : csrs[csr] = `hdl_path_csrf_0.mtvec_q;
                pito_pkg::CSR_MEPC           : csrs[csr] = `hdl_path_csrf_0.mepc_q;
                pito_pkg::CSR_MCAUSE         : csrs[csr] = `hdl_path_csrf_0.mcause_q;
                pito_pkg::CSR_MTVAL          : csrs[csr] = `hdl_path_csrf_0.mtval_q;
                pito_pkg::CSR_MIP            : csrs[csr] = `hdl_path_csrf_0.mip_q;
                // pito_pkg::CSR_MCYCLE         : csrs[csr] = `hdl_path_csrf_0.mcycle_q[31:0];
                pito_pkg::CSR_MINSTRET       : csrs[csr] = `hdl_path_csrf_0.minstret_q[31:0];
                // pito_pkg::CSR_MCYCLEH        : csrs[csr] = `hdl_path_csrf_0.mcycle_q[63:32];
                pito_pkg::CSR_MINSTRETH      : csrs[csr] = `hdl_path_csrf_0.minstret_q[63:32];
                pito_pkg::CSR_MVU_WBASEADDR  : csrs[csr] = `hdl_path_csrf_0.csr_mvu_wbaseaddr_q;
                pito_pkg::CSR_MVU_IBASEADDR  : csrs[csr] = `hdl_path_csrf_0.csr_mvu_ibaseaddr_q;
                pito_pkg::CSR_MVU_OBASEADDR  : csrs[csr] = `hdl_path_csrf_0.csr_mvu_obaseaddr_q;
                pito_pkg::CSR_MVU_WSTRIDE_0  : csrs[csr] = `hdl_path_csrf_0.csr_mvu_wstride_0_q;
                pito_pkg::CSR_MVU_WSTRIDE_1  : csrs[csr] = `hdl_path_csrf_0.csr_mvu_wstride_1_q;
                pito_pkg::CSR_MVU_WSTRIDE_2  : csrs[csr] = `hdl_path_csrf_0.csr_mvu_wstride_2_q;
                pito_pkg::CSR_MVU_ISTRIDE_0  : csrs[csr] = `hdl_path_csrf_0.csr_mvu_istride_0_q;
                pito_pkg::CSR_MVU_ISTRIDE_1  : csrs[csr] = `hdl_path_csrf_0.csr_mvu_istride_1_q;
                pito_pkg::CSR_MVU_ISTRIDE_2  : csrs[csr] = `hdl_path_csrf_0.csr_mvu_istride_2_q;
                pito_pkg::CSR_MVU_OSTRIDE_0  : csrs[csr] = `hdl_path_csrf_0.csr_mvu_ostride_0_q;
                pito_pkg::CSR_MVU_OSTRIDE_1  : csrs[csr] = `hdl_path_csrf_0.csr_mvu_ostride_1_q;
                pito_pkg::CSR_MVU_OSTRIDE_2  : csrs[csr] = `hdl_path_csrf_0.csr_mvu_ostride_2_q;
                pito_pkg::CSR_MVU_WLENGTH_0  : csrs[csr] = `hdl_path_csrf_0.csr_mvu_wlength_0_q;
                pito_pkg::CSR_MVU_WLENGTH_1  : csrs[csr] = `hdl_path_csrf_0.csr_mvu_wlength_1_q;
                pito_pkg::CSR_MVU_WLENGTH_2  : csrs[csr] = `hdl_path_csrf_0.csr_mvu_wlength_2_q;
                pito_pkg::CSR_MVU_ILENGTH_0  : csrs[csr] = `hdl_path_csrf_0.csr_mvu_ilength_0_q;
                pito_pkg::CSR_MVU_ILENGTH_1  : csrs[csr] = `hdl_path_csrf_0.csr_mvu_ilength_1_q;
                pito_pkg::CSR_MVU_ILENGTH_2  : csrs[csr] = `hdl_path_csrf_0.csr_mvu_ilength_2_q;
                pito_pkg::CSR_MVU_OLENGTH_0  : csrs[csr] = `hdl_path_csrf_0.csr_mvu_olength_0_q;
                pito_pkg::CSR_MVU_OLENGTH_1  : csrs[csr] = `hdl_path_csrf_0.csr_mvu_olength_1_q;
                pito_pkg::CSR_MVU_OLENGTH_2  : csrs[csr] = `hdl_path_csrf_0.csr_mvu_olength_2_q;
                pito_pkg::CSR_MVU_PRECISION  : csrs[csr] = `hdl_path_csrf_0.csr_mvu_precision_q;
                pito_pkg::CSR_MVU_STATUS     : csrs[csr] = `hdl_path_csrf_0.csr_mvu_status_q;
                pito_pkg::CSR_MVU_COMMAND    : csrs[csr] = `hdl_path_csrf_0.csr_mvu_command_q;
                pito_pkg::CSR_MVU_QUANT      : csrs[csr] = `hdl_path_csrf_0.csr_mvu_quant_q;
                default : csrs[csr] = 0;
            endcase
        end
        return csrs;
    endfunction 


// TODO: A dirty hack for access values within DUT. A better way is to 
// bind or use interface to correctly access the signals. For memory,
// I do not have any idea :(
    function automatic int read_dmem_word(rv32_pkg::rv32_inst_dec_t instr, int hart_id);
        rv32_opcode_enum_t    opcode    = instr.opcode   ;
        rv32_imm_t            imm       = instr.imm      ;
        rv32_register_field_t rs1       = instr.rs1      ;
        int                   addr;
        // int reg_val = `read_hart_reg(hart_id, rs1);
        int reg_val = read_hart_reg_val(hart_id, rs1);
        case (opcode)
            rv32_pkg::RV32_SB     : begin
                addr      = (rs1==0) ? (signed'(imm) - `PITO_DATA_MEM_OFFSET) : (reg_val+signed'(imm) - `PITO_DATA_MEM_OFFSET);
            end
            rv32_pkg::RV32_SH     : begin
                addr      = (rs1==0) ? (signed'(imm) - `PITO_DATA_MEM_OFFSET) : (reg_val+signed'(imm) - `PITO_DATA_MEM_OFFSET);
            end
            rv32_pkg::RV32_SW     : begin
                addr      = (rs1==0) ? (signed'(imm) - `PITO_DATA_MEM_OFFSET) : (reg_val+signed'(imm) - `PITO_DATA_MEM_OFFSET);
            end
            endcase
        return `hdl_path_top.d_mem.bram_32Kb_inst.inst.native_mem_module.blk_mem_gen_v8_4_3_inst.memory[addr];
    endfunction : read_dmem_word

    function automatic print_imem_region(int addr_from, int addr_to, string radix);
        string mem_val_str="";
        int mem_val;
        addr_from = addr_from - `PITO_DATA_MEM_OFFSET;
        addr_to   = addr_to   - `PITO_DATA_MEM_OFFSET;
        for (int addr=addr_from; addr<=addr_to; addr+=4) begin
            mem_val = `hdl_path_top.d_mem.bram_32Kb_inst.inst.native_mem_module.blk_mem_gen_v8_4_3_inst.memory[addr];
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
            logger.print($sformatf("DECODE :  %s", `hdl_path_top.rv32_dec_opcode.name ));
            logger.print($sformatf("EXECUTE:  %s", `hdl_path_top.rv32_ex_opcode.name  ));
            logger.print($sformatf("WRITEB :  %s", `hdl_path_top.rv32_wb_opcode.name  ));
            logger.print($sformatf("WRITEF :  %s", `hdl_path_top.rv32_wf_opcode.name  ));
            logger.print($sformatf("CAP    :  %s", `hdl_path_top.rv32_cap_opcode.name  ));
            logger.print("\n");
    endfunction 

    // The dut takes 5 clock cycle to process an instruction.
    // Before analysing the output, we first make sure we are 
    // in-sync with the processor. 
    task automatic sync_with_dut();
        bit time_out = 1;
        int NUM_WAIT_CYCELS = 100*`PITO_NUM_HARTS;
        rv32_inst_dec_t exp_instr = rv32i_dec.decode_instr(this.instr_q[0]);
        rv32_inst_dec_t act_instr; 
        logger.print($sformatf("Attempt to Sync with DUT hart id %1d...", this.hart_ids_q));
        for (int cycle=0; cycle<NUM_WAIT_CYCELS; cycle++) begin
            logger.print($sformatf("hart id=%1d", `hdl_path_top.rv32_hart_wf_cnt));
            if (this.hart_ids_q[`hdl_path_top.rv32_hart_wf_cnt] == 1) begin
                act_instr       = rv32i_dec.decode_instr(`hdl_path_top.rv32_wf_instr);
                // logger.print($sformatf("exp=0x%8h: %s        actual=0x%8h: %s", this.instr_q[0], exp_instr.opcode.name, `hdl_path_top.rv32_wf_instr, act_instr.opcode.name));
                logger.print($sformatf("exp=0x%8h: %s        actual=0x%8h: %s", this.instr_q[0], exp_instr.opcode.name, `hdl_path_top.rv32_wf_instr, act_instr.opcode.name));
                // if (`hdl_path_top.rv32_wf_opcode == exp_instr.opcode) begin
                if (exp_instr.opcode.name == act_instr.opcode.name) begin
                    time_out = 0;
                    break;
                end
            end
            @(posedge inf.clk);
        end
        if (time_out) begin
            foreach(this.hart_ids_q[i]) begin
                if (this.hart_ids_q[i]==1) begin
                    logger.print_banner($sformatf("Failed to sync with DUT hart id %1d after %4d cycles.", i, NUM_WAIT_CYCELS), "ERROR");
                    $finish;
                end
            end
        end else begin
            foreach(this.hart_ids_q[i]) begin
                if (this.hart_ids_q[i]==1) begin
                    logger.print($sformatf("Sync with DUT hart id %1d completed...", i));
                end
            end
        end
    endtask

    task automatic run();
        rv32_opcode_enum_t rv32_wf_opcode;
        rv32_inst_dec_t instr;
        rv32_instr_t    exp_instr;
        rv32_instr_t    act_instr;
        rv32_pc_cnt_t   pc_cnt, pc_orig_cnt;
        int hart_id;
        int hart_valid = 0;
        logger.print("Starting Monitor Task");
        logger.print("Monitoring the following harts:");

        while(`hdl_path_top.is_end == 1'b0) begin
            // logger.print($sformatf("pc=%d       decode:%s", `hdl_path_top.rv32_dec_pc, `hdl_path_top.rv32_dec_opcode.name));
            // logger.print($sformatf("%s",read_regs()));
            // logger.print($sformatf("hart id=%1d  is_set=%1d", `hdl_path_top.rv32_hart_wf_cnt, hart_ids_q[`hdl_path_top.rv32_hart_wf_cnt]));
            if (hart_ids_q[`hdl_path_top.rv32_hart_wf_cnt] == 1) begin
                // exp_instr      = instr_q.pop_front();
                pc_cnt         = `hdl_path_top.rv32_wf_pc[`hdl_path_top.rv32_hart_wf_cnt];
                pc_orig_cnt    = `hdl_path_top.rv32_org_wf_pc;
                act_instr      = `hdl_path_top.rv32_wf_instr;
                rv32_wf_opcode = `hdl_path_top.rv32_wf_opcode;
                // logger.print($sformatf("Decoding %h", `hdl_path_top.rv32_wf_instr));
                instr          = this.rv32i_dec.decode_instr(act_instr);
                hart_valid     = 1;
                hart_id        = `hdl_path_top.rv32_hart_wf_cnt;
            end
            @(negedge inf.clk);
            if (hart_valid == 1) begin
                // $display($sformatf("instr: %s",rv32_wf_opcode.name));
                rv32i_pred.predict(act_instr, instr, pc_cnt, pc_orig_cnt, read_regs(hart_id), read_csrs(hart_id), read_dmem_word(instr, hart_id), hart_id);
                // $display("\n");
                // @(posedge clk);
                hart_valid = 0;
            end
        end
        logger.print($sformatf("Exception signal was received from HART[%0d] code name: %s", hart_id, `hdl_path_top.rv32_wf_opcode.name));
    endtask

endclass
