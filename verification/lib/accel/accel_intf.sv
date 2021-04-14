interface accel_interface(input logic clk);
    import mvu_pkg::*;
    import rv32_pkg::*;
    import pito_pkg::*;
    //=======================================
    //          PITO Interface
    //=======================================
    logic                      rst_n;
    rv32_imem_addr_t           pito_imem_addr;
    rv32_instr_t               pito_imem_data;
    rv32_dmem_addr_t           pito_dmem_addr;
    rv32_data_t                pito_dmem_data;
    logic                      pito_imem_w_en;
    logic                      pito_dmem_w_en;
    logic                      pito_pito_program;
    //=======================================
    //          Data Transposer Interface
    //=======================================
    logic [         NMVU*31 : 0]  mvu_data_prec;
    logic [         NMVU*31 : 0]  mvu_data_baddr;
    logic [ NMVU*`XPR_LEN-1 : 0]  mvu_data_iword;
    logic [          NMVU-1 : 0]  mvu_data_start;
    logic [          NMVU-1 : 0]  mvu_data_busy;
    //=======================================
    //          MVU Interface
    //=======================================
    logic [NMVU*BWBANKA-1  : 0] mvu_wrw_addr; // Weight memory: write address
    logic [NMVU*BWBANKW-1  : 0] mvu_wrw_word; // Weight memory: write word
    logic [        NMVU-1  : 0] mvu_wrw_en;   // Weight memory: write enable
    logic [        NMVU-1  : 0] mvu_irq_tap;  
    logic [        NMVU-1  : 0] mvu_rdc_en  ; // input  rdc_en;
    logic [        NMVU-1  : 0] mvu_rdc_grnt; // output rdc_grnt;
    logic [NMVU*BDBANKA-1  : 0] mvu_rdc_addr; // input  rdc_addr;
    logic [NMVU*BDBANKW-1  : 0] mvu_rdc_word; // output rdc_word;

//=================================================
// Modport for Testbench interface 
//=================================================
modport  tb_interface (
    input  rst_n,
    input  pito_imem_addr,
    input  pito_imem_data,
    input  pito_dmem_addr,
    input  pito_dmem_data,
    input  pito_imem_w_en,
    input  pito_dmem_w_en,
    input  pito_pito_program,
    input  mvu_data_prec,
    input  mvu_data_baddr,
    input  mvu_data_iword,
    input  mvu_data_start,
    output mvu_data_busy,
    input  mvu_wrw_addr,
    input  mvu_wrw_word,
    input  mvu_wrw_en,
    output mvu_irq_tap,
    input  mvu_rdc_en,
    output mvu_rdc_grnt,
    input  mvu_rdc_addr,
    output mvu_rdc_word
);

//=================================================
// Modport for System interface 
//=================================================
modport  system_interface (
    input  rst_n,
    input  pito_imem_addr,
    input  pito_imem_data,
    input  pito_dmem_addr,
    input  pito_dmem_data,
    input  pito_imem_w_en,
    input  pito_dmem_w_en,
    input  pito_pito_program,
    input  mvu_data_prec,
    input  mvu_data_baddr,
    input  mvu_data_iword,
    input  mvu_data_start,
    output mvu_data_busy,
    input  mvu_wrw_addr,
    input  mvu_wrw_word,
    input  mvu_wrw_en,
    output mvu_irq_tap,
    input  mvu_rdc_en,
    output mvu_rdc_grnt,
    input  mvu_rdc_addr,
    output mvu_rdc_word
);

endinterface