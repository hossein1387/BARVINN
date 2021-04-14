`timescale 1ns/1ps
import mvu_pkg::*;
import rv32_pkg::*;

module accelerator #(
)(

    //=======================================
    //          PITO Interface
    //=======================================
    pito_interface rv_intf,
    //=======================================
    //          MVU Interface
    //=======================================
    mvu_interface  mvu_intf,
    //=======================================
    //          Accelerator Interface
    //=======================================
    accel_interface accel_inf
);
    localparam MVU_MAX_DATA_PREC      = 16;  // Maximum supported data length in MVU

    assign mvu_intf.ic_clr        = ~mvu_intf.rst_n;
    // assign mvu_ic_recv_from  = 0;
    assign mvu_intf.max_clr       = 0;
    assign mvu_intf.max_pool      = 0;
    assign mvu_intf.quant_clr     = 0;

genvar mvu_cnt;
generate 
   for (mvu_cnt = 0; mvu_cnt < NMVU; mvu_cnt++)  begin
        assign mvu_intf.wbaseaddr[mvu_cnt*BBWADDR +: BBWADDR]     = rv_intf.csr_mvu_wbaseaddr[mvu_cnt*32 +: BBWADDR];
        assign mvu_intf.ibaseaddr[mvu_cnt*BBDADDR +: BBDADDR]     = rv_intf.csr_mvu_ibaseaddr[mvu_cnt*32 +: BBDADDR];
        assign mvu_intf.obaseaddr[mvu_cnt*BBDADDR +: BBDADDR]     = rv_intf.csr_mvu_obaseaddr[mvu_cnt*32 +: BBDADDR];
        assign mvu_intf.wstride_0[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_wstride_0[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.wstride_1[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_wstride_1[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.wstride_2[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_wstride_2[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.wstride_3[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_wstride_3[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.istride_0[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_istride_0[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.istride_1[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_istride_1[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.istride_2[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_istride_2[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.istride_3[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_istride_3[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.ostride_0[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_ostride_0[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.ostride_1[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_ostride_1[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.ostride_2[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_ostride_2[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.ostride_3[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_ostride_3[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.wlength_0[mvu_cnt*BLENGTH +: BLENGTH]     = rv_intf.csr_mvu_wlength_0[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.wlength_1[mvu_cnt*BLENGTH +: BLENGTH]     = rv_intf.csr_mvu_wlength_1[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.wlength_2[mvu_cnt*BLENGTH +: BLENGTH]     = rv_intf.csr_mvu_wlength_2[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.wlength_3[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_wlength_3[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.ilength_0[mvu_cnt*BLENGTH +: BLENGTH]     = rv_intf.csr_mvu_ilength_0[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.ilength_1[mvu_cnt*BLENGTH +: BLENGTH]     = rv_intf.csr_mvu_ilength_1[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.ilength_2[mvu_cnt*BLENGTH +: BLENGTH]     = rv_intf.csr_mvu_ilength_2[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.ilength_3[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_ilength_3[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.olength_0[mvu_cnt*BLENGTH +: BLENGTH]     = rv_intf.csr_mvu_olength_0[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.olength_1[mvu_cnt*BLENGTH +: BLENGTH]     = rv_intf.csr_mvu_olength_1[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.olength_2[mvu_cnt*BLENGTH +: BLENGTH]     = rv_intf.csr_mvu_olength_2[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.olength_3[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_olength_3[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.wprecision[mvu_cnt*BPREC +: BPREC]        = rv_intf.csr_mvu_precision[mvu_cnt*32 +: BPREC];
        assign mvu_intf.iprecision[mvu_cnt*BPREC +: BPREC]        = rv_intf.csr_mvu_precision[(mvu_cnt*32+BPREC) +: BPREC];
        assign mvu_intf.oprecision[mvu_cnt*BPREC +: BPREC]        = rv_intf.csr_mvu_precision[(mvu_cnt*32+2*BPREC) +: BPREC];
        assign mvu_intf.w_signed[mvu_cnt]                         = rv_intf.csr_mvu_precision[mvu_cnt*32 + 24];
        // assign mvu_intf.i_signed[mvu_cnt]                         = rv_intf.csr_mvu_precision[mvu_cnt*32 + 25];
        assign mvu_intf.d_signed[mvu_cnt]                         = rv_intf.csr_mvu_precision[mvu_cnt*32 + 25];
        assign mvu_intf.shacc_clr[mvu_cnt]                        = ~rv_intf.pito_io_rst_n;
        assign mvu_intf.mul_mode[mvu_cnt*2 +: 2]                  = rv_intf.csr_mvu_command[(mvu_cnt*32 + 30) +: 2];
        assign mvu_intf.max_en[mvu_cnt]                           = rv_intf.csr_mvu_command[mvu_cnt*32 + 29];
        assign mvu_intf.countdown[mvu_cnt*BCNTDWN +: BCNTDWN]     = rv_intf.csr_mvu_command[ mvu_cnt*32 +: BCNTDWN];
        assign mvu_intf.quant_msbidx[mvu_cnt*BQMSBIDX +: BQMSBIDX]= rv_intf.csr_mvu_quant[(mvu_cnt*32) +: BQMSBIDX];
        // assign mvu_status  = {31{1'b0}, mvu_status}       ;

   end
endgenerate

    //=======================================
    //          MVU Interface
    //=======================================
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
                   .clk         (accel_inf.clk                                          ), // Clock
                   .rst_n       (accel_inf.rst_n                                        ), // Asynchronous reset active low
                   .prec        (accel_inf.mvu_data_prec[mvu_cnt*32 +: 32]              ), // Number of bits for each word
                   .baddr       (accel_inf.mvu_data_baddr[mvu_cnt*32 +: 32]             ), // Base address for writing the words
                   .iword       (accel_inf.mvu_data_iword[mvu_cnt*`XPR_LEN +: `XPR_LEN] ), // Base address for writing the words
                   .start       (accel_inf.mvu_data_start[mvu_cnt]                      ), // Start signal to indicate first word to be transposed
                   .busy        (accel_inf.mvu_data_busy[mvu_cnt]                       ), // A signal to indicate the status of the module
                   .mvu_wr_en   (mvu_intf.wrc_en[mvu_cnt]                               ), // MVU write enable to input RAM
                   .mvu_wr_addr (mvu_intf.wrc_addr[mvu_cnt*BDBANKA +: BDBANKA]          ), // MVU write address to input RAM
                   .mvu_wr_word (mvu_intf.wrc_word[mvu_cnt*BDBANKW +: BDBANKW]          )  // MVU write data to input RAM
            );
        end
    endgenerate

    // assign mvu_scaler_clr = ~rst_n;
    assign mvu_intf.scaler_b  = 'h1;

    mvutop mvu(mvu_intf);
    logic pito_clk;
    logic pito_rst_n;

    rv32_core pito_rv32_core(rv_intf);

always @(posedge mvu_intf.irq[0]) begin
    $display("IRQ is sent!");
end

endmodule