#ifndef CONV2D_H
#define CONV2D_H

#include <pito.h>

#define CALC_MEM_OFFSET(JUMP, HART_ID, OFFSET) (JUMP*HART_ID+OFFSET)
#define CALC_OMVU_SEL(HART_ID) (1<<HART_ID)

extern void wait_for_mvu_irq();

void conv3x3_64(int hart_id, int iofst, int oofst, int wofst, int hart_loop_length, int* final_iaddr, int* final_oaddr, int* final_waddr);
#ifdef STREAM
    void conv3x3_64_stream(int hart_id, int iofst, int oofst, int wofst, int hart_loop_length, int* final_iaddr, int* final_oaddr, int* final_waddr);
#endif

#endif
