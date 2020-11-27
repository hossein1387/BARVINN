`timescale 1 ps / 1 ps

module data_transposer #(
    parameter  NUM_WORDS    =  64,   // Number of words needed before transpose 
    parameter  XLEN         =  32,   // Length of each input word
    parameter  MVU_ADDR_LEN =  32,   // MVU address length
    parameter  MVU_DATA_LEN =  32,   // MVU data length
    parameter  MAX_DATA_PREC=  8     // MAX data precision
)(
    input  logic                      clk,         // Clock
    input  logic                      rst_n,       // Asynchronous reset active low
    input  logic [31    : 0]          prec,        // Number of bits for each word
    input  logic [31    : 0]          baddr,       // Base address for writing the words
    input  logic [XLEN-1: 0]          iword,       // Base address for writing the words
    input  logic                      start,       // Start signal to indicate first word to be transposed
    output logic                      busy,        // A signal to indicate the status of the module
    output logic                      mvu_wr_en,   // MVU write enable to input RAM
    output logic [MVU_ADDR_LEN-1 : 0] mvu_wr_addr, // MVU write address to input RAM
    output logic [MVU_DATA_LEN-1 : 0] mvu_wr_word  // MVU write data to input RAM
);

    // local buffer 
    logic     [NUM_WORDS-1 : 0] buffer[MAX_DATA_PREC-1 : 0 ];
    logic [MAX_DATA_PREC-1 : 0] prec_reg;
    // buffer counter
    localparam CNT_LEN = $clog2(NUM_WORDS);
    logic [XLEN-1 : 0 ] rd_cnt;
    logic [XLEN-1 : 0 ] wd_cnt;
    // sliced value
    logic [NUM_WORDS-1 : 0] sliced_val;

    // ASM variables
    typedef enum logic[5:0] {IDLE, DATA_READ, TRANSPOSE} trans_state_t;
    trans_state_t next_state;

    function void transpose_write(int pos);
        for (int i=0; i<MAX_DATA_PREC; i++) begin
            // buffer[i] = sliced_val[i]<<(NUM_WORDS-pos-1) | buffer[i];
            buffer[i] = sliced_val[i]<<(pos) | buffer[i];
        end
    endfunction

    assign sliced_val = {{(NUM_WORDS-MAX_DATA_PREC){1'b0}}, iword[MAX_DATA_PREC-1:0]};
    assign mvu_wr_word= buffer[wd_cnt];

    always_ff @(posedge clk) begin
        if(~rst_n) begin
            busy      <= 0;
            mvu_wr_en <= 0;
            rd_cnt    <= 0;
            wd_cnt    <= 0;
            for (int i=0; i<MAX_DATA_PREC; i++) begin
                buffer[i] = {NUM_WORDS{1'b0}};
            end
        end else begin
            case (next_state)
                IDLE : begin
                    if(start==1'b1) begin
                        next_state <= DATA_READ;
                        rd_cnt     <= 0;
                        busy       <= 1'b1;
                        prec_reg   <= prec[MAX_DATA_PREC-1:0];
                        mvu_wr_addr<= baddr;
                    end else begin
                        next_state <= IDLE;
                    end
                end
                DATA_READ : begin
                    if(rd_cnt >NUM_WORDS) begin
                        next_state <= TRANSPOSE;
                        rd_cnt     <= 0;
                        wd_cnt     <= 0;
                        mvu_wr_en  <= 1'b1;
                    end else begin
                        transpose_write(rd_cnt );
                        rd_cnt     <= rd_cnt  + 1;
                        next_state <= DATA_READ;
                    end
                end
                TRANSPOSE: begin
                    if(wd_cnt >prec_reg) begin
                        wd_cnt     <= 0;
                        busy       <= 1'b0;
                        next_state <= IDLE;
                        mvu_wr_en  <= 1'b0;
                    end else begin
                        next_state <= TRANSPOSE;
                        wd_cnt     <= wd_cnt  + 1;
                        mvu_wr_addr<= mvu_wr_addr + 1;
                    end
                end
                default: begin
                    next_state <= IDLE;
                    wd_cnt     <= 0;
                    rd_cnt     <= 0;
                    busy       <= 0;
                end
            endcase
        end
    end
endmodule