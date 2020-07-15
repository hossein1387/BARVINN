#include "pito_def.h"

csrr t1, mstatus
csrr t2, misa
csrr t3, mhartid

csrwi mvu_wprecision,  2 
csrwi mvu_iprecision,  2 
csrwi mvu_oprecision,  2
csrwi mvu_wstride_0 , 30       // 1 tile back move x 2 bits
csrwi mvu_wstride_1 ,  2       // 1 tile ahead move x 2 bits
csrwi mvu_wstride_2 ,  0 
csrwi mvu_istride_0 , 30       // 1 tile back move x 2 bits 
csrwi mvu_istride_1 ,  0 
csrwi mvu_istride_2 , 30 
csrwi mvu_ostride_0 ,  0 
csrwi mvu_ostride_1 ,  0 
csrwi mvu_ostride_2 ,  0 
csrwi mvu_wlength_0 ,  1       // 2 tiles in width
csrwi mvu_wlength_1 ,  3       // number bit combinations i.e. 2x2 bits
csrwi mvu_wlength_2 ,  1       // 2 tiles in height
csrwi mvu_ilength_0 ,  1       // 2 tiles in height
csrwi mvu_ilength_1 ,  0       // number bit combinations
csrwi mvu_ilength_2 ,  0       // 2 tiles in width of matrix operand
csrwi mvu_olength_0 ,  1 
csrwi mvu_olength_1 ,  0 
csrwi mvu_olength_2 ,  0 
csrwi mvu_countdown , 16        // Kick start MVU, 2 tiles x 2 tiles x 2bit x 2bits
ebreak

