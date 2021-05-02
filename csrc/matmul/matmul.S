# See LICENSE for license details.

#*****************************************************************************
# mvu_csr.S
#-----------------------------------------------------------------------------
#
# Test csr instruction.
#

#include "pito_def.h"

  
#include "pito_def.h"

#define mvuwbaseptr   0xF20 // Base address for weight memory
#define mvuibaseptr   0xF21 // Base address for input memory
#define mvusbaseptr   0xF22 // Base address for scaler memory (6 bits)
#define mvubbaseptr   0xF23 // Base address for bias memory (6 bits)
#define mvuobaseptr   0xF24 // Output base address
#define mvuwjump_0    0xF25 // Weight address jumps in loops 0
#define mvuwjump_1    0xF26 // Weight address jumps in loops 1
#define mvuwjump_2    0xF27 // Weight address jumps in loops 2
#define mvuwjump_3    0xF28 // Weight address jumps in loops 3
#define mvuwjump_4    0xF29 // Weight address jumps in loops 4
#define mvuijump_0    0xF2A // Input data address jumps in loops 0
#define mvuijump_1    0xF2B // Input data address jumps in loops 1
#define mvuijump_2    0xF2C // Input data address jumps in loops 2
#define mvuijump_3    0xF2D // Input data address jumps in loops 3
#define mvuijump_4    0xF2E // Input data address jumps in loops 4
#define mvusjump_0    0xF2F // Scaler memory address jumps (6 bits)
#define mvusjump_1    0xF30 // Scaler memory address jumps (6 bits)
#define mvubjump_0    0xF31 // Bias memory address jumps (6 bits)
#define mvubjump_1    0xF32 // Bias memory address jumps (6 bits)
#define mvuojump_0    0xF33 // Output data address jumps in loops 0
#define mvuojump_1    0xF34 // Output data address jumps in loops 1
#define mvuojump_2    0xF35 // Output data address jumps in loops 2
#define mvuojump_3    0xF36 // Output data address jumps in loops 3
#define mvuojump_4    0xF37 // Output data address jumps in loops 4
#define mvuwlength_1  0xF38 // Weight length in loops 0
#define mvuwlength_2  0xF39 // Weight length in loops 1
#define mvuwlength_3  0xF3A // Weight length in loops 2
#define mvuwlength_4  0xF3B // Weight length in loops 3
#define mvuilength_1  0xF3C // Input data length in loops 0
#define mvuilength_2  0xF3D // Input data length in loops 1
#define mvuilength_3  0xF3E // Input data length in loops 2
#define mvuilength_4  0xF3F // Input data length in loops 3
#define mvuslength_1  0xF40 // Scaler tensor length 15 bits
#define mvublength_1  0xF41 // Bias tensor length 15 bits
#define mvuolength_1  0xF42 // Output data length in loops 0
#define mvuolength_2  0xF43 // Output data length in loops 1
#define mvuolength_3  0xF44 // Output data length in loops 2
#define mvuolength_4  0xF45 // Output data length in loops 3
#define mvuprecision  0xF46 // Precision in bits for all tensors
#define mvustatus     0xF47 // Status of MVU
#define mvucommand    0xF48 // Kick to send command.
#define mvuquant      0xF49 // MSB index position
#define mvuscaler     0xF4A // fixed point operand for multiplicative scaling
#define mvuconfig1    0xF4B //Shift/accumulator load on jump select (only 0-4 valid) Pool/Activation clear on jump select (only 0-4 valid)


csrr t1, mstatus
csrr t2, misa
csrr t3, mhartid

addi  x1, x0, 0
addi  x2, x0, 2
add   x1, x1, x2               // set weight precision to 2
slli  x3, x2, 6                // set input precision to 2
add   x1, x1, x3
slli  x3, x2, 12                // set output precision to 2
add   x1, x1, x3
csrw  mvu_precision,  x1

csrwi mvuquant    , 10       // set quant_msbidx to 10
csrwi mvuwbaseptr , 0        // set weight address to 0
csrwi mvuibaseptr , 0        // set input address to 0

addi  x1, x0, 1
slli  x1, x1, 10               // set output address to 0x400
csrw mvuobaseptr , x1
csrwi mvu_wstride_0 , 30       // 1 tile back move x 2 bits
csrwi mvu_wstride_1 ,  2       // 1 tile ahead move x 2 bits
csrwi mvu_wstride_2 ,  0 
csrwi mvu_wstride_3 ,  0
csrwi mvu_istride_0 , 30       // 1 tile back move x 2 bits 
csrwi mvu_istride_1 ,  0 
csrwi mvu_istride_2 ,  0 
csrwi mvu_istride_3 , 30 
csrwi mvu_ostride_0 ,  0 
csrwi mvu_ostride_1 ,  0 
csrwi mvu_ostride_2 ,  0 
csrwi mvu_ostride_3 ,  0 
csrwi mvu_wlength_0 ,  1       // 2 tiles in width
csrwi mvu_wlength_1 ,  3       // number bit combinations i.e. 2x2 bits
csrwi mvu_wlength_2 ,  1       // 2 tiles in height
csrwi mvu_wlength_3 ,  0
csrwi mvu_ilength_0 ,  1       // 2 tiles in height
csrwi mvu_ilength_1 ,  0       // number bit combinations
csrwi mvu_ilength_2 ,  0       // 2 tiles in width of matrix operand
csrwi mvu_ilength_3 ,  0       
csrwi mvu_olength_0 ,  1 
csrwi mvu_olength_1 ,  0 
csrwi mvu_olength_2 ,  0 
csrwi mvu_olength_3 ,  0 

addi x1, x0, 1
slli x1, x1, 30                // mul mode 01
addi x1, x1, 16
csrw mvu_command, x1           // Kick start MVU, 2 tiles x 2 tiles x 2bit x 2bits
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop

ebreak
