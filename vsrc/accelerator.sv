module accelerator #(
    //PITO RISC-V Parameters
    parameter  XLEN    = 32,            // Datapath length

    // MVU Prameters
    parameter  NMVU    =  8,            // Number of MVUs. Ideally a Power-of-2.
    parameter  N       = 64,            // N x N matrix-vector product size. Power-of-2.
    parameter  NDBANK  = 32,            // Number of 2N-bit, 512-element Data BANK.
    parameter  BMVUA   = $clog2(NMVU),  // Bitwidth of MVU Address 
    parameter  BWBANKA = 9,             // Bitwidth of Weights BANK Address 
    parameter  BWBANKW = 4096,          // Bitwidth of Weights BANK Word
    parameter  BDBANKA = 15,            // Bitwidth of Data BANK Address 
    parameter  BDBANKW = N,             // Bitwidth of Data BANK Word 
    
    // Other Parameters
    parameter  BCNTDWN  = 29,           // Bitwidth of the countdown ports
    parameter  BPREC    = 6,            // Bitwidth of the precision ports
    parameter  BBWADDR  = 9,            // Bitwidth of the weight base address ports
    parameter  BBDADDR  = 15,           // Bitwidth of the data base address ports
    parameter  BSTRIDE  = 15,           // Bitwidth of the stride ports
    parameter  BLENGTH  = 15,           // Bitwidth of the length ports
    parameter  BACC     = 32,           // Bitwidth of Accumulators 
    parameter  BSCALERB = 16,           // scalar value
    parameter  MVU_MAX_DATA_PREC = 16,  // Maximum supported data length in MVU
    // Quantizer parameters
    parameter  BQMSBIDX = $clog2(BACC),     // Bitwidth of the quantizer MSB location specifier
    parameter  BQBOUT   = $clog2(BACC)     // Bitwitdh of the quantizer 
)(
    //=======================================
    //          PITO Interface
    //=======================================
    input  logic                      clk,
    input  logic                      rst_n,
    input  rv32_imem_addr_t           pito_imem_addr,
    input  rv32_instr_t               pito_imem_data,
    input  rv32_dmem_addr_t           pito_dmem_addr,
    input  rv32_data_t                pito_dmem_data,
    input  logic                      pito_imem_w_en,
    input  logic                      pito_dmem_w_en,
    input  logic                      pito_pito_program,

    //=======================================
    //          Data Transposer Interface
    //=======================================
    input  logic [     NMVU*31 : 0]  mvu_data_prec,
    input  logic [     NMVU*31 : 0]  mvu_data_baddr,
    input  logic [ NMVU*XLEN-1 : 0]  mvu_data_iword,
    input  logic [      NMVU-1 : 0]  mvu_data_start,
    output logic [      NMVU-1 : 0]  mvu_data_busy,

    //=======================================
    //          MVU Interface
    //=======================================
    input  logic [NMVU*BWBANKA-1 : 0] mvu_wrw_addr, // Weight memory: write address
    input  logic [NMVU*BWBANKW-1 : 0] mvu_wrw_word, // Weight memory: write word
    input  logic [        NMVU-1 : 0] mvu_wrw_en,   // Weight memory: write enable
    output logic [        NMVU-1 : 0] mvu_irq_tap,

    input  logic [        NMVU-1  : 0] mvu_rdc_en  ,// input  rdc_en;
    output logic [        NMVU-1  : 0] mvu_rdc_grnt,// output rdc_grnt;
    input  logic [NMVU*BDBANKA-1  : 0] mvu_rdc_addr,// input  rdc_addr;
    output logic [NMVU*BDBANKW-1  : 0] mvu_rdc_word // output rdc_word;

);

    logic                       mvu_clk         ; // input  clk;
    logic                       mvu_rst_n       ; // input  reset;
    logic [        NMVU-1  : 0] mvu_start       ; // input  start;
    logic [        NMVU-1  : 0] mvu_done        ; // output done;
    logic [        NMVU-1  : 0] mvu_irq         ; // output irq
    logic                       mvu_ic_clr      ; // input  ic_clr;
    // logic [  NMVU*BMVUA-1  : 0] mvu_ic_recv_from; // input  ic_recv_from;
    logic [      2*NMVU-1  : 0] mvu_mul_mode    ; // input  mul_mode;
    logic [         NMVU-1 : 0] mvu_d_signed    ;
    logic [         NMVU-1 : 0] mvu_w_signed    ;
    logic [         NMVU-1 : 0] mvu_shacc_clr   ;
    logic [        NMVU-1  : 0] mvu_max_en      ; // input  max_en;
    logic [        NMVU-1  : 0] mvu_max_clr     ; // input  max_clr;
    logic [        NMVU-1  : 0] mvu_max_pool    ; // input  max_pool;
    logic [ NMVU*BBWADDR-1 : 0] mvu_wbaseaddr   ; // Config: weight memory base address
    logic [ NMVU*BBDADDR-1 : 0] mvu_ibaseaddr   ; // Config: data memory base address for input
    logic [ NMVU*BBDADDR-1 : 0] mvu_obaseaddr   ; // Config: data memory base address for output
    logic [ NMVU*BSTRIDE-1 : 0] mvu_wstride_0   ; // Config: weight stride in dimension 0 (x)
    logic [ NMVU*BSTRIDE-1 : 0] mvu_wstride_1   ; // Config: weight stride in dimension 1 (y)
    logic [ NMVU*BSTRIDE-1 : 0] mvu_wstride_2   ; // Config: weight stride in dimension 2 (z)
    logic [ NMVU*BSTRIDE-1 : 0] mvu_wstride_3   ; // Config: weight stride in dimension 3 (z)
    logic [ NMVU*BSTRIDE-1 : 0] mvu_istride_0   ; // Config: input stride in dimension 0 (x)
    logic [ NMVU*BSTRIDE-1 : 0] mvu_istride_1   ; // Config: input stride in dimension 1 (y)
    logic [ NMVU*BSTRIDE-1 : 0] mvu_istride_2   ; // Config: input stride in dimension 2 (z)
    logic [ NMVU*BSTRIDE-1 : 0] mvu_istride_3   ; // Config: input stride in dimension 3 (z)
    logic [ NMVU*BSTRIDE-1 : 0] mvu_ostride_0   ; // Config: output stride in dimension 0 (x)
    logic [ NMVU*BSTRIDE-1 : 0] mvu_ostride_1   ; // Config: output stride in dimension 1 (y)
    logic [ NMVU*BSTRIDE-1 : 0] mvu_ostride_2   ; // Config: output stride in dimension 2 (z)
    logic [ NMVU*BSTRIDE-1 : 0] mvu_ostride_3   ; // Config: output stride in dimension 3 (z)
    logic [ NMVU*BLENGTH-1 : 0] mvu_wlength_0   ; // Config: weight length in dimension 0 (x)
    logic [ NMVU*BLENGTH-1 : 0] mvu_wlength_1   ; // Config: weight length in dimension 1 (y)
    logic [ NMVU*BLENGTH-1 : 0] mvu_wlength_2   ; // Config: weight length in dimension 2 (z)
    logic [ NMVU*BLENGTH-1 : 0] mvu_wlength_3   ; // Config: weight length in dimension 3 (z)
    logic [ NMVU*BLENGTH-1 : 0] mvu_ilength_0   ; // Config: input length in dimension 0 (x)
    logic [ NMVU*BLENGTH-1 : 0] mvu_ilength_1   ; // Config: input length in dimension 1 (y)
    logic [ NMVU*BLENGTH-1 : 0] mvu_ilength_2   ; // Config: input length in dimension 2 (z)
    logic [ NMVU*BLENGTH-1 : 0] mvu_ilength_3   ; // Config: input length in dimension 3 (z)
    logic [ NMVU*BLENGTH-1 : 0] mvu_olength_0   ; // Config: output length in dimension 0 (x)
    logic [ NMVU*BLENGTH-1 : 0] mvu_olength_1   ; // Config: output length in dimension 1 (y)
    logic [ NMVU*BLENGTH-1 : 0] mvu_olength_2   ; // Config: output length in dimension 2 (z)
    logic [ NMVU*BLENGTH-1 : 0] mvu_olength_3   ; // Config: output length in dimension 3 (z)
    logic [         NMVU-1 : 0] mvu_wrc_en      ;//input  wrc_en;
    logic [         NMVU-1 : 0] mvu_wrc_grnt    ;//output wrc_grnt;
    logic [      BDBANKA-1 : 0] mvu_wrc_addr    ;//input  wrc_addr;
    logic [      BDBANKW-1 : 0] mvu_wrc_word    ;//input  wrc_word;
    logic [         NMVU-1 : 0] mvu_quant_clr   ; // Quantizer: clear
    logic [NMVU*BQMSBIDX-1 : 0] mvu_quant_msbidx; // Quantizer: bit position index of the MSB
    logic [ NMVU*BCNTDWN-1 : 0] mvu_countdown   ; // Config: number of clocks to countdown for given task
    logic [   NMVU*BPREC-1 : 0] mvu_wprecision  ; // Config: weight precision
    logic [   NMVU*BPREC-1 : 0] mvu_iprecision  ; // Config: input precision
    logic [   NMVU*BPREC-1 : 0] mvu_oprecision  ; // Config: output precision
    logic [         NMVU-1 : 0] mvu_i_signed    ; // MVU input is signed
    // logic [   NMVU*BPREC-1 : 0] mvu_iprecision  ; // Config: input precision
    // logic [   NMVU*BPREC-1 : 0] mvu_oprecision  ; // Config: output precision

    logic [NMVU*BSCALERB-1 : 0] mvu_scaler_b  ; // MVU scaler factor

    logic [       32*NMVU-1: 0] csr_mvu_wbaseaddr;
    logic [       32*NMVU-1: 0] csr_mvu_ibaseaddr;
    logic [       32*NMVU-1: 0] csr_mvu_obaseaddr;
    logic [       32*NMVU-1: 0] csr_mvu_wstride_0;
    logic [       32*NMVU-1: 0] csr_mvu_wstride_1;
    logic [       32*NMVU-1: 0] csr_mvu_wstride_2;
    logic [       32*NMVU-1: 0] csr_mvu_istride_0;
    logic [       32*NMVU-1: 0] csr_mvu_istride_1;
    logic [       32*NMVU-1: 0] csr_mvu_istride_2;
    logic [       32*NMVU-1: 0] csr_mvu_ostride_0;
    logic [       32*NMVU-1: 0] csr_mvu_ostride_1;
    logic [       32*NMVU-1: 0] csr_mvu_ostride_2;
    logic [       32*NMVU-1: 0] csr_mvu_wlength_0;
    logic [       32*NMVU-1: 0] csr_mvu_wlength_1;
    logic [       32*NMVU-1: 0] csr_mvu_wlength_2;
    logic [       32*NMVU-1: 0] csr_mvu_ilength_0;
    logic [       32*NMVU-1: 0] csr_mvu_ilength_1;
    logic [       32*NMVU-1: 0] csr_mvu_ilength_2;
    logic [       32*NMVU-1: 0] csr_mvu_olength_0;
    logic [       32*NMVU-1: 0] csr_mvu_olength_1;
    logic [       32*NMVU-1: 0] csr_mvu_olength_2;
    logic [       32*NMVU-1: 0] csr_mvu_precision;
    logic [       32*NMVU-1: 0] csr_mvu_status   ;
    logic [       32*NMVU-1: 0] csr_mvu_command  ;
    logic [       32*NMVU-1: 0] csr_mvu_quant    ;
    logic [       32*NMVU-1: 0] csr_mvu_wstride_3;
    logic [       32*NMVU-1: 0] csr_mvu_istride_3;
    logic [       32*NMVU-1: 0] csr_mvu_ostride_3;
    logic [       32*NMVU-1: 0] csr_mvu_wlength_3;
    logic [       32*NMVU-1: 0] csr_mvu_ilength_3;
    logic [       32*NMVU-1: 0] csr_mvu_olength_3;
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
        assign mvu_wbaseaddr[mvu_cnt*BBWADDR +: BBWADDR]     = csr_mvu_wbaseaddr[mvu_cnt*32 +: BBWADDR];
        assign mvu_ibaseaddr[mvu_cnt*BBDADDR +: BBDADDR]     = csr_mvu_ibaseaddr[mvu_cnt*32 +: BBDADDR];
        assign mvu_obaseaddr[mvu_cnt*BBDADDR +: BBDADDR]     = csr_mvu_obaseaddr[mvu_cnt*32 +: BBDADDR];
        assign mvu_wstride_0[mvu_cnt*BSTRIDE +: BSTRIDE]     = csr_mvu_wstride_0[mvu_cnt*32 +: BSTRIDE];
        assign mvu_wstride_1[mvu_cnt*BSTRIDE +: BSTRIDE]     = csr_mvu_wstride_1[mvu_cnt*32 +: BSTRIDE];
        assign mvu_wstride_2[mvu_cnt*BSTRIDE +: BSTRIDE]     = csr_mvu_wstride_2[mvu_cnt*32 +: BSTRIDE];
        assign mvu_wstride_3[mvu_cnt*BSTRIDE +: BSTRIDE]     = csr_mvu_wstride_3[mvu_cnt*32 +: BSTRIDE];
        assign mvu_istride_0[mvu_cnt*BSTRIDE +: BSTRIDE]     = csr_mvu_istride_0[mvu_cnt*32 +: BSTRIDE];
        assign mvu_istride_1[mvu_cnt*BSTRIDE +: BSTRIDE]     = csr_mvu_istride_1[mvu_cnt*32 +: BSTRIDE];
        assign mvu_istride_2[mvu_cnt*BSTRIDE +: BSTRIDE]     = csr_mvu_istride_2[mvu_cnt*32 +: BSTRIDE];
        assign mvu_istride_3[mvu_cnt*BSTRIDE +: BSTRIDE]     = csr_mvu_istride_3[mvu_cnt*32 +: BSTRIDE];
        assign mvu_ostride_0[mvu_cnt*BSTRIDE +: BSTRIDE]     = csr_mvu_ostride_0[mvu_cnt*32 +: BSTRIDE];
        assign mvu_ostride_1[mvu_cnt*BSTRIDE +: BSTRIDE]     = csr_mvu_ostride_1[mvu_cnt*32 +: BSTRIDE];
        assign mvu_ostride_2[mvu_cnt*BSTRIDE +: BSTRIDE]     = csr_mvu_ostride_2[mvu_cnt*32 +: BSTRIDE];
        assign mvu_ostride_3[mvu_cnt*BSTRIDE +: BSTRIDE]     = csr_mvu_ostride_3[mvu_cnt*32 +: BSTRIDE];
        assign mvu_wlength_0[mvu_cnt*BLENGTH +: BLENGTH]     = csr_mvu_wlength_0[mvu_cnt*32 +: BLENGTH];
        assign mvu_wlength_1[mvu_cnt*BLENGTH +: BLENGTH]     = csr_mvu_wlength_1[mvu_cnt*32 +: BLENGTH];
        assign mvu_wlength_2[mvu_cnt*BLENGTH +: BLENGTH]     = csr_mvu_wlength_2[mvu_cnt*32 +: BLENGTH];
        assign mvu_wlength_3[mvu_cnt*BSTRIDE +: BSTRIDE]     = csr_mvu_wlength_3[mvu_cnt*32 +: BSTRIDE];
        assign mvu_ilength_0[mvu_cnt*BLENGTH +: BLENGTH]     = csr_mvu_ilength_0[mvu_cnt*32 +: BLENGTH];
        assign mvu_ilength_1[mvu_cnt*BLENGTH +: BLENGTH]     = csr_mvu_ilength_1[mvu_cnt*32 +: BLENGTH];
        assign mvu_ilength_2[mvu_cnt*BLENGTH +: BLENGTH]     = csr_mvu_ilength_2[mvu_cnt*32 +: BLENGTH];
        assign mvu_ilength_3[mvu_cnt*BSTRIDE +: BSTRIDE]     = csr_mvu_ilength_3[mvu_cnt*32 +: BSTRIDE];
        assign mvu_olength_0[mvu_cnt*BLENGTH +: BLENGTH]     = csr_mvu_olength_0[mvu_cnt*32 +: BLENGTH];
        assign mvu_olength_1[mvu_cnt*BLENGTH +: BLENGTH]     = csr_mvu_olength_1[mvu_cnt*32 +: BLENGTH];
        assign mvu_olength_2[mvu_cnt*BLENGTH +: BLENGTH]     = csr_mvu_olength_2[mvu_cnt*32 +: BLENGTH];
        assign mvu_olength_3[mvu_cnt*BSTRIDE +: BSTRIDE]     = csr_mvu_olength_3[mvu_cnt*32 +: BSTRIDE];
        assign mvu_wprecision[mvu_cnt*BPREC +: BPREC]        = csr_mvu_precision[mvu_cnt*32 +: BPREC];
        assign mvu_iprecision[mvu_cnt*BPREC +: BPREC]        = csr_mvu_precision[(mvu_cnt*32+BPREC) +: BPREC];
        assign mvu_oprecision[mvu_cnt*BPREC +: BPREC]        = csr_mvu_precision[(mvu_cnt*32+2*BPREC) +: BPREC];
        assign mvu_w_signed[mvu_cnt]                         = csr_mvu_precision[mvu_cnt*32 + 24];
        assign mvu_i_signed[mvu_cnt]                         = csr_mvu_precision[mvu_cnt*32 + 25];
        assign mvu_d_signed[mvu_cnt]                         = csr_mvu_precision[mvu_cnt*32 + 25];
        assign mvu_shacc_clr[mvu_cnt]                        = ~rst_n;
        // assign mvu_status  = {31{1'b0}, mvu_status}       ;
        assign mvu_mul_mode[mvu_cnt*2 +: 2]                  = csr_mvu_command[(mvu_cnt*32 + 30) +: 2];
        assign mvu_max_en[mvu_cnt]                           = csr_mvu_command[mvu_cnt*32 + 29];
        assign mvu_countdown[mvu_cnt*BCNTDWN +: BCNTDWN]     = csr_mvu_command[ mvu_cnt*32 +: BCNTDWN];
        assign mvu_quant_msbidx[mvu_cnt*BQMSBIDX +: BQMSBIDX]= csr_mvu_quant[(mvu_cnt*32) +: BQMSBIDX];

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
            // .ic_recv_from     (mvu_ic_recv_from ),
            .mul_mode         (mvu_mul_mode     ), // connected
            .d_signed         (mvu_d_signed     ),
            .w_signed         (mvu_w_signed     ),
            .shacc_clr        (mvu_shacc_clr    ),
            .max_en           (mvu_max_en       ),
            .max_clr          (mvu_max_clr      ),
            .max_pool         (mvu_max_pool     ),
            .quant_clr        (mvu_quant_clr    ),
            .quant_msbidx     (mvu_quant_msbidx ),
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
            .wstride_3        (mvu_wstride_3    ),
            .istride_0        (mvu_istride_0    ), // connected
            .istride_1        (mvu_istride_1    ), // connected
            .istride_2        (mvu_istride_2    ), // connected
            .istride_3        (mvu_istride_3    ),
            .ostride_0        (mvu_ostride_0    ), // connected
            .ostride_1        (mvu_ostride_1    ), // connected
            .ostride_2        (mvu_ostride_2    ), // connected
            .ostride_3        (mvu_ostride_3    ),
            .wlength_0        (mvu_wlength_0    ), // connected
            .wlength_1        (mvu_wlength_1    ), // connected
            .wlength_2        (mvu_wlength_2    ), // connected
            .wlength_3        (mvu_wlength_3    ), // connected
            .ilength_0        (mvu_ilength_0    ), // connected
            .ilength_1        (mvu_ilength_1    ), // connected
            .ilength_2        (mvu_ilength_2    ), // connected
            .ilength_3        (mvu_ilength_3    ), // connected
            .olength_0        (mvu_olength_0    ), // connected
            .olength_1        (mvu_olength_1    ), // connected
            .olength_2        (mvu_olength_2    ), // connected
            .olength_3        (mvu_olength_3    ), // connected
            .scaler_b         (mvu_scaler_b     ),
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
    logic pito_clk;
    logic pito_rst_n;

    assign pito_clk   = clk;
    assign pito_rst_n = rst_n;
    assign mvu_irq_tap = mvu_irq;

