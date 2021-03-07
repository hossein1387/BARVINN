interface accel_interface(input logic clk);
    import mvu_pkg::*;
    import rv32_pkg::*;
    import pito_pkg::*;
    //=======================================
    //          PITO Interface
    //=======================================
    input  logic                      rst_n;
    input  rv32_imem_addr_t           pito_imem_addr;
    input  rv32_instr_t               pito_imem_data;
    input  rv32_dmem_addr_t           pito_dmem_addr;
    input  rv32_data_t                pito_dmem_data;
    input  logic                      pito_imem_w_en;
    input  logic                      pito_dmem_w_en;
    input  logic                      pito_pito_program;
    //=======================================
    //          Data Transposer Interface
    //=======================================
    input  logic [     NMVU*31 : 0]  mvu_data_prec;
    input  logic [     NMVU*31 : 0]  mvu_data_baddr;
    input  logic [ NMVU*XLEN-1 : 0]  mvu_data_iword;
    input  logic [      NMVU-1 : 0]  mvu_data_start;
    output logic [      NMVU-1 : 0]  mvu_data_busy;
    //=======================================
    //          MVU Interface
    //=======================================
    input  logic [NMVU*BWBANKA-1  : 0] mvu_wrw_addr; // Weight memory: write address
    input  logic [NMVU*BWBANKW-1  : 0] mvu_wrw_word; // Weight memory: write word
    input  logic [        NMVU-1  : 0] mvu_wrw_en;   // Weight memory: write enable
    output logic [        NMVU-1  : 0] mvu_irq_tap;
    input  logic [        NMVU-1  : 0] mvu_rdc_en  ;// input  rdc_en;
    output logic [        NMVU-1  : 0] mvu_rdc_grnt;// output rdc_grnt;
    input  logic [NMVU*BDBANKA-1  : 0] mvu_rdc_addr;// input  rdc_addr;
    output logic [NMVU*BDBANKW-1  : 0] mvu_rdc_word;// output rdc_word;

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
};

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
};

endinterface