import utils::*;

module testbench_top();
//==================================================================================================
// Test variables
    localparam CLOCK_SPEED = 50; // 10MHZ
    Logger logger;
    string sim_log_file = "testbench_top.log";
//==================================================================================================
    logic clk;
    pito_interface pito_inf(clk);
    mvu_interface mvu_inf(clk);
    accel_interface barvinn_inf(clk);
    barvinn barvinn_inst(.rv_intf(pito_inf),
                      .mvu_intf(mvu_inf),
                      .accel_inf(accel_inf));

    // interface_tester tb;
    core_tester tb;

    initial begin
        logger = new(sim_log_file);
        tb = new(logger, pito_inf.tb_interface);

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
