interface barvinn_interface(input logic clk);
    import mvu_pkg::*;
    import rv32_pkg::*;
    import pito_pkg::*;
    //=======================================
    //          PITO Interface
    //=======================================
    logic                      rst_n;
    rv32_imem_addr_t           pito_io_imem_addr;
    rv32_instr_t               pito_io_imem_data;
    rv32_dmem_addr_t           pito_io_dmem_addr;
    rv32_data_t                pito_io_dmem_data;
    logic                      pito_io_imem_w_en;
    logic                      pito_io_dmem_w_en;
    logic                      pito_io_program;
    //=======================================
    //          Data Transposer Interface
    //=======================================
    logic [       NMVU*32-1 : 0]  mvu_data_prec;
    logic [       NMVU*32-1 : 0]  mvu_data_baddr;
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
    logic[          NMVU-1 : 0] mvu_wrc_en;               // Data memory: controller write enable
    logic[          NMVU-1 : 0] mvu_wrc_grnt;             // Data memory: controller write grant
    logic[       BDBANKA-1 : 0] mvu_wrc_addr;             // Data memory: controller write address
    logic[       BDBANKW-1 : 0] mvu_wrc_word;             // Data memory: controller write word

//=================================================
// Modport for Testbench interface 
//=================================================
modport  tb_interface (
    input  rst_n,
    input  pito_io_imem_addr,
    input  pito_io_imem_data,
    input  pito_io_dmem_addr,
    input  pito_io_dmem_data,
    input  pito_io_imem_w_en,
    input  pito_io_dmem_w_en,
    input  pito_io_program,
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
    output mvu_rdc_word,
    input  mvu_wrc_en,
    output mvu_wrc_grnt,
    input  mvu_wrc_addr,
    input  mvu_wrc_word
);

clocking cb @ (posedge clk);
    inout rst_n;
    inout pito_io_imem_addr;
    inout pito_io_imem_data;
    inout pito_io_dmem_addr;
    inout pito_io_dmem_data;
    inout pito_io_imem_w_en;
    inout pito_io_dmem_w_en;
    inout pito_io_program;
    inout mvu_data_prec;
    inout mvu_data_baddr;
    inout mvu_data_iword;
    inout mvu_data_start;
    inout mvu_data_busy;
    inout mvu_wrw_addr;
    inout mvu_wrw_word;
    inout mvu_wrw_en;
    inout mvu_irq_tap;
    inout mvu_rdc_en;
    inout mvu_rdc_grnt;
    inout mvu_rdc_addr;
    inout mvu_rdc_word;
    inout mvu_wrc_en;
    inout mvu_wrc_grnt;
    inout mvu_wrc_addr;
    inout mvu_wrc_word;
endclocking
  
  //=================================================
// Modport for System interface 
//=================================================
modport  system_interface (
    input  rst_n,
    input  pito_io_imem_addr,
    input  pito_io_imem_data,
    input  pito_io_dmem_addr,
    input  pito_io_dmem_data,
    input  pito_io_imem_w_en,
    input  pito_io_dmem_w_en,
    input  pito_io_program,
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
    output mvu_rdc_word,
    input  mvu_wrc_en,
    output mvu_wrc_grnt,
    input  mvu_wrc_addr,
    input  mvu_wrc_word
);

endinterface
