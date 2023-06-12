
module pito_mem_subsystem import rv32_pkg::*;import pito_pkg::*;
#(
    parameter int unsigned AxiIdWidth           = 6,
    parameter int unsigned AxiAddrWidth         = 32,
    parameter int unsigned AxiDataWidth         = 32,
    parameter int unsigned AxiUserWidth         = 1,
    // Dependant parameters. DO NOT CHANGE!
    localparam type        axi_data_t   = logic [AxiDataWidth-1:0],
    localparam type        axi_strb_t   = logic [AxiDataWidth/8-1:0],
    localparam type        axi_addr_t   = logic [AxiAddrWidth-1:0],
    localparam type        axi_user_t   = logic [AxiUserWidth-1:0],
    localparam type        axi_id_t     = logic [AxiIdWidth-1:0]
)(
    input  logic            clk_i,
    input  logic            rst_ni,
    output rv32_data_t      pito_dmem_wdata_o,
    input  rv32_data_t      pito_dmem_rdata_i,
    output rv32_dmem_addr_t pito_dmem_addr_o,
    output logic            pito_dmem_req_o,
    output logic            pito_dmem_we_o,
    output dmem_be_t        pito_dmem_be_o,
    output rv32_data_t      pito_imem_wdata_o,
    input  rv32_data_t      pito_imem_rdata_i,
    output rv32_imem_addr_t pito_imem_addr_o,
    output logic            pito_imem_req_o,
    output logic            pito_imem_we_o,
    output imem_be_t        pito_imem_be_o,
    output rv32_data_t      mvumem_wdata_o,
    input  rv32_data_t      mvumem_rdata_i,
    output rv32_imem_addr_t mvumem_addr_o,
    output logic            mvumem_req_o,
    output logic            mvumem_we_o,
    output imem_be_t        mvumem_be_o,
    AXI_BUS.Slave           m_axi
);
`include "axi/assign.svh"
`include "axi/typedef.svh"
`include "common_cells/registers.svh"

rv32_imem_addr_t pito_imem_addr, pito_dmem_addr;

assign pito_imem_addr_o = pito_imem_addr>>>2;
assign pito_dmem_addr_o = pito_dmem_addr>>>2;
//=================================================================================
//  Memory Regions  
//=================================================================================
localparam NrAXIMasters = 1; // Actually masters, but slaves on the crossbar

typedef enum int unsigned {
  IMEM   = 0,
  DMEM   = 1,
  MVU0MEM= 2,
  MVU1MEM= 3,
  MVU2MEM= 4,
  MVU3MEM= 5,
  MVU4MEM= 6,
  MVU5MEM= 7,
  MVU6MEM= 8,
  MVU7MEM= 9
} axi_slaves_e;
localparam NrAXISlaves = MVU7MEM + 1;

// Memory Map
localparam logic [31:0] DMEMLength   = 32'h2000;
localparam logic [31:0] IMEMLength   = 32'h2000;n
localparam logic [31:0] MVUMEMLength = 32'h0200_0000;

typedef enum logic [31:0] {
  IMEMBase     = 32'h0020_0000,
  DMEMBase     = 32'h0020_2000,
  MVU0MEMBase  = 32'h7000_0000,
  MVU1MEMBase  = 32'h7200_0000,
  MVU2MEMBase  = 32'h7400_0000,
  MVU3MEMBase  = 32'h7600_0000,
  MVU4MEMBase  = 32'h7800_0000,
  MVU5MEMBase  = 32'h7A00_0000,
  MVU6MEMBase  = 32'h7C00_0000,
  MVU7MEMBase  = 32'h7E00_0000
} soc_bus_start_e;

  // AXI Typedefs
`AXI_TYPEDEF_ALL(soc, axi_addr_t, axi_id_t, axi_data_t, axi_strb_t, axi_user_t)


  // Buses
soc_req_t  soc_axi_req;
soc_resp_t soc_axi_resp;

soc_req_t    [NrAXISlaves-1:0] periph_axi_req;
soc_resp_t   [NrAXISlaves-1:0] periph_axi_resp;


//=================================================================================
//  Crossbar
//=================================================================================

localparam axi_pkg::xbar_cfg_t XBarCfg = '{
  NoSlvPorts        : NrAXIMasters,
  NoMstPorts        : NrAXISlaves,
  MaxMstTrans       : 400,
  MaxSlvTrans       : 400,
  FallThrough       : 1'b0,
  LatencyMode       : axi_pkg::CUT_MST_PORTS,
  AxiIdWidthSlvPorts: AxiIdWidth,
  AxiIdUsedSlvPorts : AxiIdWidth,
  UniqueIds         : 1'b0,
  AxiAddrWidth      : AxiAddrWidth,
  AxiDataWidth      : AxiDataWidth,
  NoAddrRules       : NrAXISlaves
};

