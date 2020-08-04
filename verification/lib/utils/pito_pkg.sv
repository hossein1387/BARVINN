package pito_pkg;
    localparam int NUM_HARTS      = 8;
    localparam int HART_CNT_WIDTH = $clog2(NUM_HARTS);


    localparam bit RVA = 1'b0; // Is Atomic extension enabled
    localparam bit RVC = 1'b0; // Is Compressed extension enabled
    localparam bit RVD = 1'b0; // Is Double extension enabled
    localparam bit RVF = 1'b0; // Is Float extension enabled
    localparam bit RVI = 1'b1; // Is Integer extension enabled
    localparam bit RVM = 1'b0; // Is M extension enabled

    localparam logic [31:0] ISA_CODE =         (RVA <<  0)  // A - Atomic Instructions extension
                                             | (RVC <<  2)  // C - Compressed extension
                                             | (RVD <<  3)  // D - Double precsision floating-point extension
                                             | (RVF <<  5)  // F - Single precsision floating-point extension
                                             | (RVI <<  8)  // I - RV32I/64I/128I base ISA
                                             | (RVM << 12)  // M - Integer Multiply/Divide extension
                                             | (0   << 13)  // N - User level interrupts supported
                                             | (0   << 18)  // S - Supervisor mode implemented
                                             | (1   << 20)  // U - User mode implemented
                                             | (0   << 23)  // X - Non-standard extensions present
                                             | (1   << (`XPR_LEN-2)); // RV32
    localparam logic [31:0] PITO_MARCHID  = `XPR_LEN'h8C100;

//-------------------------------------------------------------------
//                     PITO Control Status Registers
//-------------------------------------------------------------------
    typedef enum logic [11:0] {
        // RV32I Machine Mode CSRs 0-31
        // Machine Information Registers
        CSR_MVENDORID      = 12'hF11,
        CSR_MARCHID        = 12'hF12,
        CSR_MIMPID         = 12'hF13,
        CSR_MHARTID        = 12'hF14,

        // Machine Trap Setup
        CSR_MSTATUS        = 12'h300,
        CSR_MISA           = 12'h301,
        CSR_MIE            = 12'h304,
        CSR_MTVEC          = 12'h305,

        //Machine Trap Handling
        CSR_MSCRATCH       = 12'h340,
        CSR_MEPC           = 12'h341,
        CSR_MCAUSE         = 12'h342,
        CSR_MTVAL          = 12'h343,
        CSR_MIP            = 12'h344,

        //Machine Counter/Timers
        CSR_MCYCLE         = 12'hB00,
        CSR_MINSTRET       = 12'hB02,
        CSR_MCYCLEH        = 12'hB80,
        CSR_MINSTRETH      = 12'hB82,

        CSR_MCALL          = 12'hB0C,  // Procedure call
        CSR_MRET           = 12'hB0D,  // Procedure Return

        // MVU CSRs            
        CSR_MVU_WBASEADDR  = 12'hF20,            // Config: weight memory base address
        CSR_MVU_IBASEADDR  = 12'hF21,            // Config: data memory base address for input
        CSR_MVU_OBASEADDR  = 12'hF22,            // Config: data memory base address for output
        CSR_MVU_WSTRIDE_0  = 12'hF23,            // Config: weight stride in dimension 0 (x)
        CSR_MVU_WSTRIDE_1  = 12'hF24,            // Config: weight stride in dimension 1 (y)
        CSR_MVU_WSTRIDE_2  = 12'hF25,            // Config: weight stride in dimension 2 (z)
        CSR_MVU_ISTRIDE_0  = 12'hF26,            // Config: input stride in dimension 0 (x)
        CSR_MVU_ISTRIDE_1  = 12'hF27,            // Config: input stride in dimension 1 (y)
        CSR_MVU_ISTRIDE_2  = 12'hF28,            // Config: input stride in dimension 2 (z)
        CSR_MVU_OSTRIDE_0  = 12'hF29,            // Config: output stride in dimension 0 (x)
        CSR_MVU_OSTRIDE_1  = 12'hF2A,            // Config: output stride in dimension 1 (y)
        CSR_MVU_OSTRIDE_2  = 12'hF2B,            // Config: output stride in dimension 2 (z)
        CSR_MVU_WLENGTH_0  = 12'hF2C,            // Config: weight length in dimension 0 (x)
        CSR_MVU_WLENGTH_1  = 12'hF2D,            // Config: weight length in dimension 1 (y)
        CSR_MVU_WLENGTH_2  = 12'hF2E,            // Config: weight length in dimension 2 (z)
        CSR_MVU_ILENGTH_0  = 12'hF2F,            // Config: input length in dimension 0 (x)
        CSR_MVU_ILENGTH_1  = 12'hF30,            // Config: input length in dimension 1 (y)
        CSR_MVU_ILENGTH_2  = 12'hF31,            // Config: input length in dimension 2 (z)
        CSR_MVU_OLENGTH_0  = 12'hF32,            // Config: output length in dimension 0 (x)
        CSR_MVU_OLENGTH_1  = 12'hF33,            // Config: output length in dimension 1 (y)
        CSR_MVU_OLENGTH_2  = 12'hF34,            // Config: output length in dimension 2 (z)
        CSR_MVU_PRECISION  = 12'hF35,            // Config precision
        CSR_MVU_STATUS     = 12'hF36,            // MVU status register
        CSR_MVU_COMMAND    = 12'hF37,            // MVU command register
        CSR_MVU_QUANT      = 12'hF38             // Config quantizer
    } csr_t;


    typedef enum logic [2:0] {
        MRET           = 3'b000,
        CSR_READ_WRITE = 3'b001,
        CSR_SET        = 3'b010,
        CSR_CLEAR      = 3'b011,
        CSR_UNKNOWN    = 3'b111
    } csr_op_t;

//-------------------------------------------------------------------
//                     PITO Interrupt and Exception Codes
//-------------------------------------------------------------------
    localparam int unsigned IRQ_M_SOFT   = 3;
    localparam int unsigned IRQ_M_TIMER  = 7;
    localparam int unsigned IRQ_M_EXT    = 11;
    localparam int unsigned IRQ_MVU_INTR = 16;

    localparam logic [31:0] MIP_MSIP = 1 << IRQ_M_SOFT;
    localparam logic [31:0] MIP_MTIP = 1 << IRQ_M_TIMER;
    localparam logic [31:0] MIP_MEIP = 1 << IRQ_M_EXT;
    localparam logic [31:0] MIP_MVIP = 1 << IRQ_MVU_INTR;

    localparam logic [31:0] MACH_SW_INTR = (1 << 31) | IRQ_M_SOFT;  //Machine software interrupt
    localparam logic [31:0] MACH_T_INTR  = (1 << 31) | IRQ_M_TIMER; //Machine timer interrupt
    localparam logic [31:0] MACH_EX_INTR = (1 << 31) | IRQ_M_EXT;   //User software interrupt
    localparam logic [31:0] MVU_INTR     = (1 << 31) | IRQ_MVU_INTR;//MVU interrupt

    localparam logic [31:0] INSTR_ADDR_MISALIGNED = 0;  // Instruction address misaligned
    localparam logic [31:0] INSTR_ACCESS_FAULT    = 1;  // Instruction access fault
    localparam logic [31:0] ILLEGAL_INSTR         = 2;  // Illegal instruction
    localparam logic [31:0] LD_ADDR_MISALIGNED    = 4;  // Load address misaligned
    localparam logic [31:0] LD_ACCESS_FAULT       = 5;  // Load access fault
    localparam logic [31:0] ST_ADDR_MISALIGNED    = 6;  // Store/AMO address misaligned
    localparam logic [31:0] ST_ACCESS_FAULT       = 7;  // Store/AMO access fault
    localparam logic [31:0] ENV_CALL_MMODE        = 11; // environment call from machine mode //Reserved

endpackage