
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

    assign mvu_clk   = clk;
    assign mvu_rst_n = rst_n;

    assign mvu_ic_clr        = ~rst_n;
    // assign mvu_ic_recv_from  = 0;
    assign mvu_max_clr       = 0;
    assign mvu_max_pool      = 0;
    assign mvu_quant_clr     = 0;

genvar mvu_cnt;
generate 
   for (mvu_cnt = 0; mvu_cnt < NMVU; mvu_cnt++)  begin
        assign mvu_intf.mvu_wbaseaddr[mvu_cnt*BBWADDR +: BBWADDR]     = rv_intf.csr_mvu_wbaseaddr[mvu_cnt*32 +: BBWADDR];
        assign mvu_intf.mvu_ibaseaddr[mvu_cnt*BBDADDR +: BBDADDR]     = rv_intf.csr_mvu_ibaseaddr[mvu_cnt*32 +: BBDADDR];
        assign mvu_intf.mvu_obaseaddr[mvu_cnt*BBDADDR +: BBDADDR]     = rv_intf.csr_mvu_obaseaddr[mvu_cnt*32 +: BBDADDR];
        assign mvu_intf.mvu_wstride_0[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_wstride_0[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.mvu_wstride_1[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_wstride_1[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.mvu_wstride_2[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_wstride_2[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.mvu_wstride_3[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_wstride_3[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.mvu_istride_0[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_istride_0[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.mvu_istride_1[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_istride_1[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.mvu_istride_2[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_istride_2[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.mvu_istride_3[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_istride_3[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.mvu_ostride_0[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_ostride_0[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.mvu_ostride_1[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_ostride_1[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.mvu_ostride_2[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_ostride_2[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.mvu_ostride_3[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_ostride_3[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.mvu_wlength_0[mvu_cnt*BLENGTH +: BLENGTH]     = rv_intf.csr_mvu_wlength_0[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.mvu_wlength_1[mvu_cnt*BLENGTH +: BLENGTH]     = rv_intf.csr_mvu_wlength_1[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.mvu_wlength_2[mvu_cnt*BLENGTH +: BLENGTH]     = rv_intf.csr_mvu_wlength_2[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.mvu_wlength_3[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_wlength_3[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.mvu_ilength_0[mvu_cnt*BLENGTH +: BLENGTH]     = rv_intf.csr_mvu_ilength_0[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.mvu_ilength_1[mvu_cnt*BLENGTH +: BLENGTH]     = rv_intf.csr_mvu_ilength_1[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.mvu_ilength_2[mvu_cnt*BLENGTH +: BLENGTH]     = rv_intf.csr_mvu_ilength_2[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.mvu_ilength_3[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_ilength_3[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.mvu_olength_0[mvu_cnt*BLENGTH +: BLENGTH]     = rv_intf.csr_mvu_olength_0[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.mvu_olength_1[mvu_cnt*BLENGTH +: BLENGTH]     = rv_intf.csr_mvu_olength_1[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.mvu_olength_2[mvu_cnt*BLENGTH +: BLENGTH]     = rv_intf.csr_mvu_olength_2[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.mvu_olength_3[mvu_cnt*BSTRIDE +: BSTRIDE]     = rv_intf.csr_mvu_olength_3[mvu_cnt*32 +: BSTRIDE];
        assign mvu_intf.mvu_wprecision[mvu_cnt*BPREC +: BPREC]        = rv_intf.csr_mvu_precision[mvu_cnt*32 +: BPREC];
        assign mvu_intf.mvu_iprecision[mvu_cnt*BPREC +: BPREC]        = rv_intf.csr_mvu_precision[(mvu_cnt*32+BPREC) +: BPREC];
        assign mvu_intf.mvu_oprecision[mvu_cnt*BPREC +: BPREC]        = rv_intf.csr_mvu_precision[(mvu_cnt*32+2*BPREC) +: BPREC];
        assign mvu_intf.mvu_w_signed[mvu_cnt]                         = rv_intf.csr_mvu_precision[mvu_cnt*32 + 24];
        assign mvu_intf.mvu_i_signed[mvu_cnt]                         = rv_intf.csr_mvu_precision[mvu_cnt*32 + 25];
        assign mvu_intf.mvu_d_signed[mvu_cnt]                         = rv_intf.csr_mvu_precision[mvu_cnt*32 + 25];
        assign mvu_intf.mvu_shacc_clr[mvu_cnt]                        = ~rv_intf.rst_n;
        assign mvu_intf.mvu_mul_mode[mvu_cnt*2 +: 2]                  = rv_intf.csr_mvu_command[(mvu_cnt*32 + 30) +: 2];
        assign mvu_intf.mvu_max_en[mvu_cnt]                           = rv_intf.csr_mvu_command[mvu_cnt*32 + 29];
        assign mvu_intf.mvu_countdown[mvu_cnt*BCNTDWN +: BCNTDWN]     = rv_intf.csr_mvu_command[ mvu_cnt*32 +: BCNTDWN];
        assign mvu_intf.mvu_quant_msbidx[mvu_cnt*BQMSBIDX +: BQMSBIDX]= rv_intf.csr_mvu_quant[(mvu_cnt*32) +: BQMSBIDX];
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
                .NUM_WORDS    (N),   // Number of words needed before transpose 
                .XLEN         (XLEN),   // Length of each input word
                .MVU_ADDR_LEN (BDBANKA),   // MVU address length
                .MVU_DATA_LEN (BDBANKW),   // MVU data length
                .MAX_DATA_PREC(MVU_MAX_DATA_PREC)     // MAX data precision
            )
            data_transposer_inst(
                   .clk         (clk                                      ), // Clock
                   .rst_n       (rst_n                                    ), // Asynchronous reset active low
                   .prec        (mvu_data_prec[mvu_cnt*32 +: 32]          ), // Number of bits for each word
                   .baddr       (mvu_data_baddr[mvu_cnt*32 +: 32]         ), // Base address for writing the words
                   .iword       (mvu_data_iword[mvu_cnt*XLEN +: XLEN]     ), // Base address for writing the words
                   .start       (mvu_data_start[mvu_cnt]                  ), // Start signal to indicate first word to be transposed
                   .busy        (mvu_data_busy[mvu_cnt]                   ), // A signal to indicate the status of the module
                   .mvu_wr_en   (mvu_wrc_en[mvu_cnt]                      ), // MVU write enable to input RAM
                   .mvu_wr_addr (mvu_wrc_addr[mvu_cnt*BDBANKA +: BDBANKA] ), // MVU write address to input RAM
                   .mvu_wr_word (mvu_wrc_word[mvu_cnt*BDBANKW +: BDBANKW] )  // MVU write data to input RAM
            );
        end
    endgenerate

    // assign mvu_scaler_clr = ~rst_n;
    assign mvu_scaler_b  = 'h1;

    mvutop mvu(mvu_intf);
    logic pito_clk;
    logic pito_rst_n;

    assign pito_clk    = clk;
    assign pito_rst_n  = rst_n;
    assign mvu_irq_tap = mvu_intf.irq;

    rv32_core pito_rv32_core(rv_intf);

always @(posedge mvu_intf.irq[0]) begin
    $display("IRQ is sent!");
end

endmodule