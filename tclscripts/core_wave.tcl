# set_property display_limit 3000000 [current_wave_config]
set_property trace_limit   3000000 [current_sim]

add_wave_group pito_core
    add_wave -into pito_core {{/testbench_top/barvinn_inst/pito_rv32_core/clk}}
    add_wave -into pito_core {{/testbench_top/barvinn_inst/pito_rv32_core/rst_n}}
    add_wave_group -into pito_core FetchStage
        add_wave -into FetchStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_pc}}
        add_wave -into FetchStage {{/testbench_top/barvinn_inst/pito_rv32_core/inf/pito_io_imem_addr}}
        add_wave -into FetchStage {{/testbench_top/barvinn_inst/pito_rv32_core/inf/pito_io_imem_data}}
        add_wave -into FetchStage {{/testbench_top/barvinn_inst/pito_rv32_core/inf/pito_io_dmem_addr}}
        add_wave -into FetchStage {{/testbench_top/barvinn_inst/pito_rv32_core/inf/pito_io_dmem_data}}
        add_wave -into FetchStage {{/testbench_top/barvinn_inst/pito_rv32_core/inf/pito_io_imem_w_en}}
        add_wave -into FetchStage {{/testbench_top/barvinn_inst/pito_rv32_core/inf/pito_io_dmem_w_en}}
        add_wave -into FetchStage {{/testbench_top/barvinn_inst/pito_rv32_core/inf/pito_io_program}}
        add_wave -into FetchStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_instr}}
        add_wave -into FetchStage {{/testbench_top/barvinn_inst/pito_rv32_core/pc_sel}}
    add_wave_group -into pito_core DecStage
        add_wave_group -into DecStage RegFile
            add_wave -into RegFile {{/testbench_top/barvinn_inst/pito_rv32_core/regfile/clk}} 
            add_wave -into RegFile {{/testbench_top/barvinn_inst/pito_rv32_core/regfile/rsa_hart}} 
            add_wave -into RegFile {{/testbench_top/barvinn_inst/pito_rv32_core/regfile/rsd_hart}} 
            add_wave -into RegFile {{/testbench_top/barvinn_inst/pito_rv32_core/regfile/rd_hart}} 
            add_wave_group -into RegFile RegFileTop
            add_wave -into RegFileTop {{/testbench_top/barvinn_inst/pito_rv32_core/regfile}} 
            add_wave_group -into RegFile RegFile_0
                add_wave -into RegFile_0 {{/testbench_top/barvinn_inst/pito_rv32_core/regfile/\genblk1[0].regfile /data}} 
            add_wave_group -into RegFile RegFile_1
                add_wave -into RegFile_1 {{/testbench_top/barvinn_inst/pito_rv32_core/regfile/\genblk1[1].regfile /data}} 
            add_wave_group -into RegFile RegFile_2
                add_wave -into RegFile_2 {{/testbench_top/barvinn_inst/pito_rv32_core/regfile/\genblk1[2].regfile /data}} 
            add_wave_group -into RegFile RegFile_3
                add_wave -into RegFile_3 {{/testbench_top/barvinn_inst/pito_rv32_core/regfile/\genblk1[3].regfile /data}} 
            add_wave_group -into RegFile RegFile_4
                add_wave -into RegFile_4 {{/testbench_top/barvinn_inst/pito_rv32_core/regfile/\genblk1[4].regfile /data}} 
            add_wave_group -into RegFile RegFile_5
                add_wave -into RegFile_5 {{/testbench_top/barvinn_inst/pito_rv32_core/regfile/\genblk1[5].regfile /data}} 
            add_wave_group -into RegFile RegFile_6
                add_wave -into RegFile_6 {{/testbench_top/barvinn_inst/pito_rv32_core/regfile/\genblk1[6].regfile /data}} 
            add_wave_group -into RegFile RegFile_7
                add_wave -into RegFile_7 {{/testbench_top/barvinn_inst/pito_rv32_core/regfile/\genblk1[7].regfile /data}} 
        add_wave_group -into DecStage Decoder
            add_wave -into Decoder {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dec_pc}}
            add_wave -into Decoder {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dec_rs1}}
            add_wave -into Decoder {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dec_rd}}
            add_wave -into Decoder {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dec_rs2}}
            add_wave -into Decoder {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dec_shamt}}
            add_wave -into Decoder {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dec_imm}}
            add_wave -into Decoder {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dec_rd1}}
            add_wave -into Decoder {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dec_rd2}}
            add_wave -into Decoder {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dec_fence_succ}}
            add_wave -into Decoder {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dec_fence_pred}}
            add_wave -into Decoder {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dec_csr}}
            add_wave -into Decoder {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dec_instr_trap}}
            add_wave -into Decoder {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dec_alu_op}}
            add_wave -into Decoder {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dec_opcode}}
            add_wave -into Decoder {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dec_instr}}
    add_wave_group -into pito_core EXStage
        add_wave_group -into EXStage Alu
            add_wave -into Alu {{/testbench_top/barvinn_inst/pito_rv32_core/alu_src}}
            add_wave -into Alu {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_alu_rs1}}
            add_wave -into Alu {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_alu_rs2}}
            add_wave -into Alu {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_ex_rd}}
            add_wave -into Alu {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_alu_res}}
            add_wave -into Alu {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_alu_op}}
            add_wave -into Alu {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_alu_z}}
        add_wave -into EXStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_ex_instr}}
        add_wave -into EXStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_ex_rd}}
        add_wave -into EXStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_ex_rs1}}
        add_wave -into EXStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_ex_opcode}}
        add_wave -into EXStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_ex_pc}}
        add_wave -into EXStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_ex_imm}}
        add_wave -into EXStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_ex_readd_addr}}

    add_wave_group -into pito_core WBStage
        add_wave -into WBStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_wb_opcode}}
        add_wave -into WBStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_wb_rd}}
        add_wave -into WBStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_wb_out}}
        add_wave -into WBStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_wb_rs2_skip}}
        add_wave -into WBStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_wb_pc}}
        add_wave -into WBStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_wb_skip}}
        add_wave -into WBStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_wb_instr}}
        add_wave -into WBStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_wb_readd_addr}}
    add_wave_group -into pito_core WFStage
        add_wave -into WFStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_wf_opcode}}
        add_wave -into WFStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_wf_pc}}
        add_wave -into WFStage {{/testbench_top/barvinn_inst/pito_rv32_core/pc_sel}}
        add_wave -into WFStage {{/testbench_top/barvinn_inst/pito_rv32_core/alu_src}}
        add_wave -into WFStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_i_addr}}
        add_wave -into WFStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dmem_addr}}
        add_wave -into WFStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dmem_data}}
        add_wave -into WFStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dmem_w_en}}
        add_wave -into WFStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dw_addr}}
        add_wave -into WFStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dw_data}}
        add_wave -into WFStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dw_en}}
        add_wave -into WFStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dr_addr}}
        add_wave -into WFStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dr_data}}
        add_wave -into WFStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_wf_instr}}
        add_wave -into WFStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_wf_load_val}}
        add_wave -into WFStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_wf_load_val}}
        add_wave -into WFStage {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_regf_wd}}
    add_wave_group -into WFStage Next_PC
            add_wave -into Next_PC {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_next_pc_cal/rv32_alu_res}}
            add_wave -into Next_PC {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_next_pc_cal/rv32_rs1}}
            add_wave -into Next_PC {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_next_pc_cal/rv32_imm}}
            add_wave -into Next_PC {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_next_pc_cal/rv32_instr_opcode}}
            add_wave -into Next_PC {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_next_pc_cal/rv32_cur_pc}}
            add_wave -into Next_PC {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_next_pc_cal/rv32_save_pc}}
            add_wave -into Next_PC {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_next_pc_cal/rv32_has_new_pc}}
            add_wave -into Next_PC {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_next_pc_cal/rv32_reg_pc}}
            add_wave -into Next_PC {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_next_pc_cal/rv32_next_pc_val}}
            add_wave -into Next_PC {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_next_pc_cal/csr_irq_evt}}