rv32_core pito_rv32_core(
    .pito_io_clk      (pito_clk             ),
    .pito_io_rst_n    (pito_rst_n           ),
    .pito_io_imem_addr(pito_imem_addr       ),
    .pito_io_imem_data(pito_imem_data       ),
    .pito_io_dmem_addr(pito_dmem_addr       ),
    .pito_io_dmem_data(pito_dmem_data       ),
    .pito_io_imem_w_en(pito_imem_w_en       ),
    .pito_io_dmem_w_en(pito_dmem_w_en       ),
    .pito_io_program  (pito_pito_program    ),
    .mvu_irq_i        (mvu_irq              ),
    .csr_mvu_wbaseaddr(csr_mvu_wbaseaddr    ),
    .csr_mvu_ibaseaddr(csr_mvu_ibaseaddr    ),
    .csr_mvu_obaseaddr(csr_mvu_obaseaddr    ),
    .csr_mvu_wstride_0(csr_mvu_wstride_0    ),
    .csr_mvu_wstride_1(csr_mvu_wstride_1    ),
    .csr_mvu_wstride_2(csr_mvu_wstride_2    ),
    .csr_mvu_istride_0(csr_mvu_istride_0    ),
    .csr_mvu_istride_1(csr_mvu_istride_1    ),
    .csr_mvu_istride_2(csr_mvu_istride_2    ),
    .csr_mvu_ostride_0(csr_mvu_ostride_0    ),
    .csr_mvu_ostride_1(csr_mvu_ostride_1    ),
    .csr_mvu_ostride_2(csr_mvu_ostride_2    ),
    .csr_mvu_wlength_0(csr_mvu_wlength_0    ),
    .csr_mvu_wlength_1(csr_mvu_wlength_1    ),
    .csr_mvu_wlength_2(csr_mvu_wlength_2    ),
    .csr_mvu_ilength_0(csr_mvu_ilength_0    ),
    .csr_mvu_ilength_1(csr_mvu_ilength_1    ),
    .csr_mvu_ilength_2(csr_mvu_ilength_2    ),
    .csr_mvu_olength_0(csr_mvu_olength_0    ),
    .csr_mvu_olength_1(csr_mvu_olength_1    ),
    .csr_mvu_olength_2(csr_mvu_olength_2    ),
    .csr_mvu_precision(csr_mvu_precision    ),
    .csr_mvu_wstride_3(csr_mvu_wstride_3    ),
    .csr_mvu_istride_3(csr_mvu_istride_3    ),
    .csr_mvu_ostride_3(csr_mvu_ostride_3    ),
    .csr_mvu_wlength_3(csr_mvu_wlength_3    ),
    .csr_mvu_ilength_3(csr_mvu_ilength_3    ),
    .csr_mvu_olength_3(csr_mvu_olength_3    ),
    .csr_mvu_status   (csr_mvu_status       ),
    .csr_mvu_command  (csr_mvu_command      ),
    .csr_mvu_quant    (csr_mvu_quant        ),
    .mvu_start        (mvu_start            )
);

always @(posedge mvu_irq[0]) begin
    $display("IRQ is sent!");
end

endmodule