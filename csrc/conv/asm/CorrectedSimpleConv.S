#*****************************************************************************
# Template file for auto code generation
# DO NOT MODIFY
#*****************************************************************************
# This is a demo code to compute a 2d Convolution of following size:
# input: 1x64x32x32
# weight: 64x64x3x3
# output: 1x64x32x32
# padding: 1
# stride: 1
# ilength[4]=         0, ilength[3]=         2, ilength[2]=         2, ilength[1]=         3
# ijump[4]  =         0, ijump[3]  =         2, ijump[2]  =        60, ijump[1]  =      -132, ijump[0]  =      -132
# wlength[4]=         0, wlength[3]=         8, wlength[2]=         3, wlength[1]=         0
# wjump[4]  =         0, wjump[3]  =         2, wjump[2]  =       -16, wjump[1]  =         2, wjump[0]  =       -16
# slength[4]=         0, slength[3]=         0, slength[2]=         0, slength[1]=         0
# sjump[4]  =         0, sjump[3]  =         0, sjump[2]  =         0, sjump[1]  =         1, sjump[0]  =         0
# blength[4]=         0, blength[3]=         0, blength[2]=         0, blength[1]=         0
# bjump[4]  =         0, bjump[3]  =         0, bjump[2]  =         0, bjump[1]  =         1, bjump[0]  =         0
# ioffset=0, woffset=0, countdown=1080

#include "pito_def.h"

.globl _start
.globl _prog_end
.globl _fail

.section .text;
.section .text.init;
j reset_vector

reset_vector:
    li      x1, 0
    li      x4, 0
    li      x5, 0
    li      x6, 0
    li      x7, 0
    li      x8, 0
    li      x9, 0
    li      x10, 0
    li      x11, 0
    li      x12, 0
    li      x13, 0
    li      x14, 0
    li      x15, 0
    li      x16, 0
    li      x17, 0
    li      x18, 0
    li      x19, 0
    li      x20, 0
    li      x10, 0
    li      x21, 0
    li      x22, 0
    li      x23, 0
    li      x24, 0
    li      x25, 0
    li      x26, 0
    li      x27, 0
    li      x28, 0
    li      x29, 0
    li      x30, 0
    li      x31, 0
    li      sp, 0x00003fc # set sp to the end of the memory
    la      t0, main
    csrw    mepc, t0
    mret

main:
    addi sp, sp, -4
    sw ra, 4(sp)
    jal __startup_code__
    jal Conv_0
    lw ra, 4(sp)
    addi sp, sp, 4
    j _prog_end

# in startup code, we need to set the following:
#   -> mtvec addresses
__startup_code__:
    # creating mtvec mask
    addi sp, sp, -4
    sw ra, 4(sp)
    jal enable_mvu_irq
    lui  a0, %hi(mvu_irq_handler)
    addi a0, a0, %lo(mvu_irq_handler )
    csrw mtvec, a0
    lw ra, 4(sp)
    addi sp, sp, 4
    ret

wait_for_mvu_irq:
    addi sp, sp, -24
    sw ra, 4(sp)
    sw s0, 8(sp)
    sw s1, 12(sp)
    sw s2, 16(sp)
    sw s3, 20(sp)
    sw s4, 24(sp)
wait_for_mvu_irq_loop:
    csrr t0, mcause
    srli t0, t0, 31
    addi t1, x0, 1
    # wait for mcause[31] interrupt to go high
    bne t0, t1, wait_for_mvu_irq_loop
    # Clear interrup cause
    csrw mcause, x0
    lw ra, 4(sp)
    lw s0, 8(sp)
    lw s1, 12(sp)
    lw s2, 16(sp)
    lw s3, 20(sp)
    lw s4, 24(sp)
    addi sp, sp, 24
    ret

mvu_irq_handler:
    # make sure global interrupt is disabled
    csrwi mstatus, 0x0
    # first things first, clear mvu intterupts pending bit while processing current irq.
    addi t1, x0, 1
    slli t1, t1, 16
    csrc mip, t1
    # do whatever to make MVU happy
    addi x0, x0, 0
    # we can now start processing incoming interrupts
    jal enable_mvu_irq
    mret

