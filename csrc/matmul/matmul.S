# See LICENSE for license details.

#*****************************************************************************
# mvu_csr.S
#-----------------------------------------------------------------------------
#
# Test csr instruction.
#

#include "pito_def.h"

  
#include "pito_def.h"

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

csrwi mvu_quant     , 10       // set quant_msbidx to 10
csrwi mvu_wbaseaddr , 0        // set weight address to 0
csrwi mvu_ibaseaddr , 0        // set input address to 0

addi  x1, x0, 1
slli  x1, x1, 10               // set output address to 0x400
csrw mvu_obaseaddr , x1

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
