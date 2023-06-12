`timescale 1ns/1ps

`include "rv32_defines.svh"

import mvu_pkg::*;
import rv32_pkg::*;

module barvinn #(
)(
    pito_soc_ext_interface pito_ext_intf,
    MVU_EXT_INTERFACE      mvu_ext_intf
);
    localparam MVU_MAX_DATA_PREC      = 16;  // Maximum supported data length in MVU

    // // mvu done signal, not used for now
    // logic [        NMVU-1  : 0] mvu_done; // mvu output done signal
    // assign mvu_done = mvu_ext_intf.done;

    // connecting global reset
    assign mvu_ext_intf.rst_n = pito_ext_intf.rst_n;

    genvar mvu_cnt;
    generate 
    for (mvu_cnt = 0; mvu_cnt < NMVU; mvu_cnt++)  begin
            assign pito_ext_intf.mvu_irq[mvu_cnt] = mvu_ext_intf.irq[mvu_cnt];
    end
    endgenerate



    

    //=======================================
    //          MVU Interface
    //=======================================
    // Data Transposer:  
    // generate
    //     for(mvu_cnt=0; mvu_cnt < NMVU; mvu_cnt++) begin
    //         data_transposer #(
    //             .NUM_WORDS    (N),         // Number of words needed before transpose 
    //             .XLEN         (`XPR_LEN),  // Length of each input word
    //             .MVU_ADDR_LEN (BDBANKA),   // MVU address length
    //             .MVU_DATA_LEN (BDBANKW),   // MVU data length
    //             .MAX_DATA_PREC(MVU_MAX_DATA_PREC)     // MAX data precision
    //         )
    //         data_transposer_inst(
    //                .clk         (mvu_ext_intf.clk                                         ), // Clock
    //                .rst_n       (mvu_ext_intf.rst_n                                       ), // Asynchronous reset active low
    //                .prec        (mvu_ext_intf.mvu_data_prec[mvu_cnt*32 +: 32]             ), // Number of bits for each word
    //                .baddr       (mvu_ext_intf.data_baddr[mvu_cnt*32 +: 32]            ), // Base address for writing the words
    //                .iword       (mvu_ext_intf.data_iword[mvu_cnt*`XPR_LEN +: `XPR_LEN]), // Base address for writing the words
    //                .start       (mvu_ext_intf.data_start[mvu_cnt]                     ), // Start signal to indicate first word to be transposed
    //                .busy        (mvu_ext_intf.data_busy[mvu_cnt]                      ), // A signal to indicate the status of the module
    //                .mvu_wr_en   (mvu_ext_intf.wrc_en[mvu_cnt]                         ), // MVU write enable to input RAM
    //                .mvu_wr_addr (mvu_ext_intf.wrc_addr                                ), // MVU write address to input RAM
    //                .mvu_wr_word (mvu_ext_intf.wrc_word                                )  // MVU write data to input RAM
    //         );
    //     end
    // endgenerate

    // Bindings:
    APB #(
        .ADDR_WIDTH(pito_pkg::APB_ADDR_WIDTH), 
        .DATA_WIDTH(pito_pkg::APB_DATA_WIDTH)
    ) apb_interface();

    mvutop_wrapper mvu(.mvu_ext_if(mvu_ext_intf),
                       .apb(apb_interface.Slave));
    pito_soc soc(
        .sys_clk_i   (sys_clk_i  ),
        .sys_rst_n_i (sys_rst_n_i),
        .mvu_irq_i   (mvu_irq_i),
        .uart_rx_i   (uart_rx_i),
        .uart_tx_o   (uart_tx_i),
        .m_axi       ( ),
        .mvu_apb     ( )
    );

endmodule