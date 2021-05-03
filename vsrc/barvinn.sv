`timescale 1ns/1ps
import mvu_pkg::*;
import rv32_pkg::*;

module accelerator #(
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
    accel_interface barvinn_intf
);
    localparam MVU_MAX_DATA_PREC      = 1;  // Maximum supported data length in MVU

    // mvu done signal, not used for now
    logic [        NMVU-1  : 0] mvu_done        ; // mvu output done signal
    assign mvu_done = mvu_intf.done;

    // connecting global reset
    assign mvu_intf.rst_n         = barvinn_intf.rst_n;
    assign mvu_intf.rst_n         = brvinn_intf.rst_n;

    assign mvu_intf.ic_clr        = barvinn_intf.rst_n;
    assign mvu_irq_tap
    // assign mvu_ic_recv_from  = 0;

genvar mvu_cnt;
generate 
   for (mvu_cnt = 0; mvu_cnt < NMVU; mvu_cnt++)  begin
        // Let's first stitch mvu and pito together:
        assign mvu_intf.start[mvu_cnt]                            = pito_intf.mvu_start[mvu_cnt];
        assign mvu_intf.irq[mvu_cnt]                              = pito_intf.mvu_irq_i[mvu_cnt];
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
        assign mvu_intf.omvusel                                   = 8'b00000001;
        assign mvu_intf.wjump[0]                                  = pito_intf.csr_mvuwjump_0[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.wjump[1]                                  = pito_intf.csr_mvuwjump_1[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.wjump[2]                                  = pito_intf.csr_mvuwjump_2[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.wjump[3]                                  = pito_intf.csr_mvuwjump_3[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.wjump[4]                                  = pito_intf.csr_mvuwjump_4[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.ijump[0]                                  = pito_intf.csr_mvuijump_0[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.ijump[1]                                  = pito_intf.csr_mvuijump_1[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.ijump[2]                                  = pito_intf.csr_mvuijump_2[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.ijump[3]                                  = pito_intf.csr_mvuijump_3[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.ijump[4]                                  = pito_intf.csr_mvuijump_4[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.ojump[0]                                  = pito_intf.csr_mvuojump_0[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.ojump[1]                                  = pito_intf.csr_mvuojump_1[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.ojump[2]                                  = pito_intf.csr_mvuojump_2[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.ojump[3]                                  = pito_intf.csr_mvuojump_3[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.ojump[4]                                  = pito_intf.csr_mvuojump_4[mvu_cnt*32 +: BJUMP];
        assign mvu_intf.wlength[1]                                = pito_intf.csr_mvuwlength_1[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.wlength[2]                                = pito_intf.csr_mvuwlength_2[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.wlength[3]                                = pito_intf.csr_mvuwlength_3[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.wlength[4]                                = pito_intf.csr_mvuwlength_4[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.ilength[1]                                = pito_intf.csr_mvuilength_1[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.ilength[2]                                = pito_intf.csr_mvuilength_2[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.ilength[3]                                = pito_intf.csr_mvuilength_3[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.ilength[4]                                = pito_intf.csr_mvuilength_4[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.olength[1]                                = pito_intf.csr_mvuolength_1[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.olength[2]                                = pito_intf.csr_mvuolength_2[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.olength[3]                                = pito_intf.csr_mvuolength_3[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.olength[4]                                = pito_intf.csr_mvuolength_4[mvu_cnt*32 +: BLENGTH];
        assign mvu_intf.scaler_b[mvu_cnt]                         = {BSCALERB{1'b1}};
        assign mvu_intf.shacc_load_sel[mvu_cnt]                   = {NJUMPS{1'b1}}; 
        assign mvu_intf.zigzag_step_sel[mvu_cnt]                  = {NJUMPS{1'b1}}; 

        // Now we need to connect barvinn to mvu 
        assign barvinn_intf.mvu_irq_tap[mvu_cnt]                  = mvu_intf.irq[mvu_cnt];
        assign barvinn_intf.mvu_wrw_addr[mvu_cnt]                 = mvu_intf.wrw_addr[mvu_cnt];
        assign barvinn_intf.mvu_wrw_word[mvu_cnt]                 = mvu_intf.wrw_word[mvu_cnt];
        assign barvinn_intf.mvu_wrw_en[mvu_cnt]                   = mvu_intf.wrw_en[mvu_cnt];
        assign barvinn_intf.mvu_rdc_en[mvu_cnt]                   = mvu_intf.rdc_en[mvu_cnt];
        assign barvinn_intf.mvu_rdc_grnt[mvu_cnt]                   = mvu_intf.rdc_grnt[mvu_cnt];
        assign barvinn_intf.mvu_rdc_addr[mvu_cnt]                   = mvu_intf.rdc_addr[mvu_cnt];
        assign barvinn_intf.mvu_rdc_word[mvu_cnt]                   = mvu_intf.rdc_word[mvu_cnt];
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
                   .clk         (barvinn_intf.clk                                         ), // Clock
                   .rst_n       (barvinn_intf.rst_n                                       ), // Asynchronous reset active low
                   .prec        (barvinn_intf.mvu_data_prec[mvu_cnt*32 +: 32]             ), // Number of bits for each word
                   .baddr       (barvinn_intf.mvu_data_baddr[mvu_cnt*32 +: 32]            ), // Base address for writing the words
                   .iword       (barvinn_intf.mvu_data_iword[mvu_cnt*`XPR_LEN +: `XPR_LEN]), // Base address for writing the words
                   .start       (barvinn_intf.mvu_data_start[mvu_cnt]                     ), // Start signal to indicate first word to be transposed
                   .busy        (barvinn_intf.mvu_data_busy[mvu_cnt]                      ), // A signal to indicate the status of the module
                   .mvu_wr_en   (mvu_intf.wrc_en[mvu_cnt]                                 ), // MVU write enable to input RAM
                   .mvu_wr_addr (mvu_intf.wrc_addr[mvu_cnt*BDBANKA +: BDBANKA]            ), // MVU write address to input RAM
                   .mvu_wr_word (mvu_intf.wrc_word[mvu_cnt*BDBANKW +: BDBANKW]            )  // MVU write data to input RAM
            );
        end
    endgenerate


    mvutop mvu(mvu_intf);

    rv32_core pito_rv32_core(pito_intf);

always @(posedge mvu_intf.irq[0]) begin
    $display("IRQ is sent!");
end

endmodule