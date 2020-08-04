package rv32_utils;
import utils::*;
import rv32_pkg::*;
import pito_pkg::*;
// `include "../../../vsrc/rv32_types.svh"

//==================================================================================================
// RV32IDecoder class used for verification and simulation purposes 
//==================================================================================================

class BaseObj;
    Logger logger;

   function new (Logger logger);
      this.logger = logger;
   endfunction

endclass

class RV32IDecoder extends BaseObj;

    function new (Logger logger);
        super.new (logger);   // Calls 'new' method of parent class
    endfunction

    function rv32_inst_dec_t dec_nop_type (rv32_instr_t instr);
        rv32_inst_dec_t rv32_inst_dec;
        string inst_type = "NOP-Type";
        if ((instr[6:0] == 7'b0010011) && (instr[31:7] == {25{1'b0}})) begin
            //rv32_inst_dec.ins_str = $sformatf("%8s.%7s                              ", inst_type, "nop");
            rv32_inst_dec.opcode = RV32_NOP;
            rv32_inst_dec.inst_type = RV32_TYPE_NOP;
        end else begin
            //rv32_inst_dec.ins_str = "!unknown instruction!";
            rv32_inst_dec.opcode = RV32_UNKNOWN;
            rv32_inst_dec.inst_type = RV32_TYPE_UNKNOWN;
        end
        rv32_inst_dec.imm = `PITO_NULL;
        rv32_inst_dec.csr = `PITO_NULL;
        rv32_inst_dec.rs1 = `PITO_NULL;
        rv32_inst_dec.rs2 = `PITO_NULL;
        rv32_inst_dec.rd  = `PITO_NULL;
        return rv32_inst_dec;
    endfunction


    function rv32_inst_dec_t dec_u_type (rv32_instr_t instr);
        rv32_inst_dec_t rv32_inst_dec;
        string inst_type = "U-Type";
        logic [6:0] opcode = instr[6:0];
        int imm = {{12{instr[31]}}, instr[31:12]};
        rv32_register_field_t rd = instr[11:7]; 
        if          (opcode == 7'b0110111) begin
            //rv32_inst_dec.ins_str = $sformatf("%8s.%7s: rd=%2d                imm=%4d", inst_type, "lui", rd, imm);
            rv32_inst_dec.opcode         = RV32_LUI;
            rv32_inst_dec.rd             = rd;
            rv32_inst_dec.imm            = imm;
            rv32_inst_dec.inst_type    = RV32_TYPE_U;
        end else if (opcode == 7'b0010111) begin
            //rv32_inst_dec.ins_str = $sformatf("%8s.%7s: rd=%2d                imm=%4d", inst_type, "auipc", rd, imm);
            rv32_inst_dec.opcode         = RV32_AUIPC;
            rv32_inst_dec.rd             = rd;
            rv32_inst_dec.imm            = imm;
            rv32_inst_dec.inst_type    = RV32_TYPE_U;
        end else                           begin
            //rv32_inst_dec.ins_str = "!unknown instruction!";
            rv32_inst_dec.opcode = RV32_UNKNOWN;
            rv32_inst_dec.inst_type = RV32_TYPE_UNKNOWN;
        end
        rv32_inst_dec.csr            = `PITO_NULL;
        rv32_inst_dec.rs1            = `PITO_NULL;
        rv32_inst_dec.rs2            = `PITO_NULL;
        return rv32_inst_dec;
    endfunction

    function rv32_inst_dec_t dec_j_type (rv32_instr_t instr);
        rv32_inst_dec_t rv32_inst_dec;
        //string ins_str;
        string inst_type = "J-Type";
        logic [6:0] opcode = instr[6:0];
        int imm = { {12{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21]};

        rv32_register_field_t rd = instr[11:7];
        if          (opcode == 7'b1101111) begin
            //rv32_inst_dec.ins_str = $sformatf("%8s.%7s: rd=%2d                imm=%4d", inst_type, "jal", rd, imm);
            rv32_inst_dec.opcode      = RV32_JAL;
            rv32_inst_dec.rd          = rd;
            rv32_inst_dec.imm         = imm;
            rv32_inst_dec.inst_type = RV32_TYPE_J;
        end else                           begin
            //rv32_inst_dec.ins_str = "!unknown instruction!";
            rv32_inst_dec.opcode = RV32_UNKNOWN;
            rv32_inst_dec.inst_type = RV32_TYPE_UNKNOWN;
        end
        rv32_inst_dec.csr = `PITO_NULL;
        rv32_inst_dec.rs1 = `PITO_NULL;
        rv32_inst_dec.rs2 = `PITO_NULL;
        return rv32_inst_dec;
    endfunction

    function rv32_inst_dec_t dec_i_type (rv32_instr_t instr);
        rv32_inst_dec_t rv32_inst_dec;
        string inst_type = "I-Type";
        logic [6:0] opcode = instr[6:0];
        int imm = {{20{instr[31]}}, instr[31:20]};
        rv32_register_field_t rd  = instr[11:7]; 
        rv32_register_field_t rs1 = instr[19:15]; 
        fnct3_t             funct3 = instr[14:12];
        rv32_inst_dec.rd          = rd;
        rv32_inst_dec.rs1         = rs1;
        rv32_inst_dec.imm         = imm;
        rv32_inst_dec.inst_type = RV32_TYPE_I;
        rv32_inst_dec.csr         = `PITO_NULL;
        if          (opcode == 7'b1100111) begin
            //rv32_inst_dec.ins_str = $sformatf("%8s.%7s: rd=%2d rs1=%2d           imm=%4d", inst_type, "jalr", rd, rs1, imm);
            rv32_inst_dec.opcode = RV32_JALR;
        end else if (opcode == 7'b0000011) begin
            string funct3_str;
            case (funct3)
                3'b000  : begin rv32_inst_dec.opcode = RV32_LB     ; funct3_str = "lb"; end
                3'b001  : begin rv32_inst_dec.opcode = RV32_LH     ; funct3_str = "lh"; end
                3'b010  : begin rv32_inst_dec.opcode = RV32_LW     ; funct3_str = "lw"; end
                3'b100  : begin rv32_inst_dec.opcode = RV32_LBU    ; funct3_str = "lbu"; end
                3'b101  : begin rv32_inst_dec.opcode = RV32_LHU    ; funct3_str = "lhu"; end
                default : begin rv32_inst_dec.opcode = RV32_UNKNOWN; funct3_str = "unknown"; end/* default */
            endcase
            //rv32_inst_dec.ins_str = $sformatf("%8s.%7s: rd=%2d rs1=%2d           imm=%4d", inst_type, funct3_str, rd, rs1, imm);
        end else if (opcode == 7'b0010011) begin
            string funct3_str;
            case (funct3)
                3'b000  : begin rv32_inst_dec.opcode = RV32_ADDI; funct3_str = "addi"; end
                3'b001  : begin if (instr[31:25]==0) begin 
                                    funct3_str = "slli"; 
                                    rv32_inst_dec.opcode = RV32_SLLI; 
                                    rv32_inst_dec.imm    = instr[25:20];
                                end else begin
                                    rv32_inst_dec.opcode = RV32_UNKNOWN; 
                                    funct3_str = "unknown"; 
                                end 
                          end
                3'b010  : begin rv32_inst_dec.opcode = RV32_SLTI; funct3_str = "slti"; end
                3'b011  : begin rv32_inst_dec.opcode = RV32_SLTIU;funct3_str = "sltiu"; end
                3'b100  : begin rv32_inst_dec.opcode = RV32_XORI; funct3_str = "xori"; end
                3'b101  : begin if (instr[31:25]==0) begin
                                    funct3_str = "srli";
                                    rv32_inst_dec.opcode = RV32_SRLI;
                                    rv32_inst_dec.imm    = instr[25:20];
                                end else if (instr[31:25]==7'b0100000) begin
                                    funct3_str = "srai";
                                    rv32_inst_dec.imm    = instr[25:20];
                                    rv32_inst_dec.opcode = RV32_SRAI;
                                end else begin
                                    funct3_str = "unknown";
                                    rv32_inst_dec.opcode = RV32_UNKNOWN;
                                end
                            end
                3'b110  : begin rv32_inst_dec.opcode = RV32_ORI;     funct3_str = "ori"; end
                3'b111  : begin rv32_inst_dec.opcode = RV32_ANDI;    funct3_str = "andi"; end
                default : begin rv32_inst_dec.opcode = RV32_UNKNOWN; funct3_str = "unknown"; end/* default */
            endcase
            //rv32_inst_dec.ins_str = $sformatf("%8s.%7s: rd=%2d rs1=%2d           imm=%4d", inst_type, funct3_str, rd, rs1, imm);
        end else if (opcode == 7'b0001111) begin
            string funct3_str;
            case (funct3)
                3'b000  : begin rv32_inst_dec.opcode = RV32_FENCE  ; funct3_str = "fence" ; end
                3'b001  : begin rv32_inst_dec.opcode = RV32_FENCEI ; funct3_str = "fencei"; end
                default : begin rv32_inst_dec.opcode = RV32_UNKNOWN; funct3_str = "unknown"; end/* default */
            endcase
            //rv32_inst_dec.ins_str = "fence instruction   [NOT SUPPORTED]";
        end else if (opcode == 7'b1110011) begin
            string funct3_str;
            case (funct3)
                3'b000  : begin if (instr[31:20]==0) begin 
                                    funct3_str = "ecall"; 
                                    rv32_inst_dec.opcode = RV32_ECALL; 
                                    rv32_inst_dec.imm    = 0;
                                end else if (instr[31:20]==1) begin 
                                    funct3_str = "ebreak"; 
                                    rv32_inst_dec.opcode = RV32_EBREAK; 
                                    rv32_inst_dec.imm    = 0;
                                end else begin
                                    rv32_inst_dec.opcode = RV32_UNKNOWN; 
                                    funct3_str = "unknown"; 
                                end 
                          end
                3'b001  : begin 
                            rv32_inst_dec.opcode = RV32_CSRRW  ; funct3_str = "csrrw"  ;
                            rv32_inst_dec.csr    = instr[31:20];
                            end
                3'b010  : begin 
                            rv32_inst_dec.opcode = RV32_CSRRS  ; funct3_str = "csrrs"  ;
                            rv32_inst_dec.csr    = instr[31:20];
                            end
                3'b011  : begin 
                            rv32_inst_dec.opcode = RV32_CSRRC  ; funct3_str = "csrrc"  ;
                            rv32_inst_dec.csr    = instr[31:20];
                            end
                3'b101  : begin 
                            rv32_inst_dec.opcode = RV32_CSRRWI ; funct3_str = "csrrwi" ; 
                            rv32_inst_dec.imm    = instr[19:15];
                            rv32_inst_dec.csr    = instr[31:20];
                            end
                3'b110  : begin 
                            rv32_inst_dec.opcode = RV32_CSRRSI ; funct3_str = "csrrsi" ; 
                            rv32_inst_dec.imm    = instr[19:15];
                            rv32_inst_dec.csr    = instr[31:20];
                            end
                3'b111  : begin 
                            rv32_inst_dec.opcode = RV32_CSRRCI ; funct3_str = "csrrci" ; 
                            rv32_inst_dec.imm    = instr[19:15];
                            rv32_inst_dec.csr    = instr[31:20];
                            end
                default : begin rv32_inst_dec.opcode = RV32_UNKNOWN; funct3_str = "unknown"; end/* default */
            endcase
            rv32_inst_dec.csr = instr[31:20];
        end else begin
            //rv32_inst_dec.ins_str = "!unknown instruction!";
            rv32_inst_dec.opcode = RV32_UNKNOWN;
            rv32_inst_dec.inst_type = RV32_TYPE_UNKNOWN;
        end
        return rv32_inst_dec;
    endfunction

    function rv32_inst_dec_t dec_b_type (rv32_instr_t instr);
        rv32_inst_dec_t rv32_inst_dec;
        //string ins_str;
        string inst_type = "B-Type";
        logic [6:0] opcode = instr[6:0];
        logic [11:0] pre_imm = {instr[31:25], instr[11:7]};
        int imm = { {20{pre_imm[11]}}, {pre_imm[11], pre_imm[0], pre_imm[10:5], pre_imm[4:1]}};
        rv32_register_field_t rs1 = instr[19:15];
        rv32_register_field_t rs2 = instr[24:20];
        fnct3_t             funct3 = instr[14:12];
        rv32_inst_dec.rd              = `PITO_NULL;
        rv32_inst_dec.imm             = imm;
        rv32_inst_dec.inst_type       = RV32_TYPE_B;
        rv32_inst_dec.csr             = `PITO_NULL;
        rv32_inst_dec.rs1             = rs1;
        rv32_inst_dec.rs2             = rs2;
        if          (opcode == 7'b1100011) begin
            string funct3_str;
            case (funct3)
                3'b000  : begin rv32_inst_dec.opcode = RV32_BEQ    ; funct3_str = "beq"; end
                3'b001  : begin rv32_inst_dec.opcode = RV32_BNE    ; funct3_str = "bne"; end
                3'b100  : begin rv32_inst_dec.opcode = RV32_BLT    ; funct3_str = "blt"; end
                3'b101  : begin rv32_inst_dec.opcode = RV32_BGE    ; funct3_str = "bge"; end
                3'b110  : begin rv32_inst_dec.opcode = RV32_BLTU   ; funct3_str = "bltu"; end
                3'b111  : begin rv32_inst_dec.opcode = RV32_BGEU   ; funct3_str = "bgeu"; end
                default : begin rv32_inst_dec.opcode = RV32_UNKNOWN; funct3_str = "unknown"; end
            endcase
            //rv32_inst_dec.ins_str = $sformatf("%8s.%7s:       rs1=%2d rs2=  %2d  imm=%4d", inst_type, funct3_str, rs1, rs2, imm);;
        end else                           begin
            //rv32_inst_dec.ins_str = "!unknown instruction!";
            rv32_inst_dec.opcode = RV32_UNKNOWN;
        end
        return rv32_inst_dec;
    endfunction

    function rv32_inst_dec_t dec_s_type (rv32_instr_t instr);
        rv32_inst_dec_t rv32_inst_dec;
        //string ins_str;
        string inst_type = "S-Type";
        logic [6:0] opcode = instr[6:0];
        int imm = { {20{instr[31]}}, {instr[31:25], instr[11:7]}};
        rv32_register_field_t rs1 = instr[19:15];
        rv32_register_field_t rs2 = instr[24:20];
        fnct3_t             funct3 = instr[14:12];
        
        rv32_inst_dec.rd             = `PITO_NULL;
        rv32_inst_dec.imm            = imm;
        rv32_inst_dec.inst_type    = RV32_TYPE_S;
        rv32_inst_dec.csr            = `PITO_NULL;
        rv32_inst_dec.rs1            = rs1;
        rv32_inst_dec.rs2            = rs2;
        if          (opcode == 7'b0100011) begin
            string funct3_str;
            case (funct3)
                3'b000  : begin rv32_inst_dec.opcode = RV32_SB;      funct3_str = "sb"; end
                3'b001  : begin rv32_inst_dec.opcode = RV32_SH;      funct3_str = "sh"; end
                3'b010  : begin rv32_inst_dec.opcode = RV32_SW;      funct3_str = "sw"; end
                default : begin rv32_inst_dec.opcode = RV32_UNKNOWN; funct3_str = "unknown"; end
            endcase
            //rv32_inst_dec.ins_str = $sformatf("%8s.%7s:       rs1=%2d rs2=  %2d  imm=%4d", inst_type, funct3_str, rs1, rs2, imm);
        end else                           begin
            //rv32_inst_dec.ins_str = "!unknown instruction!";
            rv32_inst_dec.opcode         = RV32_UNKNOWN;
        end
        return rv32_inst_dec;
    endfunction

    function rv32_inst_dec_t dec_r_type (rv32_instr_t instr);
        rv32_inst_dec_t rv32_inst_dec;
        //string ins_str;
        string inst_type = "R-Type";
        logic [6:0] opcode = instr[6:0];
        rv32_register_field_t rd  = instr[11:7];
        rv32_register_field_t rs1 = instr[19:15];
        rv32_register_field_t rs2 = instr[24:20];
        fnct3_t             funct3 = instr[14:12];
        rv32_inst_dec.rd             = rd;
        rv32_inst_dec.imm            = `PITO_NULL;
        rv32_inst_dec.inst_type      = RV32_TYPE_R;
        rv32_inst_dec.csr            = `PITO_NULL;
        rv32_inst_dec.rs1            = rs1;
        rv32_inst_dec.rs2            = rs2;
        if          (opcode == 7'b0110011) begin
            string funct3_str;
            case (funct3)
                3'b000  : begin if (instr[31:25]==7'b0000000) begin
                                  funct3_str = "add"; 
                                  rv32_inst_dec.opcode  = RV32_ADD;
                                end else if (instr[31:25]==7'b0100000) begin
                                  funct3_str = "sub"; 
                                  rv32_inst_dec.opcode  = RV32_SUB;
                                end else begin 
                                  funct3_str = "unknown";
                                  rv32_inst_dec.opcode  = RV32_UNKNOWN;
                                end
                          end
                3'b001  : begin rv32_inst_dec.opcode = RV32_SLL;  funct3_str = "sll";  end
                3'b010  : begin rv32_inst_dec.opcode = RV32_SLT;  funct3_str = "slt";  end
                3'b011  : begin rv32_inst_dec.opcode = RV32_SLTU; funct3_str = "sltu"; end
                3'b100  : begin rv32_inst_dec.opcode = RV32_XOR;  funct3_str = "xor";  end
                3'b101  : begin if (instr[31:25]==7'b0000000) begin
                                    funct3_str = "srl"; 
                                    rv32_inst_dec.opcode = RV32_SRL;
                                end else if (instr[31:25]==7'b0100000) begin 
                                    funct3_str = "sra"; 
                                    rv32_inst_dec.opcode = RV32_SRA;
                                end else begin 
                                    funct3_str = "unknown";
                                    rv32_inst_dec.opcode = RV32_UNKNOWN;
                                end
                          end
                3'b110  : begin rv32_inst_dec.opcode = RV32_OR ;     funct3_str = "or";     end
                3'b111  : begin rv32_inst_dec.opcode = RV32_AND;     funct3_str = "and";     end
                default : begin rv32_inst_dec.opcode = RV32_UNKNOWN; funct3_str = "unknown"; end
            endcase
            //rv32_inst_dec.ins_str = $sformatf("%8s.%7s: rd=%2d rs1=%2d rs2=  %2d          ", inst_type, funct3_str, rd, rs1, rs2);
        end else                           begin
            //rv32_inst_dec.ins_str = "!unknown instruction!";
            rv32_inst_dec.opcode = RV32_UNKNOWN;
        end
        return rv32_inst_dec;
    endfunction

    function rv32_inst_dec_t decode_instr (rv32_instr_t instr);
        static rv32_inst_dec_t decode_ins;
        static logic [6:0] opcode;
        opcode = instr[6:0];
        if ((opcode == 7'b0110111) || (opcode == 7'b0010111) ) begin //U-Type
            decode_ins = dec_u_type(instr);
        end else if (opcode == 7'b1101111) begin // J-Type
            decode_ins = dec_j_type(instr);
        end else if ((opcode == 7'b1100111) || 
                     (opcode == 7'b0000011) || 
                     (opcode == 7'b0010011) || 
                     (opcode == 7'b0001111) || 
                     (opcode == 7'b1110011)) begin // I-Type
            if (instr[31:7] == {25{1'b0}}) begin
                decode_ins = dec_nop_type(instr);
            end else begin
                decode_ins = dec_i_type(instr);
            end
        end else if (opcode == 7'b1100011) begin // B-Type
            decode_ins = dec_b_type(instr);
        end else if (opcode == 7'b0100011) begin // S-Type
            decode_ins = dec_s_type(instr);
        end else if (opcode == 7'b0110011) begin // R-Type
            decode_ins = dec_r_type(instr);
        end else begin
            decode_ins.opcode    = RV32_UNKNOWN;
            decode_ins.imm       = 0;
            decode_ins.csr       = 0;
            decode_ins.rs1       = 0;
            decode_ins.rs2       = 0;
            decode_ins.rd        = 0;
            decode_ins.inst_type = RV32_TYPE_UNKNOWN;
        end
        return decode_ins;
    endfunction

endclass

class RV32IPredictor extends BaseObj;
    test_stats_t test_stat;
    rv32_csrfile_t csrf_model[];
    rv32_regfile_t regf_model[];
    int riscv_data_mem [logic[31:0]];
    int num_harts;

    function init_regfile_model();
        int file_faults = $fopen (`REG_FILE_INIT, "r");
        integer scan_faults;
        int reg_cnt = 0;
        string line;
        while (!$feof(file_faults) && reg_cnt< 32) begin
            scan_faults = $fgets(line, file_faults);
            for (int regf=0; regf < this.num_harts; regf++) begin
                this.regf_model[regf][reg_cnt] = line.atohex();
            end
            reg_cnt += 1;
        end
    endfunction

    function init_csrfile_model();
        int file_faults = $fopen (`CSR_FILE_INIT, "r");
        integer scan_faults;
        int reg_cnt = 0;
        string line;
        while (!$feof(file_faults) && reg_cnt< `NUM_CSR) begin
            scan_faults = $fgets(line, file_faults);
            for (int regf=0; regf < this.num_harts; regf++) begin
                this.csrf_model[regf][reg_cnt] = line.atohex();
            end
            reg_cnt += 1;
        end
    endfunction

    function init_data_mem_model (rv32_data_q data_q);
        for (int addr=0; addr<data_q.size(); addr++) begin
            if (data_q[addr] != 0) begin
                riscv_data_mem[addr] = data_q[addr];
            end
        end
    endfunction 

    function new (Logger logger, rv32_data_q data_q, int num_harts);
        super.new(logger);   // Calls 'new' method of parent class
        this.num_harts = num_harts;
        test_stat = '{pass_cnt: 0, fail_cnt: 0};
        regf_model = new[num_harts];
        csrf_model = new[`NUM_CSR];
        init_regfile_model();
        init_data_mem_model(data_q);
    endfunction

    function void report_result (bit is_riscv_test, rv32_data_q hart_ids_q);
        string res_str;
        print_result(this.test_stat, VERB_LOW, this.logger);
        for (int id=0; id<hart_ids_q.size(); id++) begin
            if (is_riscv_test && hart_ids_q[id]==1) begin
                res_str = $sformatf("[HARTID: %1d] RISC-V Test Result: %c%c%c%c", id, this.regf_model[id][11], this.regf_model[id][12], this.regf_model[id][13], this.regf_model[id][14]);
                this.logger.print(res_str);
            end
        end
    endfunction : report_result

    function update_regf(bit has_update, rv32_register_field_t rd, int val, int hart_id);
        if (has_update) begin
            if (rd != 0) begin
                this.regf_model[hart_id][rd] = val;
            end
        end
    endfunction

    function rv32_csr_access_enum_t cse_access_type (pito_pkg::csr_t csr_i);
        rv32_csr_access_enum_t access;
        case (csr_i)
            pito_pkg::CSR_MVENDORID      : access = rv32_pkg::RV32_WIRI;
            pito_pkg::CSR_MARCHID        : access = rv32_pkg::RV32_WIRI;
            pito_pkg::CSR_MIMPID         : access = rv32_pkg::RV32_WIRI;
            pito_pkg::CSR_MHARTID        : access = rv32_pkg::RV32_WIRI;
            pito_pkg::CSR_MSTATUS        : access = rv32_pkg::RV32_WPRI;
            pito_pkg::CSR_MISA           : access = rv32_pkg::RV32_WPRI;
            pito_pkg::CSR_MIE            : access = rv32_pkg::RV32_WPRI;
            pito_pkg::CSR_MTVEC          : access = rv32_pkg::RV32_WARL;
            pito_pkg::CSR_MSCRATCH       : access = rv32_pkg::RV32_WIRI;
            pito_pkg::CSR_MEPC           : access = rv32_pkg::RV32_WARL;
            pito_pkg::CSR_MCAUSE         : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MTVAL          : access = rv32_pkg::RV32_WARL;
            pito_pkg::CSR_MIP            : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MCYCLE         : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MINSTRET       : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MCYCLEH        : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MINSTRETH      : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MCALL          : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MRET           : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MVU_WBASEADDR  : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MVU_IBASEADDR  : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MVU_OBASEADDR  : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MVU_WSTRIDE_0  : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MVU_WSTRIDE_1  : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MVU_WSTRIDE_2  : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MVU_ISTRIDE_0  : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MVU_ISTRIDE_1  : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MVU_ISTRIDE_2  : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MVU_OSTRIDE_0  : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MVU_OSTRIDE_1  : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MVU_OSTRIDE_2  : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MVU_WLENGTH_0  : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MVU_WLENGTH_1  : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MVU_WLENGTH_2  : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MVU_ILENGTH_0  : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MVU_ILENGTH_1  : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MVU_ILENGTH_2  : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MVU_OLENGTH_0  : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MVU_OLENGTH_1  : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MVU_OLENGTH_2  : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MVU_PRECISION  : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MVU_STATUS     : access = rv32_pkg::RV32_WIRI;
            pito_pkg::CSR_MVU_COMMAND    : access = rv32_pkg::RV32_WLRL;
            pito_pkg::CSR_MVU_QUANT      : access = rv32_pkg::RV32_WLRL;
            default : access = rv32_pkg::RV32_WIRI;/* default */
        endcase
        return access;
    endfunction 

    function update_csrf(bit has_update, rv32_csr_t csr_i, int val, int hart_id, pito_pkg::csr_op_t csr_op);
        pito_pkg::csr_t csr = pito_pkg::csr_t'(csr_i);
        if (has_update) begin
            rv32_csr_access_enum_t access_type = cse_access_type(csr);
            if (access_type == RV32_WLRL || access_type == RV32_WARL) begin
                case (csr_op)
                    MRET           : this.logger.print($sformatf("ERROR: MRET instruction attempts to write to CSR file mode on HART[%0d]", hart_id));
                    CSR_READ_WRITE : this.regf_model[hart_id][csr] = val;
                    CSR_SET        : this.regf_model[hart_id][csr] = this.regf_model[hart_id][csr] | val;
                    CSR_CLEAR      : this.regf_model[hart_id][csr] = (~this.regf_model[hart_id][csr]) & val;
                    default : /* default */;
                endcase
            end else begin
                this.logger.print($sformatf("ERROR: Attempt to write to hart[%1d].csr[%s] has failed. No write access is allowed.", hart_id, csr.name));
            end
        end
    endfunction

    function void write_to_mem(int addr, int val, int size);
        if (size==1) begin
            riscv_data_mem[addr] = val[7:0];
        end else if (size==2) begin
            // riscv_data_mem[addr  ] = val[7 :0];
            riscv_data_mem[addr] = val[15:0];
        end else if (size==4) begin
            riscv_data_mem[addr] = val;
            // riscv_data_mem[addr+1] = val[15 : 8 ];
            // riscv_data_mem[addr+2] = val[23 : 16];
            // riscv_data_mem[addr+3] = val[31 : 24];
        end else begin
            this.logger.print($sformatf("ERROR: Address not accessible for a variable size %0d", size));
        end
    endfunction

    function int read_from_mem(int addr, int size, bit is_signed);
        int ret_val = 0;
        if (size==1) begin
            ret_val = riscv_data_mem[addr >> 2];
            if (is_signed) begin
                case (addr[1:0])
                    2'b00: ret_val = signed'(ret_val[7 : 0]);
                    2'b01: ret_val = signed'(ret_val[15: 8]);
                    2'b10: ret_val = signed'(ret_val[23:16]);
                    2'b11: ret_val = signed'(ret_val[31:24]);
                    default : ret_val = 0;
                endcase
            end else begin
                case (addr[1:0])
                    2'b00: ret_val = unsigned'(ret_val[7 : 0]);
                    2'b01: ret_val = unsigned'(ret_val[15: 8]);
                    2'b10: ret_val = unsigned'(ret_val[23:16]);
                    2'b11: ret_val = unsigned'(ret_val[31:24]);
                    default : ret_val = 0;
                endcase
            end
        end else if (size==2) begin
            ret_val = riscv_data_mem[addr >> 2];
            if (is_signed) begin
                case (addr[1:0])
                    2'b00: ret_val = signed'(ret_val[15: 0]);
                    2'b10: ret_val = signed'(ret_val[31:16]);
                    default : ret_val = 0;
                endcase
            end else begin
                case (addr[1:0])
                    2'b00: ret_val = unsigned'(ret_val[15: 0]);
                    2'b10: ret_val = unsigned'(ret_val[31:16]);
                    default : ret_val = 0;
                endcase
            end
        end else if (size==4) begin
            ret_val = riscv_data_mem[addr >> 2];
        end else begin
            this.logger.print($sformatf("ERROR: Reading of size %0d from memory is not available.", size));
        end
        return ret_val;
    endfunction


    function void check_res(rv32_instr_t act_instr, int exp_val, int real_val, int hart_id, string info="", rv32_pc_cnt_t pc_cnt=0);
        info = $sformatf("%s pc=%4h", info, int'(pc_cnt));
        if ( exp_val == real_val) begin
            this.test_stat.pass_cnt ++;
            this.logger.print($sformatf("[HART_ID:%1d]Test Pass [0x%8h: %s]: Expecting %0d got %0d", hart_id, act_instr, info, exp_val, real_val));
        end else begin
            this.test_stat.fail_cnt ++;
            this.logger.print($sformatf("[HART_ID:%1d]Test Fail [0x%8h: %s]: Expecting %0d got %0d", hart_id, act_instr, info, exp_val, real_val));
        end
    endfunction

    function void predict (rv32_instr_t act_instr, rv32_inst_dec_t instr, rv32_pc_cnt_t pc_cnt, rv32_pc_cnt_t pc_orig_cnt, rv32_regfile_t regf, rv32_csrfile_t csrs, int mem_val, int hart_id);
        rv32_opcode_enum_t    opcode    = instr.opcode   ;
        rv32_imm_t            imm       = instr.imm      ;
        rv32_csr_t            csr       = instr.csr      ;
        rv32_register_field_t rs1       = instr.rs1      ;
        rv32_register_field_t rs2       = instr.rs2      ;
        rv32_register_field_t rd        = instr.rd       ;
        rv32_type_enum_t      inst_type = instr.inst_type;
        string                instr_str = get_instr_str(instr);
        int                   exp_val, real_val;
        int                   addr;
        string                info;
        bit                   has_rf_update = 0;
        bit                   has_csr_update = 0;
        pito_pkg::csr_op_t    csr_op   = pito_pkg::CSR_UNKNOWN;
        pito_pkg::csr_t       csr_enum = pito_pkg::csr_t'(csr);
        string                csr_str  = csr_enum.name;
        case (opcode)
            RV32_LB     : begin
                addr      = (rs1==0) ? signed'(imm) : regf_model[hart_id][rs1]+signed'(imm);
                exp_val   = (rd==0) ? 0 : read_from_mem(addr, 1, 1);
                real_val  = regf[rd];
                info      = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_LH     : begin
                addr      = (rs1==0) ? signed'(imm) : regf_model[hart_id][rs1]+signed'(imm);
                exp_val   = (rd==0) ? 0 : read_from_mem(addr, 2, 1);
                real_val  = regf[rd];
                info      = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_LW     : begin
                addr      = (rs1==0) ? signed'(imm) : regf_model[hart_id][rs1]+signed'(imm);
                exp_val   = (rd==0) ? 0 : read_from_mem(addr, 4, 1);
                real_val  = regf[rd];
                info      = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_LBU    : begin
                addr      = (rs1==0) ? signed'(imm) : regf_model[hart_id][rs1]+signed'(imm);
                exp_val   = (rd==0) ? 0 : read_from_mem(addr, 1, 0);
                real_val  = regf[rd];
                info      = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_LHU    : begin
                addr      = (rs1==0) ? signed'(imm) : regf_model[hart_id][rs1]+signed'(imm);
                exp_val   = (rd==0) ? 0 : read_from_mem(addr, 2, 0);
                real_val  = regf[rd];
                info      = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_SB     : begin
                addr      = (rs1==0) ? signed'(imm) : regf_model[hart_id][rs1]+signed'(imm);
                addr      = addr - `PITO_DATA_MEM_OFFSET;
                exp_val   = regf_model[hart_id][rs2];
                real_val  = mem_val;
                info      = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
                write_to_mem( addr, regf_model[hart_id][rs2], 1);
            end
            RV32_SH     : begin
                addr      = (rs1==0) ? signed'(imm) : regf_model[hart_id][rs1]+signed'(imm);
                addr      = addr - `PITO_DATA_MEM_OFFSET;
                exp_val   = regf_model[hart_id][rs2];
                real_val  = mem_val;
                info      = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
                write_to_mem( addr, regf_model[hart_id][rs2], 2);
            end
            RV32_SW     : begin
                addr      = (rs1==0) ? signed'(imm) : regf_model[hart_id][rs1]+signed'(imm);
                addr      = addr - `PITO_DATA_MEM_OFFSET;
                exp_val   = regf_model[hart_id][rs2];
                real_val  = mem_val;
                info      = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
                write_to_mem( addr, regf_model[hart_id][rs2], 4);
            end
            RV32_SLL    : begin
                exp_val  = (rd==0) ? 0 : (regf_model[hart_id][rs1] << (regf_model[hart_id][rs2]&32'h0000_001F));
                real_val =  regf[rd];
                info     = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_SLLI   : begin
                imm = int'(imm[4:0]);
                exp_val  = (rd==0) ? 0 : (regf_model[hart_id][rs1] << (imm&32'h0000_001F));
                real_val =  regf[rd];
                info     = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_SRL    : begin
                exp_val  = (rd==0) ? 0 : (regf_model[hart_id][rs1] >> (regf_model[hart_id][rs2]&32'h0000_001F));
                real_val =  regf[rd];
                info     = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_SRLI   : begin
                imm = int'(imm[4:0]);
                exp_val  = (rd==0) ? 0 : (regf_model[hart_id][rs1] >> (imm&32'h0000_001F));
                real_val =  regf[rd];
                info     = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_SRA    : begin
                exp_val  = (rd==0) ? 0 : (signed'(regf_model[hart_id][rs1]) >>> (regf_model[hart_id][rs2]&32'h0000_001F));
                real_val =  regf[rd];
                info     = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_SRAI   : begin
                imm = int'(imm[4:0]);
                exp_val  = (rd==0) ? 0 : (signed'(regf_model[hart_id][rs1]) >>> imm);
                real_val =  regf[rd];
                info     = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_ADD    : begin
                exp_val  = (rd==0) ? 0 : (regf_model[hart_id][rs1] + regf_model[hart_id][rs2]);
                real_val =  regf[rd];
                info     = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_ADDI   : begin
                exp_val  = (rd==0) ? 0 : (regf_model[hart_id][rs1] + int'(imm));
                real_val =  regf[rd];
                info     = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_SUB    : begin
                exp_val  = (rd==0) ? 0 : (regf_model[hart_id][rs1] - regf_model[hart_id][rs2]);
                real_val =  regf[rd];
                info     = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_LUI    : begin
                exp_val  = (rd==0) ? 0 : (int'(imm)<<12);
                real_val =  regf[rd];
                info     = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_AUIPC  : begin
                exp_val  = (rd==0) ? 0 : (int'(pc_cnt)) + (int'(imm)<<12);
                real_val =  regf[rd];
                info     = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_XOR    : begin
                exp_val  = (rd==0) ? 0 : (regf_model[hart_id][rs1] ^ regf_model[hart_id][rs2]);
                real_val =  regf[rd];
                info     = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_XORI   : begin
                exp_val  = (rd==0) ? 0 : (regf_model[hart_id][rs1] ^ int'(imm));
                real_val =  regf[rd];
                info     = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_OR     : begin
                exp_val  = (rd==0) ? 0 : (regf_model[hart_id][rs1] | regf_model[hart_id][rs2]);
                real_val =  regf[rd];
                info     = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_ORI    : begin
                exp_val  = (rd==0) ? 0 : (regf_model[hart_id][rs1] | int'(imm));
                real_val =  regf[rd];
                info     = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_AND    : begin
                exp_val  = (rd==0) ? 0 : (regf_model[hart_id][rs1] & regf_model[hart_id][rs2]);
                real_val =  regf[rd];
                info     = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_ANDI   : begin
                exp_val  = (rd==0) ? 0 : (regf_model[hart_id][rs1] & int'(imm));
                real_val =  regf[rd];
                info     = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_SLT    : begin
                exp_val  = (rd==0) ? 0 : (signed'(regf_model[hart_id][rs1]) < signed'(regf_model[hart_id][rs2])) ? 1 : 0;
                real_val =  regf[rd];
                info     = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_SLTI   : begin
                exp_val  = (rd==0) ? 0 : (signed'(regf_model[hart_id][rs1]) < signed'( int'(imm))) ? 1 : 0;
                real_val =  regf[rd];
                info     = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_SLTU   : begin
                exp_val  = (rd==0) ? 0 : (unsigned'(regf_model[hart_id][rs1]) < unsigned'(regf_model[hart_id][rs2]));
                real_val =  regf[rd];
                info     = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_SLTIU  : begin
                exp_val  = (rd==0) ? 0 : (unsigned'(regf_model[hart_id][rs1]) < unsigned'(imm));
                real_val =  regf[rd];
                info     = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_BEQ    : begin
                // $display($sformatf("BEQ-------> rs1=%0d rs2=%0d",signed'(regf_model[hart_id][rs1]), signed'(regf_model[hart_id][rs2])));
                exp_val  = (signed'(regf_model[hart_id][rs1]) == signed'(regf_model[hart_id][rs2])) ? (pc_orig_cnt + signed'(imm<<1)) : pc_orig_cnt;
                real_val = pc_cnt;
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_BNE    : begin
                exp_val  = (signed'(regf_model[hart_id][rs1]) != signed'(regf_model[hart_id][rs2])) ? (pc_orig_cnt + signed'(imm<<1)) : pc_orig_cnt;
                real_val =  pc_cnt;
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_BLT    : begin
                exp_val  = (signed'(regf_model[hart_id][rs1]) < signed'(regf_model[hart_id][rs2])) ? (pc_orig_cnt + signed'(imm<<1)) : pc_orig_cnt;
                real_val =  pc_cnt;
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_BGE    : begin
                exp_val  = (signed'(regf_model[hart_id][rs1]) >= signed'(regf_model[hart_id][rs2])) ? (pc_orig_cnt + signed'(imm<<1)) : pc_orig_cnt;
                real_val =  pc_cnt;
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_BLTU   : begin
                exp_val  = (unsigned'(regf_model[hart_id][rs1]) < unsigned'(regf_model[hart_id][rs2])) ? (pc_orig_cnt + signed'(imm<<1)) : pc_orig_cnt;
                real_val =  pc_cnt;
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_BGEU   : begin
                exp_val  = (unsigned'(regf_model[hart_id][rs1]) >= unsigned'(regf_model[hart_id][rs2])) ? (pc_orig_cnt + signed'(imm<<1)) : pc_orig_cnt;
                real_val =  pc_cnt;
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_JAL    : begin
                exp_val  = pc_orig_cnt + signed'(imm<<1);
                real_val = pc_cnt;
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
                exp_val  = (rd==0) ? 0 : pc_orig_cnt + 4;
                real_val = regf_model[hart_id][rd];
                info     = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_JALR   : begin
                exp_val  = regf_model[hart_id][rs1] + signed'(imm);
                real_val = pc_cnt;
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
                exp_val  = (rd==0) ? 0 : pc_orig_cnt + 4;
                real_val = regf_model[hart_id][rd];
                info     = instr_str;
                has_rf_update=1;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_CSRRW  : begin
                exp_val  = csrf_model[csr];
                real_val = regf[rd];
                info     = $sformatf("%s %18s",instr_str, csr_str);
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
                exp_val  = regf_model[rs1];
                real_val = csrs[csr];
                info     = $sformatf("%s %18s",instr_str, csr_str);
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
                has_csr_update = 1;
                csr_op   = pito_pkg::CSR_READ_WRITE;
            end
            RV32_CSRRS  : begin
                exp_val  = csrf_model[csr];
                real_val = regf[rd];
                info     = $sformatf("%s %18s",instr_str, csr_str);
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
                exp_val  = regf_model[rs1] | csrs[csr];
                real_val = csrs[csr];
                info     = $sformatf("%s %18s",instr_str, csr_str);
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
                has_csr_update = 1;
                csr_op   = pito_pkg::CSR_SET;
            end
            RV32_CSRRC  : begin
                exp_val  = csrf_model[csr];
                real_val = regf[rd];
                info     = $sformatf("%s %18s",instr_str, csr_str);
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
                exp_val  = (~regf_model[rs1]) & csrs[csr];
                real_val = csrs[csr];
                info     = $sformatf("%s %18s",instr_str, csr_str);
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
                has_csr_update = 1;
                csr_op   = pito_pkg::CSR_CLEAR;
            end
            RV32_CSRRWI : begin
                exp_val  = csrf_model[csr];
                real_val = regf[rd];
                info     = $sformatf("%s %18s",instr_str, csr_str);
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
                exp_val  = imm;
                real_val = csrs[csr];
                info     = $sformatf("%s %18s",instr_str, csr_str);
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
                has_csr_update = 1;
                csr_op   = pito_pkg::CSR_READ_WRITE;
            end
            RV32_CSRRSI : begin
                exp_val  = csrf_model[csr];
                real_val = regf[rd];
                info     = $sformatf("%s %18s",instr_str, csr_str);
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
                exp_val  = imm | csrs[csr];
                real_val = csrs[csr];
                info     = $sformatf("%s %18s",instr_str, csr_str);
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
                has_csr_update = 1;
                csr_op   = pito_pkg::CSR_SET;
            end
            RV32_CSRRCI : begin
                exp_val  = csrf_model[csr];
                real_val = regf[rd];
                info     = $sformatf("%s %18s",instr_str, csr_str);
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
                exp_val  = (~imm) & csrs[csr];
                real_val = csrs[csr];
                info     = $sformatf("%s %18s",instr_str, csr_str);
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
                has_csr_update = 1;
                csr_op   = pito_pkg::CSR_CLEAR;
            end
            RV32_MRET: begin
                csr_op   = pito_pkg::MRET;
                this.logger.print($sformatf("checking %s  is WIP", instr_str));
            end
            RV32_FENCEI, RV32_FENCE, RV32_ECALL, RV32_EBREAK, 
            RV32_ERET, RV32_WFI: begin
                this.logger.print($sformatf("checking %s  is not supported yet", instr_str));
            end
            RV32_NOP: begin
                // TODO: Write better test to check for NOP, I am not testing it now!
                exp_val  = opcode;
                real_val = RV32_NOP;
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, hart_id, info, pc_cnt);
            end
            RV32_UNKNOWN : begin
                // TODO: send a signal to check_res function to increase filed counts
                // this.logger.print("Unknown Instruction");
                this.logger.print($sformatf("Test Fail [0x%8h: %s] Unknown Instruction, pc=%4h", act_instr, instr_str, pc_orig_cnt));
            end
            endcase
            this.update_regf(has_rf_update, rd, exp_val, hart_id);
            this.update_csrf(has_csr_update, csr, exp_val, hart_id, csr_op);
    endfunction

endclass

    function automatic string reg_file_to_str(rv32_regfile_t regfile);
        int NUM_ROWS = 4;
        int NUM_COLS = 8;
        string reg_vals = "";
        for (int i=0; i< NUM_ROWS; i++) begin
            for (int j=0; j< NUM_COLS; j++) begin
                reg_vals = $sformatf("%s[%4s]:0x%8h  ", reg_vals, rv32_abi_reg_s[i*NUM_COLS+j], regfile[i*NUM_COLS+j]);
            end
            reg_vals = $sformatf("%s\n", reg_vals);
        end
        return reg_vals;
    endfunction

    function automatic string get_instr_str(rv32_inst_dec_t instr);
        string instr_str;
        string   opcode    = instr.opcode.name        ;
        rv32_imm_t imm     = instr.imm                ;
        rv32_csr_t csr     = instr.csr                ;
        string   rs1       = rv32_abi_reg_s[instr.rs1];
        string   rs2       = rv32_abi_reg_s[instr.rs2];
        string   rd        = rv32_abi_reg_s[instr.rd ];
        string   inst_type = instr.inst_type.name     ;
        case (instr.inst_type)
            RV32_TYPE_R       : instr_str = $sformatf("%17s.%12s: rd=%4s rs1=%4s rs2=  %4s          ", inst_type, opcode, rd, rs1, rs2);
            RV32_TYPE_I       : instr_str = $sformatf("%17s.%12s: rd=%4s rs1=%4s           imm=%4d", inst_type, opcode, rd, rs1, imm);
            RV32_TYPE_S       : instr_str = $sformatf("%17s.%12s:        rs1=%4s rs2=  %4s imm=%4d", inst_type, opcode, rs1, rs2, imm);
            RV32_TYPE_B       : instr_str = $sformatf("%17s.%12s:        rs1=%4s rs2=  %4s imm=%4d", inst_type, opcode, rs1, rs2, imm);
            RV32_TYPE_U       : instr_str = $sformatf("%17s.%12s: rd=%4s rs1=%4s           imm=%4d", inst_type, opcode, rd, rs1, imm);
            RV32_TYPE_J       : instr_str = $sformatf("%17s.%12s: rd=%4s                imm=%4d", inst_type, opcode, rd, imm);
            RV32_TYPE_NOP     : instr_str = $sformatf("%17s.%12s:                             ", inst_type, opcode);
            RV32_TYPE_UNKNOWN : instr_str = "!unknown instruction!";
        endcase
        return instr_str;
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

endpackage: rv32_utils