axi_pkg::xbar_rule_32_t [NrAXISlaves-1:0] routing_rules;
assign routing_rules = '{
  '{idx: IMEM,    start_addr: IMEMBase,    end_addr: IMEMBase    + IMEMLength},
  '{idx: DMEM,    start_addr: DMEMBase,    end_addr: DMEMBase    + DMEMLength},
  '{idx: MVU0MEM, start_addr: MVU0MEMBase, end_addr: MVU0MEMBase + MVUMEMLength}
  '{idx: MVU1MEM, start_addr: MVU1MEMBase, end_addr: MVU1MEMBase + MVUMEMLength}
  '{idx: MVU2MEM, start_addr: MVU2MEMBase, end_addr: MVU2MEMBase + MVUMEMLength}
  '{idx: MVU3MEM, start_addr: MVU3MEMBase, end_addr: MVU3MEMBase + MVUMEMLength}
  '{idx: MVU4MEM, start_addr: MVU4MEMBase, end_addr: MVU4MEMBase + MVUMEMLength}
  '{idx: MVU5MEM, start_addr: MVU5MEMBase, end_addr: MVU5MEMBase + MVUMEMLength}
  '{idx: MVU6MEM, start_addr: MVU6MEMBase, end_addr: MVU6MEMBase + MVUMEMLength}
  '{idx: MVU7MEM, start_addr: MVU7MEMBase, end_addr: MVU7MEMBase + MVUMEMLength}
};

axi_xbar #(
  .Cfg          (XBarCfg                ),
  .ATOPs        (1'b0                   ),
  .slv_aw_chan_t(soc_aw_chan_t          ),
  .mst_aw_chan_t(soc_aw_chan_t          ),
  .w_chan_t     (soc_w_chan_t           ),
  .slv_b_chan_t (soc_b_chan_t           ),
  .mst_b_chan_t (soc_b_chan_t           ),
  .slv_ar_chan_t(soc_ar_chan_t          ),
  .mst_ar_chan_t(soc_ar_chan_t          ),
  .slv_r_chan_t (soc_r_chan_t           ),
  .mst_r_chan_t (soc_r_chan_t           ),
  .slv_req_t    (soc_req_t              ),
  .slv_resp_t   (soc_resp_t             ),
  .mst_req_t    (soc_req_t              ),
  .mst_resp_t   (soc_resp_t             ),
  .rule_t       (axi_pkg::xbar_rule_32_t)
) i_soc_xbar (
  .clk_i                (clk_i           ),
  .rst_ni               (rst_ni          ),
  .test_i               (1'b0            ),
  .slv_ports_req_i      (soc_axi_req     ),
  .slv_ports_resp_o     (soc_axi_resp    ),
  .mst_ports_req_o      (periph_axi_req  ),
  .mst_ports_resp_i     (periph_axi_resp ),
  .addr_map_i           (routing_rules   ),
  .en_default_mst_port_i('0              ),
  .default_mst_port_i   ('0              )
);

`AXI_ASSIGN_TO_REQ(soc_axi_req, m_axi)
`AXI_ASSIGN_FROM_RESP(m_axi, soc_axi_resp)

//=================================================================================
//  AXI Peripherals
//=================================================================================

logic pito_imem_rvalid, pito_dmem_rvalid, imem_gnt, dmem_gnt;
  // One-cycle latency
`FF(pito_imem_rvalid, pito_imem_req_o, 1'b1);
`FF(pito_dmem_rvalid, pito_dmem_req_o, 1'b1);

// Instruction memory

assign imem_gnt = 1'b1; // Always available

axi_to_mem #(
  .AddrWidth   (AxiAddrWidth         ),
  .DataWidth   (AxiDataWidth         ),
  .IdWidth     (AxiIdWidth           ),
  .NumBanks    (1                    ),
  .axi_req_t   (soc_req_t            ),
  .axi_resp_t  (soc_resp_t           )
) i_axi_to_mem (
  .clk_i       (clk_i                ),
  .rst_ni      (rst_ni               ),
  .axi_req_i   (periph_axi_req[IMEM] ),
  .axi_resp_o  (periph_axi_resp[IMEM]),
  .mem_req_o   (pito_imem_req_o      ),
  .mem_gnt_i   (imem_gnt             ), // Always available
  .mem_we_o    (pito_imem_we_o       ),
  .mem_addr_o  (pito_imem_addr       ),
  .mem_strb_o  (pito_imem_be_o       ),
  .mem_wdata_o (pito_imem_wdata_o    ),
  .mem_rdata_i (pito_imem_rdata_i    ),
  .mem_rvalid_i(pito_imem_rvalid     ),
  .mem_atop_o  (/* Unused */         ),
  .busy_o      (/* Unused */         )
);


// Data memory

assign dmem_gnt = 1'b1; // Always available


axi_to_mem #(
  .AddrWidth   (AxiAddrWidth         ),
  .DataWidth   (AxiDataWidth         ),
  .IdWidth     (AxiIdWidth           ),
  .NumBanks    (1                    ),
  .axi_req_t   (soc_req_t            ),
  .axi_resp_t  (soc_resp_t           )
) d_axi_to_mem (
  .clk_i       (clk_i                ),
  .rst_ni      (rst_ni               ),
  .axi_req_i   (periph_axi_req[DMEM] ),
  .axi_resp_o  (periph_axi_resp[DMEM]),
  .mem_req_o   (pito_dmem_req_o      ),
  .mem_gnt_i   (dmem_gnt             ), // Always available
  .mem_we_o    (pito_dmem_we_o       ),
  .mem_addr_o  (pito_dmem_addr       ),
  .mem_strb_o  (pito_dmem_be_o       ),
  .mem_wdata_o (pito_dmem_wdata_o    ),
  .mem_rdata_i (pito_dmem_rdata_i    ),
  .mem_rvalid_i(pito_dmem_rvalid     ),
  .mem_atop_o  (/* Unused */         ),
  .busy_o      (/* Unused */         )
);

endmodule