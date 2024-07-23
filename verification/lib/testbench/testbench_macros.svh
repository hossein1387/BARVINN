//================================================================
// hard coded HDL paths for verification 
//================================================================
`define hdl_path_soc_top   testbench_top.barvinn_inst.soc
`define hdl_path_top       `hdl_path_soc_top.pito
`define hdl_path_regf      `hdl_path_top.regfile.genblk1
`define hdl_path_regf_0    `hdl_path_regf[0].regfile.data
`define hdl_path_regf_1    `hdl_path_regf[1].regfile.data
`define hdl_path_regf_2    `hdl_path_regf[2].regfile.data
`define hdl_path_regf_3    `hdl_path_regf[3].regfile.data
`define hdl_path_regf_4    `hdl_path_regf[4].regfile.data
`define hdl_path_regf_5    `hdl_path_regf[5].regfile.data
`define hdl_path_regf_6    `hdl_path_regf[6].regfile.data
`define hdl_path_regf_7    `hdl_path_regf[7].regfile.data
`define hdl_path_csrf      `hdl_path_top.csr.genblk1
`define hdl_path_csrf_0    `hdl_path_csrf[0].csrfile
`define hdl_path_csrf_1    `hdl_path_csrf[1].csrfile
`define hdl_path_csrf_2    `hdl_path_csrf[2].csrfile
`define hdl_path_csrf_3    `hdl_path_csrf[3].csrfile
`define hdl_path_csrf_4    `hdl_path_csrf[4].csrfile
`define hdl_path_csrf_5    `hdl_path_csrf[5].csrfile
`define hdl_path_csrf_6    `hdl_path_csrf[6].csrfile
`define hdl_path_csrf_7    `hdl_path_csrf[7].csrfile
`define hdl_path_dmem      `hdl_path_soc_top.d_mem.ram.sram
`define hdl_path_dmem_init `hdl_path_soc_top.d_mem.ram.init_val
`define hdl_path_imem      `hdl_path_soc_top.i_mem.ram.sram
`define hdl_path_imem_init `hdl_path_soc_top.i_mem.ram.init_val

// THE FOLLOWING DOES NOT WORK :(
//`define hdl_path_mvu0_mem_fcn(mvu, bank)  `hdl_path_mvu0_mem[mvu].mvunit.bankarray[bank].`hdl_path_mvu0_mem_cell

// `define hdl_path_mvu0_mem testbench_top.barvinn_inst.mvu.mvuarray[0].mvunit.bankarray[1].db.b.inst.native_mem_module.blk_mem_gen_v8_4_3_inst.memory
`define hdl_path_mvu_top           testbench_top.barvinn_inst.mvu
`define hdl_path_mvu_data_mem(mvu_num) `hdl_path_mvu_top.mvu.mvuarray[mvu_num]
`define hdl_path_mvu_data_mem_bank(mvu_num, bank) `hdl_path_mvu_data_mem(mvu_num).mvuunit.bankarray[bank]
`define hdl_path_mvu_data_mem_bank_ram(mvu_num, bank) `hdl_path_mvu_data_mem_bank(mvu_num, bank).db.data_ram.mem