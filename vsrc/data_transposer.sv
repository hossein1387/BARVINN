`timescale 1ns/1ps
    // Data transposer's job is to write input data (that is stored in a processor RAM
    // in linear format) into MVU RAM in a transposed format. The input word can be packed
    // of 2,4,8 or 16 bits data. Given the input data precision (prec) the transposer will
    // unpack, transpose and store them in the correct format. Once the MVU word is prepared,
    // data tranposer will go into busy state inwhich it will ignore any incoming new input 
    // data. At this point, the transposed data will be written into MVU word. Once complete, 
    // it will go back into IDLE state and it will wait for a new posedge on start signal to 
    // start the process all over again.
    //
    //      <----------XLEN---------->                                                                      
    //                         <prec>                <------------------------N-------------------------->  
    //      -------------------------     -           ---------------------------------------------------   
    //  0  |    |    |    |    |    |     |       0  | | | | | | | | | | | | | | | | | | | | | | | | | | |  
    //      -------------------------     |           ---------------------------------------------------   
    //  1  |    |    |    |    |    |     |       1  | | | | | | | | | | | | | | | | | | | | | | | | | | |  
    //      -------------------------     0       .   ---------------------------------------------------   
    //                ...                 |       .                          ...                            
    //      -------------------------     |       .   ---------------------------------------------------   
    //N-1  |    |    |    |    |    |     |  prec-1  | | | | | | | | | | | | | | | | | | | | | | | | | | |  
    //      -------------------------     -           ---------------------------------------------------   
    //                                    -           ---------------------------------------------------   
    //                                    |       0  | | | | | | | | | | | | | | | | | | | | | | | | | | |  
    //                                    |           ---------------------------------------------------   
    //                                    |       1  | | | | | | | | | | | | | | | | | | | | | | | | | | |  
    //                                    1       .   ---------------------------------------------------   
    //                                    |       .                          ...                            
    //                                    |       .   ---------------------------------------------------   
    //                                    |  prec-1  | | | | | | | | | | | | | | | | | | | | | | | | | | |  
    //                                    -           ---------------------------------------------------   
    //                                                                                                     
    //                                    -           ---------------------------------------------------   
    //                                    |       0  | | | | | | | | | | | | | | | | | | | | | | | | | | |  
    //                                    |           ---------------------------------------------------   
    //                                    |       1  | | | | | | | | | | | | | | | | | | | | | | | | | | |  
    //                            (XLEN/prec)-1   .   ---------------------------------------------------   
    //                                    |       .                          ...                            
    //                                    |       .   ---------------------------------------------------   
    //                                    |  prec-1  | | | | | | | | | | | | | | | | | | | | | | | | | | |  
    //                                    -           ---------------------------------------------------   

module data_transposer #(
    parameter  NUM_WORDS    =  64,   // Number of words needed before transpose 
    parameter  XLEN         =  32,   // Length of each input word
    parameter  MVU_ADDR_LEN =  15,   // MVU address length
    parameter  MVU_DATA_LEN =  64,   // MVU data length
    parameter  MAX_DATA_PREC=  16     // MAX data precision
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
    // GEN variables
    genvar i,j;

    // local buffer 
    logic     [NUM_WORDS-1 : 0] buffer[MAX_DATA_PREC-1 : 0 ];
    logic [MAX_DATA_PREC-1 : 0] prec_reg;
    // buffer counter
    localparam CNT_LEN = $clog2(NUM_WORDS);
    logic [XLEN-1 : 0 ] rd_cnt;
    logic [XLEN-1 : 0 ] wd_cnt;
    // sliced value
    logic [31:0] sliced2_val;
    logic [31:0] sliced4_val;
    logic [31:0] sliced8_val;
    logic [31:0] sliced16_val;
    logic [15:0] words2[1:0];
    logic [ 7:0] words4[3:0];
    logic [ 3:0] words8[7:0];
    logic [ 1:0] words16[15:0];

    // Local registers
    logic [XLEN-1 : 0 ] step;

    // Circuit to slice and concatenate every seconds bits from input iword into 2 vectors
    generate
        for (i = 0; i < 2; i = i + 1) begin
            for (j = 0; j < XLEN/2; j = j + 1) begin
                assign sliced2_val[i*(XLEN/2)+j] = iword[j*2+i];
            end
            assign words2[i] = sliced2_val[i*(XLEN/2) +:  (XLEN/2)];
        end
    endgenerate
    generate
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < XLEN/4; j = j + 1) begin
                assign sliced4_val[i*(XLEN/4)+j] = iword[j*4+i];
            end
            assign words4[i] = sliced4_val[i*(XLEN/4) +:  (XLEN/4)];
        end
    endgenerate
    generate
        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < XLEN/8; j = j + 1) begin
                assign sliced8_val[i*(XLEN/8)+j] = iword[j*8+i];
            end
            assign words8[i] = sliced8_val[i*(XLEN/8) +:  (XLEN/8)];
        end
    endgenerate
    generate
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < XLEN/16; j = j + 1) begin
                assign sliced16_val[i*(XLEN/16)+j] = iword[j*16+i];
            end
            assign words16[i] = sliced16_val[i*(XLEN/16) +:  (XLEN/16)];
        end
    endgenerate

    // Data needs to be stored in MVU in tranposed and MSB first. The buffer holds data in 
    // Transposed format, however, for writing to MVU, we need to write in MSB first format.
    // Hence for an N precision input array , the word stored at address 0 in the buffer needs 
    // to be written to N-1 etc.
    function void transpose_write(int pos);
        for (int i=0; i<prec_reg; i++) begin
            if (prec_reg==2) begin
                buffer[i] <= words2[i]<<(pos) | buffer[i];
            end else if (prec_reg==4) begin
                buffer[i] <= words4[i]<<(pos) | buffer[i];
            end else if (prec_reg==8) begin
                buffer[i] <= words8[i]<<(pos) | buffer[i];
            end else if (prec_reg==16) begin
                buffer[i] <= words16[i]<<(pos) | buffer[i];
            end
        end
    endfunction

    // ASM variables
    typedef enum logic[5:0] {IDLE, DATA_READ, TRANSPOSE} trans_state_t;
    trans_state_t next_state;


    // Writing buffer into MVU with MSB first format
    assign mvu_wr_word= buffer[prec_reg-wd_cnt-1];
    assign busy       = (rd_cnt >= NUM_WORDS-step) ? 1'b1 : 1'b0;
    always_comb begin 
        case (prec_reg)
                  2 : step = 16;
                  4 : step =  8;
                  8 : step =  4;
                 16 : step =  2;
            default : step =  4;
        endcase
    end

    always_ff @(posedge clk) begin
        if(~rst_n) begin
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
                        prec_reg   <= prec[MAX_DATA_PREC-1:0];
                        mvu_wr_addr<= baddr;
                    end else begin
                        next_state <= IDLE;
                    end
                end
                DATA_READ : begin
                    if(rd_cnt > NUM_WORDS-step) begin
                        next_state <= TRANSPOSE;
                        rd_cnt     <= 0;
                        wd_cnt     <= 0;
                        mvu_wr_en  <= 1'b1;
                    end else begin
                        transpose_write(rd_cnt);
                        rd_cnt     <= rd_cnt  + step;
                        next_state <= DATA_READ;
                    end
                end
                TRANSPOSE: begin
                    if(wd_cnt >=prec_reg-1) begin
                        wd_cnt     <= 0;
                        next_state <= IDLE;
                        mvu_wr_en  <= 1'b0;
                        for (int i=0; i<MAX_DATA_PREC; i++) begin
                            buffer[i] <= {NUM_WORDS{1'b0}};
                        end
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
                end
            endcase
        end
    end
endmodule