add_wave_group decoder
    add_wave -into decoder {{/testbench_top/barvinn_inst/pito_rv32_core/decoder}} 
add_wave_group regfile
    add_wave -into regfile {{/testbench_top/barvinn_inst/pito_rv32_core/regfile}} 
add_wave_group alu
    add_wave -into alu {{/testbench_top/barvinn_inst/pito_rv32_core/alu}} 
add_wave_group pipeline
    add_wave_group -into pipeline pc_counters
        add_wave -into pc_counters {{/testbench_top/barvinn_inst/pito_rv32_core/pc_sel}}
        add_wave -into pc_counters {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_pc}}
        add_wave -into pc_counters {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dec_pc}}
        add_wave -into pc_counters {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_ex_pc}}
        add_wave -into pc_counters {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_wb_pc}}
        add_wave -into pc_counters {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_wf_pc}}
        add_wave -into pc_counters {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_org_ex_pc}}
        add_wave -into pc_counters {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_org_wb_pc}}
        add_wave -into pc_counters {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_org_wf_pc}}
    add_wave_group -into pipeline instructions
        add_wave -into instructions {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_instr}}
        add_wave -into instructions {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dec_instr}}
        add_wave -into instructions {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_ex_instr}}
        add_wave -into instructions {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_wb_instr}}
        add_wave -into instructions {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_wf_instr}}
    add_wave_group -into pipeline opcodes
        add_wave -into opcodes {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_instr}}
        add_wave -into opcodes {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_dec_opcode}}
        add_wave -into opcodes {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_ex_opcode}}
        add_wave -into opcodes {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_wb_opcode}}
        add_wave -into opcodes {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_wf_opcode}}
    add_wave_group -into pipeline rs1_2
        add_wave -into rs1_2 {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_alu_rs1}}
        add_wave -into rs1_2 {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_alu_rs2}}
        add_wave -into rs1_2 {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_wb_alu_rs1}}
        add_wave -into rs1_2 {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_wb_alu_rs2}}
        add_wave -into rs1_2 {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_wf_alu_rs1}}
        add_wave -into rs1_2 {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_wf_alu_rs2}}
        add_wave -into rs1_2 {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_cap_alu_rs1}}
        add_wave -into rs1_2 {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_cap_alu_rs2}}
    add_wave_group -into pipeline harts
        add_wave_group -into harts hart_ids
            add_wave -into hart_ids {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_hart_cnt}}
            add_wave -into hart_ids {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_hart_fet_cnt}}
            add_wave -into hart_ids {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_hart_dec_cnt}}
            add_wave -into hart_ids {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_hart_ex_cnt}}
            add_wave -into hart_ids {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_hart_wb_cnt}}
            add_wave -into hart_ids {{/testbench_top/barvinn_inst/pito_rv32_core/rv32_hart_wf_cnt}}


