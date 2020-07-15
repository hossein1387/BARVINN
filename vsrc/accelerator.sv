module accelerator #(
    parameter  NMVU    =  8,   /* Number of MVUs. Ideally a Power-of-2. */
    parameter  N       = 64,   /* N x N matrix-vector product size. Power-of-2. */
    parameter  NDBANK  = 32,   /* Number of 2N-bit, 512-element Data BANK. */
    parameter  BMVUA   = $clog2(NMVU),  /* Bitwidth of MVU          Address */
    parameter  BWBANKA = 9,             /* Bitwidth of Weights BANK Address */
    parameter  BWBANKW = 4096,          // Bitwidth of Weights BANK Word
    parameter  BDBANKA = 15,            /* Bitwidth of Data    BANK Address */
    parameter  BDBANKW = N,             /* Bitwidth of Data    BANK Word */
    
    // Other Parameters
    parameter  BCNTDWN  = 29,           // Bitwidth of the countdown ports
    parameter  BPREC    = 6,            // Bitwidth of the precision ports
    parameter  BBWADDR  = 9,            // Bitwidth of the weight base address ports
    parameter  BBDADDR  = 15,           // Bitwidth of the data base address ports
    parameter  BSTRIDE  = 15,           // Bitwidth of the stride ports
    parameter  BLENGTH  = 15,           // Bitwidth of the length ports

    parameter  BACC    = 32,            /* Bitwidth of Accumulators */

    // Quantizer parameters
    parameter  BQMSBIDX = $clog2(BACC),     // Bitwidth of the quantizer MSB location specifier
    parameter  BQBOUT   = $clog2(BACC)     // Bitwitdh of the quantizer 
)(
    input logic              io_clk,
    input logic              io_rst_n,  
    input rv32_imem_addr_t   io_imem_addr,
    input rv32_instr_t       io_imem_data,
    input rv32_dmem_addr_t   io_dmem_addr,
    input rv32_data_t        io_dmem_data,
    input logic              io_imem_w_en,
    input logic              io_dmem_w_en,
    input logic              io_pito_program

);

    logic                      mvu_clk          ; // input  clk;
    logic                      mvu_rst_n        ; // input  reset;
    logic [        NMVU-1 : 0] mvu_start        ; // input  start;
    logic [        NMVU-1 : 0] mvu_done         ; // output done;
    logic [        NMVU-1 : 0] mvu_irq          ; // output irq
    logic                      mvu_ic_clr       ; // input  ic_clr;
    logic [  NMVU*BMVUA-1 : 0] mvu_ic_recv_from ; // input  ic_recv_from;
    logic [      2*NMVU-1 : 0] mvu_mul_mode     ; // input  mul_mode;
    logic [        NMVU-1 : 0] mvu_acc_clr      ; // input  acc_clr;
    logic [        NMVU-1 : 0] mvu_max_en       ; // input  max_en;
    logic [        NMVU-1 : 0] mvu_max_clr      ; // input  max_clr;
    logic [        NMVU-1 : 0] mvu_max_pool     ; // input  max_pool;
    logic [        NMVU-1 : 0] mvu_rdc_en       ; // input  rdc_en;
    logic [        NMVU-1 : 0] mvu_rdc_grnt     ; // output rdc_grnt;
    logic [NMVU*BDBANKA-1 : 0] mvu_rdc_addr     ; // input  rdc_addr;
    logic [NMVU*BDBANKW-1 : 0] mvu_rdc_word     ; // output rdc_word;
    logic [        NMVU-1 : 0] mvu_wrc_en       ; // input  wrc_en;
    logic [        NMVU-1 : 0] mvu_wrc_grnt     ; // output wrc_grnt;
    logic [     BDBANKA-1 : 0] mvu_wrc_addr     ; // input  wrc_addr;
    logic [     BDBANKW-1 : 0] mvu_wrc_word     ; // input  wrc_word;
    logic [         NMVU-1 : 0] mvu_quant_clr   ; // Quantizer: clear
    logic [NMVU*BQMSBIDX-1 : 0] mvu_quant_msbidx; // Quantizer: bit position index of the MSB
    logic [         NMVU-1 : 0] mvu_quant_start ; // Quantizer: signal to start quantizing
    logic[  NMVU*BCNTDWN-1 : 0] mvu_countdown   ; // Config: number of clocks to countdown for given task
    logic[    NMVU*BPREC-1 : 0] mvu_wprecision  ; // Config: weight precision
    logic[    NMVU*BPREC-1 : 0] mvu_iprecision  ; // Config: input precision
    logic[    NMVU*BPREC-1 : 0] mvu_oprecision  ; // Config: output precision
    logic[  NMVU*BBWADDR-1 : 0] mvu_wbaseaddr   ; // Config: weight memory base address
    logic[  NMVU*BBDADDR-1 : 0] mvu_ibaseaddr   ; // Config: data memory base address for input
    logic[  NMVU*BBDADDR-1 : 0] mvu_obaseaddr   ; // Config: data memory base address for output
    logic[  NMVU*BWBANKA-1 : 0] mvu_wrw_addr    ; // Weight memory: write address
    logic[  NMVU*BWBANKW-1 : 0] mvu_wrw_word    ; // Weight memory: write word
    logic[          NMVU-1 : 0] mvu_wrw_en      ; // Weight memory: write enable
    logic[  NMVU*BSTRIDE-1 : 0] mvu_wstride_0   ; // Config: weight stride in dimension 0 (x)
    logic[  NMVU*BSTRIDE-1 : 0] mvu_wstride_1   ; // Config: weight stride in dimension 1 (y)
    logic[  NMVU*BSTRIDE-1 : 0] mvu_wstride_2   ; // Config: weight stride in dimension 2 (z)
    logic[  NMVU*BSTRIDE-1 : 0] mvu_istride_0   ; // Config: input stride in dimension 0 (x)
    logic[  NMVU*BSTRIDE-1 : 0] mvu_istride_1   ; // Config: input stride in dimension 1 (y)
    logic[  NMVU*BSTRIDE-1 : 0] mvu_istride_2   ; // Config: input stride in dimension 2 (z)
    logic[  NMVU*BSTRIDE-1 : 0] mvu_ostride_0   ; // Config: output stride in dimension 0 (x)
    logic[  NMVU*BSTRIDE-1 : 0] mvu_ostride_1   ; // Config: output stride in dimension 1 (y)
    logic[  NMVU*BSTRIDE-1 : 0] mvu_ostride_2   ; // Config: output stride in dimension 2 (z)
    logic[  NMVU*BLENGTH-1 : 0] mvu_wlength_0   ; // Config: weight length in dimension 0 (x)
    logic[  NMVU*BLENGTH-1 : 0] mvu_wlength_1   ; // Config: weight length in dimension 1 (y)
    logic[  NMVU*BLENGTH-1 : 0] mvu_wlength_2   ; // Config: weight length in dimension 2 (z)
    logic[  NMVU*BLENGTH-1 : 0] mvu_ilength_0   ; // Config: input length in dimension 0 (x)
    logic[  NMVU*BLENGTH-1 : 0] mvu_ilength_1   ; // Config: input length in dimension 1 (y)
    logic[  NMVU*BLENGTH-1 : 0] mvu_ilength_2   ; // Config: input length in dimension 2 (z)
    logic[  NMVU*BLENGTH-1 : 0] mvu_olength_0   ; // Config: output length in dimension 0 (x)
    logic[  NMVU*BLENGTH-1 : 0] mvu_olength_1   ; // Config: output length in dimension 1 (y)
    logic[  NMVU*BLENGTH-1 : 0] mvu_olength_2   ; // Config: output length in dimension 2 (z)


    assign mvu_clk   = io_clk;
    assign mvu_rst_n = io_rst_n;

    assign mvu_ic_clr        = 0;
    assign mvu_ic_recv_from  = 0;
    assign mvu_acc_clr       = 0;
    assign mvu_max_en        = 0;
    assign mvu_max_clr       = 0;
    assign mvu_max_pool      = 0;
    assign mvu_quant_clr     = 0;
    assign mvu_quant_msbidx  = 0;
    assign mvu_quant_start   = 0;
    assign mvu_wrw_addr      = 0;
    assign mvu_wrw_word      = 0;
    assign mvu_wrw_en        = 0;
    assign mvu_rdc_en        = 0;
    assign mvu_rdc_addr      = 0;
    assign mvu_wrc_en        = 0;
    assign mvu_wrc_addr      = 0;
    assign mvu_wrc_word      = 0;
    
    mvutop #(
            .NMVU  (NMVU  ),
            .N     (N     ),
            .NDBANK(NDBANK)
        ) mvu
        (
            .clk              (mvu_clk          ), // connected
            .rst_n            (mvu_rst_n        ), // connected
            .start            (mvu_start        ), // connected
            .done             (mvu_done         ),
            .irq              (mvu_irq          ), // connected
            .ic_clr           (mvu_ic_clr       ),
            .ic_recv_from     (mvu_ic_recv_from ),
            .mul_mode         (mvu_mul_mode     ), // connected
            .acc_clr          (mvu_acc_clr      ),
            .max_en           (mvu_max_en       ),
            .max_clr          (mvu_max_clr      ),
            .max_pool         (mvu_max_pool     ),
            .quant_clr        (mvu_quant_clr    ),
            .quant_msbidx     (mvu_quant_msbidx ),
            .quant_start      (mvu_quant_start  ),
            .countdown        (mvu_countdown    ), // connected
            .wprecision       (mvu_wprecision   ), // connected
            .iprecision       (mvu_iprecision   ), // connected
            .oprecision       (mvu_oprecision   ), // connected
            .wbaseaddr        (mvu_wbaseaddr    ), // connected
            .ibaseaddr        (mvu_ibaseaddr    ), // connected
            .obaseaddr        (mvu_obaseaddr    ), // connected
            .wstride_0        (mvu_wstride_0    ), // connected
            .wstride_1        (mvu_wstride_1    ), // connected
            .wstride_2        (mvu_wstride_2    ), // connected
            .istride_0        (mvu_istride_0    ), // connected
            .istride_1        (mvu_istride_1    ), // connected
            .istride_2        (mvu_istride_2    ), // connected
            .ostride_0        (mvu_ostride_0    ), // connected
            .ostride_1        (mvu_ostride_1    ), // connected
            .ostride_2        (mvu_ostride_2    ), // connected
            .wlength_0        (mvu_wlength_0    ), // connected
            .wlength_1        (mvu_wlength_1    ), // connected
            .wlength_2        (mvu_wlength_2    ), // connected
            .ilength_0        (mvu_ilength_0    ), // connected
            .ilength_1        (mvu_ilength_1    ), // connected
            .ilength_2        (mvu_ilength_2    ), // connected
            .olength_0        (mvu_olength_0    ), // connected
            .olength_1        (mvu_olength_1    ), // connected
            .olength_2        (mvu_olength_2    ), // connected
            .wrw_addr         (mvu_wrw_addr     ),
            .wrw_word         (mvu_wrw_word     ),
            .wrw_en           (mvu_wrw_en       ),
            .rdc_en           (mvu_rdc_en       ),
            .rdc_grnt         (mvu_rdc_grnt     ),
            .rdc_addr         (mvu_rdc_addr     ),
            .rdc_word         (mvu_rdc_word     ),
            .wrc_en           (mvu_wrc_en       ),
            .wrc_grnt         (mvu_wrc_grnt     ),
            .wrc_addr         (mvu_wrc_addr     ),
            .wrc_word         (mvu_wrc_word     )
        );

    assign pito_clk   = io_clk;
    assign pito_rst_n = io_rst_n;