enable_mvu_irq:
    addi sp, sp, -4
    sw ra, 4(sp)
    # make sure global interrupt is enabled
    csrwi mstatus, 0x8
    # set MVU specific MIE bit aka mie[16]
    addi t0, x0, 1
    slli t0, t0, 16
    csrw mie, t0
    addi ra, sp, 0
    lw ra, 4(sp)
    addi sp, sp, 4
    ret

disable_mvu_irq:
    addi sp, sp, -4
    sw ra, 4(sp)
    # clear MVU specific MIE bit
    addi t0, x0, 1
    slli t0, t0, 16
    not t0, t0
    csrw mie, t0
    addi ra, sp, 0
    lw ra, 4(sp)
    addi sp, sp, 4
    ret

clear_mvu_pending_irq:
    addi sp, sp, -4
    sw ra, 4(sp)
    csrrci x0, mip, 0
    lw ra, 4(sp)
    addi sp, sp, 4
    ret

Conv_0:
    addi sp, sp, -4
    sw ra, 4(sp)
    jal Conv_0_init
    jal Conv_0_loop
    lw ra, 4(sp)
    addi sp, sp, 4
    ret

Conv_0_init:
    addi sp, sp, -4
    sw ra, 4(sp)
    addi  t1, x0, 0
    addi  t2, x0, 2
    add   t1, t1, t2
    addi  t2, x0, 2
    slli  t3, t2, 6
    add   t1, t1, t3
    addi  t2, x0, 2
    slli  t3, t2, 12
    add   t1, t1, t3
    csrw  mvuprecision,  t1
    csrwi mvuilength_4, 0
    csrwi mvuilength_3, 2
    csrwi mvuilength_2, 2
    csrwi mvuilength_1, 3

    csrwi mvuijump_4, 0
    csrwi mvuijump_3, 2
    li t0, 60
    csrw mvuijump_2, t0
    li t0, -132
    csrw mvuijump_1, t0
    li t0, -132
    csrw mvuijump_0, t0
    
    csrwi mvuwlength_4, 0
    csrwi mvuwlength_3, 8
    csrwi mvuwlength_2, 3
    csrwi mvuwlength_1, 0
    
    csrwi mvuwjump_4, 0
    csrwi mvuwjump_3, 2
    li t0, -16
    csrw mvuwjump_2, t0
    csrwi mvuwjump_1, 2
    li t0, -16
    csrw mvuwjump_0, t0

    lw ra, 4(sp)
    addi sp, sp, 4
    ret

# we are using 5 S registers that we should keep their content
# throughout the code:
# s0: loop counter
# s1: loop counter for output address
# s2: loop counter for weight address
# s3: loop counter for input address
# s4: kick start command

Conv_0_loop:
    addi sp, sp, -4
    sw ra, 4(sp)
    addi s0, x0, 32
    li s1, 0
    li s2, 0
    li s3, 0
    addi s4, x0, 1
    slli s4, s4, 30
    li t0, 1080
    add s4, s4, t0
    # Each loop iteration, MVU produces 1 row of the output feature map
    # The output size is 1x64x32x32 and 1 row of the output feature map with 
    # NHWC format will be 1x64x1x32, hence, we need to loop 32 times
loop:
    csrwi mvuquant, 7
    csrw mvuwbaseptr, s2
    csrw mvuibaseptr, s3
    csrw mvuobaseptr , s1
    csrw mvucommand, s4
    jal wait_for_mvu_irq
    addi s0,s0, -1 
# At every loop iteration, we need to store the output result in output ram,
# based on the output precision, we should update output address with a
# step size of 32*oprec (256 = 32*8) 
    addi s1, s1, 64
    addi s3, s3, 2
    bne s0, x0, loop
    lw ra, 4(sp)
    addi sp, sp, 4
    ret

# Done with our awesome program!
_prog_end:
    lui a0,0x10000000>>12
    addi  a1,zero,'O'
    addi  a2,zero,'K'
    addi  a3,zero,'\n'
    sw  a1,0(a0)
    sw  a2,0(a0)
    sw  a3,0(a0)
    ebreak

_fail:
    lui a0,0x10000000>>12
    addi  a1,zero,'N'
    addi  a2,zero,'O'
    addi  a3,zero,'K'
    addi  a4,zero,'\n'
    sw  a1,0(a0)
    sw  a2,0(a0)
    sw  a3,0(a0)
    sw  a4,0(a0)
    ebreak

.section .data