add_wave_group csr
    add_wave_group -into csr csr0
            add_wave -into csr0  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[0].csrfile /mvu_irq_i}}
            add_wave -into csr0  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[0].csrfile /mcause_q}} 
            add_wave -into csr0  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[0].csrfile /mvu_start}}
            add_wave -into csr0  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[0].csrfile /csr_mvucommand}}
            add_wave -into csr0 {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[0].csrfile /csr_mvuprecision}}
            add_wave -into csr0 {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[0].csrfile /csr_op}}
            add_wave -into csr0  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[0].csrfile /mtvec_q}} 
            add_wave -into csr0  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[0].csrfile /mstatus_q}} 
            add_wave -into csr0  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[0].csrfile /mip_q}} 
            add_wave -into csr0  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[0].csrfile /mie_q}} 

    add_wave_group -into csr csr1
            add_wave -into csr1  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[1].csrfile /mvu_irq_i}}
            add_wave -into csr1  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[1].csrfile /mcause_q}} 
            add_wave -into csr1  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[1].csrfile /mvu_start}}
            add_wave -into csr1  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[1].csrfile /csr_mvucommand}}
            add_wave -into csr1 {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[1].csrfile /csr_mvuprecision}}
            add_wave -into csr1 {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[1].csrfile /csr_op}}
    add_wave_group -into csr csr2
            add_wave -into csr2  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[2].csrfile /mvu_irq_i}}
            add_wave -into csr2  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[2].csrfile /mcause_q}} 
            add_wave -into csr2  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[2].csrfile /mvu_start}}
            add_wave -into csr2  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[2].csrfile /csr_mvucommand}}
            add_wave -into csr2 {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[2].csrfile /csr_mvuprecision}}
            add_wave -into csr2 {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[2].csrfile /csr_op}}
    add_wave_group -into csr csr3
            add_wave -into csr3  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[3].csrfile /mvu_irq_i}}
            add_wave -into csr3  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[3].csrfile /mcause_q}} 
            add_wave -into csr3  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[3].csrfile /mvu_start}}
            add_wave -into csr3  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[3].csrfile /csr_mvucommand}}
            add_wave -into csr3 {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[3].csrfile /csr_mvuprecision}}
            add_wave -into csr3 {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[3].csrfile /csr_op}}
    add_wave_group -into csr csr4
            add_wave -into csr4  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[4].csrfile /mvu_irq_i}}
            add_wave -into csr4  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[4].csrfile /mcause_q}} 
            add_wave -into csr4  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[4].csrfile /mvu_start}}
            add_wave -into csr4  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[4].csrfile /csr_mvucommand}}
            add_wave -into csr4 {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[4].csrfile /csr_mvuprecision}}
            add_wave -into csr4 {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[4].csrfile /csr_op}}
    add_wave_group -into csr csr5
            add_wave -into csr5  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[5].csrfile /mvu_irq_i}}
            add_wave -into csr5  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[5].csrfile /mcause_q}} 
            add_wave -into csr5  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[5].csrfile /mvu_start}}
            add_wave -into csr5  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[5].csrfile /csr_mvucommand}}
            add_wave -into csr5 {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[5].csrfile /csr_mvuprecision}}
            add_wave -into csr5 {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[5].csrfile /csr_op}}
    add_wave_group -into csr csr6
            add_wave -into csr6 {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[6].csrfile /mvu_irq_i}}
            add_wave -into csr6  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[6].csrfile /mcause_q}} 
            add_wave -into csr6 {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[6].csrfile /mvu_start}}
            add_wave -into csr6 {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[6].csrfile /csr_mvucommand}}
            add_wave -into csr6 {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[6].csrfile /csr_mvuprecision}}
            add_wave -into csr6 {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[6].csrfile /csr_op}}
    add_wave_group -into csr csr7
            add_wave -into csr7 {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[7].csrfile /mvu_irq_i}}
            add_wave -into csr7  {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[7].csrfile /mcause_q}} 
            add_wave -into csr7 {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[7].csrfile /mvu_start}}
            add_wave -into csr7 {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[7].csrfile /csr_mvucommand}}
            add_wave -into csr7 {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[7].csrfile /csr_mvuprecision}}
            add_wave -into csr7 {{/testbench_top/barvinn_inst/pito_rv32_core/csr/\genblk1[7].csrfile /csr_op}}