rv32_core pito_rv32_core(
    .pito_io_clk      (pito_clk         ),
    .pito_io_rst_n    (pito_rst_n       ),
    .pito_io_imem_addr(io_imem_addr     ),
    .pito_io_imem_data(io_imem_data     ),
    .pito_io_dmem_addr(io_dmem_addr     ),
    .pito_io_dmem_data(io_dmem_data     ),
    .pito_io_imem_w_en(io_imem_w_en     ),
    .pito_io_dmem_w_en(io_dmem_w_en     ),
    .pito_io_program  (io_pito_program  ),
    .mvu_irq_i        (mvu_irq          ),
    .mvu_mul_mode     (mvu_mul_mode     ),
    .mvu_countdown    (mvu_countdown    ),
    .mvu_wprecision   (mvu_wprecision   ),
    .mvu_iprecision   (mvu_iprecision   ),
    .mvu_oprecision   (mvu_oprecision   ),
    .mvu_wbaseaddr    (mvu_wbaseaddr    ),
    .mvu_ibaseaddr    (mvu_ibaseaddr    ),
    .mvu_obaseaddr    (mvu_obaseaddr    ),
    .mvu_wstride_0    (mvu_wstride_0    ),
    .mvu_wstride_1    (mvu_wstride_1    ),
    .mvu_wstride_2    (mvu_wstride_2    ),
    .mvu_istride_0    (mvu_istride_0    ),
    .mvu_istride_1    (mvu_istride_1    ),
    .mvu_istride_2    (mvu_istride_2    ),
    .mvu_ostride_0    (mvu_ostride_0    ),
    .mvu_ostride_1    (mvu_ostride_1    ),
    .mvu_ostride_2    (mvu_ostride_2    ),
    .mvu_wlength_0    (mvu_wlength_0    ),
    .mvu_wlength_1    (mvu_wlength_1    ),
    .mvu_wlength_2    (mvu_wlength_2    ),
    .mvu_ilength_0    (mvu_ilength_0    ),
    .mvu_ilength_1    (mvu_ilength_1    ),
    .mvu_ilength_2    (mvu_ilength_2    ),
    .mvu_olength_0    (mvu_olength_0    ),
    .mvu_olength_1    (mvu_olength_1    ),
    .mvu_olength_2    (mvu_olength_2    ),
    .mvu_start        (mvu_start        )
);

endmodule