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

`define hdl_path_mvu0_mem    testbench_top.barvinn_inst.mvu.mvu.mvuarray
`define hdl_path_mvu0_mem_cell db.b.inst.native_mem_module.blk_mem_gen_v8_4_4_inst.memory
`define hdl_path_mvu0_mem_0  `hdl_path_mvu0_mem[0].mvunit.bankarray[0 ].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_1  `hdl_path_mvu0_mem[0].mvunit.bankarray[1 ].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_2  `hdl_path_mvu0_mem[0].mvunit.bankarray[2 ].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_3  `hdl_path_mvu0_mem[0].mvunit.bankarray[3 ].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_4  `hdl_path_mvu0_mem[0].mvunit.bankarray[4 ].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_5  `hdl_path_mvu0_mem[0].mvunit.bankarray[5 ].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_6  `hdl_path_mvu0_mem[0].mvunit.bankarray[6 ].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_7  `hdl_path_mvu0_mem[0].mvunit.bankarray[7 ].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_8  `hdl_path_mvu0_mem[0].mvunit.bankarray[8 ].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_9  `hdl_path_mvu0_mem[0].mvunit.bankarray[9 ].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_10 `hdl_path_mvu0_mem[0].mvunit.bankarray[10].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_11 `hdl_path_mvu0_mem[0].mvunit.bankarray[11].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_12 `hdl_path_mvu0_mem[0].mvunit.bankarray[12].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_13 `hdl_path_mvu0_mem[0].mvunit.bankarray[13].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_14 `hdl_path_mvu0_mem[0].mvunit.bankarray[14].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_15 `hdl_path_mvu0_mem[0].mvunit.bankarray[15].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_16 `hdl_path_mvu0_mem[0].mvunit.bankarray[16].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_17 `hdl_path_mvu0_mem[0].mvunit.bankarray[17].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_18 `hdl_path_mvu0_mem[0].mvunit.bankarray[18].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_19 `hdl_path_mvu0_mem[0].mvunit.bankarray[19].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_20 `hdl_path_mvu0_mem[0].mvunit.bankarray[20].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_21 `hdl_path_mvu0_mem[0].mvunit.bankarray[21].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_22 `hdl_path_mvu0_mem[0].mvunit.bankarray[22].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_23 `hdl_path_mvu0_mem[0].mvunit.bankarray[23].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_24 `hdl_path_mvu0_mem[0].mvunit.bankarray[24].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_25 `hdl_path_mvu0_mem[0].mvunit.bankarray[25].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_26 `hdl_path_mvu0_mem[0].mvunit.bankarray[26].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_27 `hdl_path_mvu0_mem[0].mvunit.bankarray[27].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_28 `hdl_path_mvu0_mem[0].mvunit.bankarray[28].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_29 `hdl_path_mvu0_mem[0].mvunit.bankarray[29].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_30 `hdl_path_mvu0_mem[0].mvunit.bankarray[30].`hdl_path_mvu0_mem_cell
`define hdl_path_mvu0_mem_31 `hdl_path_mvu0_mem[0].mvunit.bankarray[31].`hdl_path_mvu0_mem_cell
