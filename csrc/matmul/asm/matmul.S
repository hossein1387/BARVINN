#include "pito.h"

jal sp, enable_mvu_irq
jal sp, __startup_code__
jal sp, mat_mul
jal t3, wait_for_mvu_irq
jal sp, prog_end


// in startup code, we need to set the following:
//   -> mtvec addresses
//
__startup_code__:
    // addi x1, x0, pito_mtvec_mask
    // creating mtvec mask
    lui  a0, %hi(mvu_irq_handler)
    addi a0, a0, %lo(mvu_irq_handler )
    csrw mtvec, a0
    addi ra, sp, 0
    ret

wait_for_mvu_irq:
    csrr t0, mcause
    srli t0, t0, 31
    addi t1, x0, 1
    // wait for mcause[31] interrupt to go high
    bne t0, t1, wait_for_mvu_irq
    addi ra, t3, 0
    ret

mvu_irq_handler:
    // make sure global interrupt is disabled
    csrwi mstatus, 0x0
    // first things first, clear mvu intterupts pending bit while processing current irq.
    addi t1, x0, 1
    slli t1, t1, 16
    csrc mip, t1
    // do whatever to make MVU happy
    addi x0, x0, 0
    // we can now start processing incoming interrupts
    addi gp, sp, 0
    jal sp, enable_mvu_irq
    addi ra, gp, 0
    mret

enable_mvu_irq:
    // make sure global interrupt is enabled
    csrwi mstatus, 0x8
    // set MVU specific MIE bit aka mie[16]
    addi t0, x0, 1
    slli t0, t0, 16
    csrw mie, t0
    addi ra, sp, 0
    ret

disable_mvu_irq:
    // clear MVU specific MIE bit
    addi t0, x0, 1
    slli t0, t0, 16
    not t0, t0
    csrw mie, t0
    addi ra, sp, 0
    ret

clear_mvu_pending_irq:
    csrrci x0, mip, 0
    ret

mat_mul:
    addi  t1, x0, 0
    addi  t2, x0, 2
    add   t1, t1, t2               // set weight precision to 2
    slli  t3, t2, 6                // set input precision to 2
    add   t1, t1, t3
    slli  t3, t2, 12                // set output precision to 2
    add   t1, t1, t3
    csrw  CSR_MVUPRECISION,  t1

    csrwi CSR_MVUQUANT     , 10       // set quant_msbidx to 10
    csrwi CSR_MVUWBASEPTR  , 0        // set weight address to 0
    csrwi CSR_MVUIBASEPTR  , 0        // set input address to 0

    addi  t1, x0, 1
    slli  t1, t1, 10               // set output address to 0x400
    # csrw mvuobaseptr , t1

    csrwi CSR_MVUWJUMP_0, 30           // 1 tile back move x 2 bits
    csrwi CSR_MVUWJUMP_1, 2            // 1 tile ahead move x 2 bits
    csrwi CSR_MVUWJUMP_2, 0
    csrwi CSR_MVUWJUMP_3, 0
    csrwi CSR_MVUWJUMP_4, 0
    csrwi CSR_MVUIJUMP_0, 30           // 1 tile back move x 2 bits
    csrwi CSR_MVUIJUMP_1, 0
    csrwi CSR_MVUIJUMP_2, 0
    csrwi CSR_MVUIJUMP_3, 0
    csrwi CSR_MVUIJUMP_4, 0
    csrwi CSR_MVUSJUMP_0, 0
    csrwi CSR_MVUSJUMP_1, 0
    csrwi CSR_MVUBJUMP_0, 0
    csrwi CSR_MVUBJUMP_1, 0
    csrwi CSR_MVUOJUMP_0, 0
    csrwi CSR_MVUOJUMP_1, 0
    csrwi CSR_MVUOJUMP_2, 0
    csrwi CSR_MVUOJUMP_3, 0
    csrwi CSR_MVUOJUMP_4, 0
    csrwi CSR_MVUWLENGTH_1 ,  1       // 2 tiles in width
    csrwi CSR_MVUWLENGTH_2 ,  3       // number bit combinations i.e. 2x2 bits
    csrwi CSR_MVUWLENGTH_3 ,  1       // 2 tiles in height
    csrwi CSR_MVUWLENGTH_4 ,  0
    csrwi CSR_MVUILENGTH_1 ,  1       // 2 tiles in height
    csrwi CSR_MVUILENGTH_2 ,  0       // number bit combinations
    csrwi CSR_MVUILENGTH_3 ,  0       // 2 tiles in width of matrix operand
    csrwi CSR_MVUILENGTH_4 ,  0
    csrwi CSR_MVUOLENGTH_1 ,  1
    csrwi CSR_MVUOLENGTH_2 ,  0
    csrwi CSR_MVUOLENGTH_3 ,  0
    csrwi CSR_MVUOLENGTH_4 ,  0

    addi t1, x0, 1
    slli t1, t1, 30                // mul mode 01
    addi t1, t1, 16
    csrw CSR_MVUCOMMAND, t1           // Kick start MVU, 2 tiles x 2 tiles x 2bit x 2bits
    addi ra, sp, 0
    ret

// Done with our awesome program!
prog_end:
    lui a0,0x10000000>>12
    addi  a1,zero,'O'
    addi  a2,zero,'K'
    addi  a3,zero,'\n'
    sw  a1,0(a0)
    sw  a2,0(a0)
    sw  a3,0(a0)
    ebreak