add_wave_group mems
    add_wave_group -into mems i_mem
        add_wave -into i_mem {{/testbench_top/barvinn_inst/pito_rv32_core/i_mem/clock}}
        add_wave -into i_mem {{/testbench_top/barvinn_inst/pito_rv32_core/i_mem/data}}
        add_wave -into i_mem {{/testbench_top/barvinn_inst/pito_rv32_core/i_mem/rdaddress}}
        add_wave -into i_mem {{/testbench_top/barvinn_inst/pito_rv32_core/i_mem/wraddress}}
        add_wave -into i_mem {{/testbench_top/barvinn_inst/pito_rv32_core/i_mem/wren}}
        add_wave -into i_mem {{/testbench_top/barvinn_inst/pito_rv32_core/i_mem/q}}
        # add_wave -into i_mem {{core/i_mem/bram_32Kb_inst/inst/\native_mem_module.blk_mem_gen_v8_4_3_inst /memory}}
        # add_wave -into i_mem {{/testbench_top/barvinn_inst/pito_rv32_core/i_mem/altsyncram_component/mem_data}}
    add_wave_group -into mems d_mem
        add_wave -into d_mem {{/testbench_top/barvinn_inst/pito_rv32_core/d_mem/clock}}
        add_wave -into d_mem {{/testbench_top/barvinn_inst/pito_rv32_core/d_mem/data}}
        add_wave -into d_mem {{/testbench_top/barvinn_inst/pito_rv32_core/d_mem/rdaddress}}
        add_wave -into d_mem {{/testbench_top/barvinn_inst/pito_rv32_core/d_mem/wraddress}}
        add_wave -into d_mem {{/testbench_top/barvinn_inst/pito_rv32_core/d_mem/wren}}
        add_wave -into d_mem {{/testbench_top/barvinn_inst/pito_rv32_core/d_mem/q}}
        # add_wave -into d_mem {{core/d_mem/bram_32Kb_inst/inst/\native_mem_module.blk_mem_gen_v8_4_3_inst /memory}}
        # add_wave -into d_mem {{/testbench_top/barvinn_inst/pito_rv32_core/d_mem/altsyncram_component/mem_data}}

