`timescale 1 ps / 1 ps

import utils::*;

module transpose_tester();
//==================================================================================================
// Global Variables
    localparam CLOCK_SPEED   = 50; // 10MHZ
    localparam BDBANKA       = 15;
    localparam BDBANKW       = 64;
    localparam MAX_PRECISION = 16;
    localparam XLEN          = 32;

    Logger logger;
    string sim_log_file = "transpose_tester.log";
    logic [BDBANKA-1 : 0] mvu_addr;
//==================================================================================================
// DUT Signals
    logic                      clk;
    logic                      rst_n; 
    logic [31    : 0]          prec;
    logic [31    : 0]          baddr;
    logic [XLEN-1: 0]          iword;
    logic                      start;
    logic                      busy;
    logic                      mvu_wr_en;
    logic [     BDBANKA-1 : 0] mvu_wr_addr;
    logic [     BDBANKW-1 : 0] mvu_wr_word;

    data_transposer #(
        .NUM_WORDS    (BDBANKW       ),
        .XLEN         (XLEN          ),
        .MVU_ADDR_LEN (BDBANKA       ),
        .MVU_DATA_LEN (BDBANKW       ),
        .MAX_DATA_PREC(MAX_PRECISION ) 
    ) transposer
    (
        .clk        (clk        ),
        .rst_n      (rst_n      ),
        .prec       (prec       ),
        .baddr      (baddr      ),
        .iword      (iword      ),
        .start      (start      ),
        .busy       (busy       ),
        .mvu_wr_en  (mvu_wr_en  ),
        .mvu_wr_addr(mvu_wr_addr),
        .mvu_wr_word(mvu_wr_word)
);

    task automatic write_to_ram(string filename, Logger logger);
        data_q_t val_q;
        int word_cnt = 0;
        logger.print($sformatf("Parsing %s...", filename));
        val_q = datafile_to_q(filename, logger);
        logger.print($sformatf("Done Parsing %s", filename));
        logger.print($sformatf("Number of elements %d", val_q.size()));
        prec = 8;
        baddr = 0;
        start = 1'b1;
        @(posedge clk);
        while (word_cnt<val_q.size()) begin
        // for (int i =0; i<val_q.size(); i++) begin
            if (busy==1'b1) begin
                iword = 0;
            end else begin
                iword = val_q[word_cnt];
                word_cnt += 1;
            end
            @(posedge clk);
        end
        start = 1'b0;
        @(posedge clk);
    endtask

    initial begin
        logger = new(sim_log_file);
        rst_n = 1;
        @(posedge clk);
        rst_n = 0;
        start = 1'b0;
        #(10us);
        rst_n = 1;
        @(posedge clk);
        #(10us);
        write_to_ram("input.txt", logger);
    end

    initial begin 
        $timeformat(-9, 2, " ns", 12);
        clk   = 0;
        forever begin
            #((CLOCK_SPEED)*1ns) clk = !clk;
        end
    end

    initial begin
        #100ms;
        $display("Simulation took more than expected ( more than 600ms)");
        $finish();
    end
endmodule
