`include "pito_inf.svh"
`include "matmul_tester.sv"


module testbench_top import utils::*;();
//==================================================================================================
// Test variables
    localparam CLOCK_SPEED = 50; // 10MHZ
    Logger logger;
    string sim_log_file = "testbench_top.log";
//==================================================================================================
    logic clk;
    barvinn_interface barvinn_intf(clk);
    pito_interface pito_intf(clk);
    mvu_interface mvu_intf(clk);
    barvinn barvinn_inst(.pito_intf(pito_intf),
                         .mvu_intf(mvu_intf),
                         .barvinn_intf(barvinn_intf));

    // interface_tester tb;
    matmul_tester tb;

    initial begin
        logger = new(sim_log_file);
        tb = new(logger, barvinn_intf.tb_interface, pito_intf.tb_interface);

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
        #1ms;
        $display("Simulation took more than expected ( more than 600ms)");
        $finish();
    end
endmodule
