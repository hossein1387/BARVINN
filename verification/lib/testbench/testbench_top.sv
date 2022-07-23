// `include "matmul_tester.sv"
`include "conv_tester.sv"


module testbench_top import utils::*;();
//==================================================================================================
// Test variables
    localparam CLOCK_SPEED = 50; // 10MHZ
    Logger logger;
    string sim_log_file = "testbench_top.log";
//==================================================================================================
    logic clk;
    pito_soc_ext_interface pito_intf(clk);
    MVU_EXT_INTERFACE mvu_intf(clk);
    barvinn barvinn_inst(.pito_ext_intf(pito_intf),
                         .mvu_ext_intf(mvu_intf));
                     
    // interface_tester tb;
    conv_tester tb;

    initial begin
        logger = new(sim_log_file);
        tb = new(logger, mvu_intf, pito_intf);

        tb.tb_setup();
        tb.run();
        tb.report();
        $finish();

    end

//==================================================================================================
// Simulation specific Threads

    initial begin 
        $timeformat(-9, 2, " ns", 12);
        clk   = 0;
        forever begin
            #((CLOCK_SPEED)*1ns) clk = !clk;
        end
    end

    initial begin
        #1000ms;
        $display("Simulation took more than expected ( more than 600ms)");
        $finish();
    end
endmodule
