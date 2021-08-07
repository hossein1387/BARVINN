`timescale 1ns/1ps

`include "rv32_defines.svh"
`include "pito_inf.svh"
`include "mvu_inf.svh"
`include "barvinn_intf.sv"

import mvu_pkg::*;
import rv32_pkg::*;

module barvinn #(
)(

    //=======================================
    //          PITO Interface
    //=======================================
    pito_interface pito_intf,
    //=======================================
    //          MVU Interface
    //=======================================
    mvu_interface  mvu_intf,
    //=======================================
    //          Accelerator Interface
    //=======================================
    barvinn_interface barvinn_intf
);
    localparam MVU_MAX_DATA_PREC      = 16;  // Maximum supported data length in MVU

    // mvu done signal, not used for now
    logic [        NMVU-1  : 0] mvu_done        ; // mvu output done signal
    assign mvu_done = mvu_intf.done;

    // connecting global reset
    assign mvu_intf.rst_n          = barvinn_intf.rst_n;
    assign pito_intf.pito_io_rst_n = barvinn_intf.rst_n;

    assign mvu_intf.ic_clr        = barvinn_intf.rst_n;
    // assign mvu_ic_recv_from  = 0;

genvar mvu_cnt;
generate 
   for (mvu_cnt = 0; mvu_cnt < NMVU; mvu_cnt++)  begin
        // Let's first stitch mvu and pito together:
        assign mvu_intf.start[mvu_cnt]                            = pito_intf.mvu_start[mvu_cnt];
        assign mvu_intf.mul_mode[mvu_cnt*2 +: 2]                  = pito_intf.csr_mvucommand[(mvu_cnt*32 + 30) +: 2];
        assign mvu_intf.d_signed[mvu_cnt]                         = pito_intf.csr_mvuprecision[mvu_cnt*32 + 25];
        assign mvu_intf.w_signed[mvu_cnt]                         = pito_intf.csr_mvuprecision[mvu_cnt*32 + 24];
        assign mvu_intf.shacc_clr[mvu_cnt]                        = ~pito_intf.pito_io_rst_n;
        assign mvu_intf.max_en[mvu_cnt]                           = pito_intf.csr_mvucommand[mvu_cnt*32 + 29];
        assign mvu_intf.max_clr[mvu_cnt]                          = 0;
        assign mvu_intf.max_pool[mvu_cnt]                         = 0;
        assign mvu_intf.quant_clr[mvu_cnt]                        = 0;
        assign mvu_intf.quant_msbidx[mvu_cnt*BQMSBIDX +: BQMSBIDX]= pito_intf.csr_mvuquant[(mvu_cnt*32) +: BQMSBIDX];
        assign mvu_intf.countdown[mvu_cnt*BCNTDWN +: BCNTDWN]     = pito_intf.csr_mvucommand[ mvu_cnt*32 +: BCNTDWN];
        assign mvu_intf.wprecision[mvu_cnt*BPREC +: BPREC]        = pito_intf.csr_mvuprecision[mvu_cnt*32 +: BPREC];
        assign mvu_intf.iprecision[mvu_cnt*BPREC +: BPREC]        = pito_intf.csr_mvuprecision[(mvu_cnt*32+BPREC) +: BPREC];
        assign mvu_intf.oprecision[mvu_cnt*BPREC +: BPREC]        = pito_intf.csr_mvuprecision[(mvu_cnt*32+2*BPREC) +: BPREC];
        assign mvu_intf.wbaseaddr[mvu_cnt*BBWADDR +: BBWADDR]     = pito_intf.csr_mvuwbaseptr[mvu_cnt*32 +: BBWADDR];
        assign mvu_intf.ibaseaddr[mvu_cnt*BBDADDR +: BBDADDR]     = pito_intf.csr_mvuibaseptr[mvu_cnt*32 +: BBDADDR];
        assign mvu_intf.obaseaddr[mvu_cnt*BBDADDR +: BBDADDR]     = pito_intf.csr_mvuobaseptr[mvu_cnt*32 +: BBDADDR];
        assign mvu_intf.omvusel[mvu_cnt]                          = 8'b00000001; //-> error, should be like omvusel[mvu_cnt*8 +: 8]
        assign mvu_intf.wjump[mvu_cnt][0]                         = pito_intf.csr_mvuwjump_0[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.wjump[mvu_cnt][1]                         = pito_intf.csr_mvuwjump_1[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.wjump[mvu_cnt][2]                         = pito_intf.csr_mvuwjump_2[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.wjump[mvu_cnt][3]                         = pito_intf.csr_mvuwjump_3[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.wjump[mvu_cnt][4]                         = pito_intf.csr_mvuwjump_4[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.ijump[mvu_cnt][0]                         = pito_intf.csr_mvuijump_0[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.ijump[mvu_cnt][1]                         = pito_intf.csr_mvuijump_1[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.ijump[mvu_cnt][2]                         = pito_intf.csr_mvuijump_2[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.ijump[mvu_cnt][3]                         = pito_intf.csr_mvuijump_3[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.ijump[mvu_cnt][4]                         = pito_intf.csr_mvuijump_4[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.ojump[mvu_cnt][0]                         = pito_intf.csr_mvuojump_0[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.ojump[mvu_cnt][1]                         = pito_intf.csr_mvuojump_1[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.ojump[mvu_cnt][2]                         = pito_intf.csr_mvuojump_2[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.ojump[mvu_cnt][3]                         = pito_intf.csr_mvuojump_3[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.ojump[mvu_cnt][4]                         = pito_intf.csr_mvuojump_4[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.wlength[mvu_cnt][1]                       = pito_intf.csr_mvuwlength_1[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.wlength[mvu_cnt][2]                       = pito_intf.csr_mvuwlength_2[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.wlength[mvu_cnt][3]                       = pito_intf.csr_mvuwlength_3[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.wlength[mvu_cnt][4]                       = pito_intf.csr_mvuwlength_4[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.ilength[mvu_cnt][1]                       = pito_intf.csr_mvuilength_1[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.ilength[mvu_cnt][2]                       = pito_intf.csr_mvuilength_2[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.ilength[mvu_cnt][3]                       = pito_intf.csr_mvuilength_3[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.ilength[mvu_cnt][4]                       = pito_intf.csr_mvuilength_4[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.olength[mvu_cnt][1]                       = pito_intf.csr_mvuolength_1[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.olength[mvu_cnt][2]                       = pito_intf.csr_mvuolength_2[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.olength[mvu_cnt][3]                       = pito_intf.csr_mvuolength_3[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.olength[mvu_cnt][4]                       = pito_intf.csr_mvuolength_4[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.scaler_b[mvu_cnt*BSCALERB +: BSCALERB]    = 16'h01;
        assign mvu_intf.shacc_load_sel[mvu_cnt]                   = 5'b00001;//{NJUMPS{1'b1}}; // they have to be CSR to support GEMV and Conv
        assign mvu_intf.zigzag_step_sel[mvu_cnt]                  = 5'b00011;//{NJUMPS{1'b1}}; // they have to be CSR to support GEMV and Conv

        assign pito_intf.mvu_irq_i[mvu_cnt]                       = mvu_intf.irq[mvu_cnt];

   end
endgenerate

        // Now we need to connect barvinn to mvu 
        assign mvu_intf.irq      = barvinn_intf.mvu_irq_tap;
        assign mvu_intf.wrw_addr = barvinn_intf.mvu_wrw_addr;
        assign mvu_intf.wrw_word = barvinn_intf.mvu_wrw_word;
        assign mvu_intf.wrw_en   = barvinn_intf.mvu_wrw_en;
        assign mvu_intf.rdc_en   = barvinn_intf.mvu_rdc_en;
        assign mvu_intf.rdc_grnt = barvinn_intf.mvu_rdc_grnt;
        assign mvu_intf.rdc_addr = barvinn_intf.mvu_rdc_addr;
        assign mvu_intf.rdc_word = barvinn_intf.mvu_rdc_word;
        assign mvu_intf.wrc_en   = barvinn_intf.mvu_wrc_en;   // Data memory: controller write enable
        assign barvinn_intf.mvu_wrc_grnt = mvu_intf.wrc_grnt; // Data memory: controller write grant

    //=======================================
    //          PITO Interface
    //=======================================
    assign pito_intf.pito_io_imem_addr = barvinn_intf.pito_io_imem_addr;
    assign pito_intf.pito_io_imem_data = barvinn_intf.pito_io_imem_data;
    assign pito_intf.pito_io_dmem_addr = barvinn_intf.pito_io_dmem_addr;
    assign pito_intf.pito_io_dmem_data = barvinn_intf.pito_io_dmem_data;
    assign pito_intf.pito_io_imem_w_en = barvinn_intf.pito_io_imem_w_en;
    assign pito_intf.pito_io_dmem_w_en = barvinn_intf.pito_io_dmem_w_en;
    assign pito_intf.pito_io_program = barvinn_intf.pito_io_program;

    //=======================================
    //          MVU Interface
    //=======================================
        assign mvu_intf.wrc_addr = barvinn_intf.mvu_wrc_addr; // Data memory: controller write address
        assign mvu_intf.wrc_word = barvinn_intf.mvu_wrc_word; // Data memory: controller write word
    // Data Transposer: 
    generate
        for(mvu_cnt=0; mvu_cnt < NMVU; mvu_cnt++) begin
            data_transposer #(
                .NUM_WORDS    (N),         // Number of words needed before transpose 
                .XLEN         (`XPR_LEN),      // Length of each input word
                .MVU_ADDR_LEN (BDBANKA),   // MVU address length
                .MVU_DATA_LEN (BDBANKW),   // MVU data length
                .MAX_DATA_PREC(MVU_MAX_DATA_PREC)     // MAX data precision
            )
            data_transposer_inst(
                   .clk         (barvinn_intf.clk                                         ), // Clock
                   .rst_n       (barvinn_intf.rst_n                                       ), // Asynchronous reset active low
                   .prec        (barvinn_intf.mvu_data_prec[mvu_cnt*32 +: 32]             ), // Number of bits for each word
                   .baddr       (barvinn_intf.mvu_data_baddr[mvu_cnt*32 +: 32]            ), // Base address for writing the words
                   .iword       (barvinn_intf.mvu_data_iword[mvu_cnt*`XPR_LEN +: `XPR_LEN]), // Base address for writing the words
                   .start       (barvinn_intf.mvu_data_start[mvu_cnt]                     ), // Start signal to indicate first word to be transposed
                   .busy        (barvinn_intf.mvu_data_busy[mvu_cnt]                      ), // A signal to indicate the status of the module
                   .mvu_wr_en   (barvinn_intf.mvu_wrc_en[mvu_cnt]                         ), // MVU write enable to input RAM
                   .mvu_wr_addr (barvinn_intf.mvu_wrc_addr                                ), // MVU write address to input RAM
                   .mvu_wr_word (barvinn_intf.mvu_wrc_word                                )  // MVU write data to input RAM
            );
        end
    endgenerate

    mvutop mvu(mvu_intf);

    rv32_core pito_rv32_core(pito_intf);

always @(posedge mvu_intf.irq[0]) begin
    $display($sformatf("IRQ is sent!, S0=%0d, SP=%0d", testbench_top.barvinn_inst.pito_rv32_core.regfile.genblk1[0].regfile.data[8], testbench_top.barvinn_inst.pito_rv32_core.regfile.genblk1[0].regfile.data[2]));
end

endmodule