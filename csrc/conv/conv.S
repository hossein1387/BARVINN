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
addi  x4, x0, 4
addi  x8, x0, 8
addi  x16, x0, 16
add   x1, x1, x8               // set weight precision to 8
slli  x3, x4, 6                // set input precision to 4
add   x1, x1, x3
slli  x3, x16, 12              // set output precision to 16
add   x1, x1, x3
csrw  mvu_precision,  x1

addi  x1, x0, 15
csrw  mvu_quant     , x1       // set quant_msbidx to 16
csrwi mvu_wbaseaddr , 0        // set weight address to 0
csrwi mvu_ibaseaddr , 0        // set input address to 0

addi  x1, x0, 1
slli  x1, x1, 10               // set output address to 0x400
csrw mvu_obaseaddr , x1

csrwi mvu_wstride_0 ,  0       // 1 tile back move x 2 bits
csrwi mvu_wstride_1 ,  0       // 1 tile ahead move x 2 bits
csrwi mvu_wstride_2 ,  0 
csrwi mvu_wstride_3 ,  0
csrwi mvu_istride_0 ,  0       // 1 tile back move x 2 bits 
csrwi mvu_istride_1 ,  0 
csrwi mvu_istride_2 ,  0 
csrwi mvu_istride_3 ,  0 
csrwi mvu_ostride_0 ,  0 
csrwi mvu_ostride_1 ,  0 
csrwi mvu_ostride_2 ,  0 
csrwi mvu_ostride_3 ,  0 
csrwi mvu_wlength_0 ,  0       // 2 tiles in width
addi  x1, x0,  31              // number bit combinations i.e. 2x2 bits
csrw mvu_wlength_1 , x1
csrwi mvu_wlength_2 ,  0       // 2 tiles in height
csrwi mvu_wlength_3 ,  0
csrwi mvu_ilength_0 ,  0       // 2 tiles in height
csrwi mvu_ilength_1 ,  0       // number bit combinations
csrwi mvu_ilength_2 ,  0       // 2 tiles in width of matrix operand
csrwi mvu_ilength_3 ,  0       
csrwi mvu_olength_0 ,  1 
csrwi mvu_olength_1 ,  0 
csrwi mvu_olength_2 ,  0 
csrwi mvu_olength_3 ,  0 

addi x1, x0, 1
slli x1, x1, 30                // mul mode 01
addi x1, x1, 32
csrw mvu_command, x1           // Kick start MVU, 2 tiles x 2 tiles x 2bit x 2bits

ebreak
