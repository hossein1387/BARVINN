#include "conv2d.h"

#ifdef STREAM
void conv3x3_64_stream(int hart_id, int iofst, int oofst, int wofst, int hart_loop_length, int* final_iaddr, int* final_oaddr, int* final_waddr){
    int input_addr  = CALC_MEM_OFFSET(64, hart_id, iofst);
    int output_addr = CALC_MEM_OFFSET(2 , hart_id, oofst);
    int weight_addr = CALC_MEM_OFFSET(0 , hart_id, wofst);
    SET_CSR(CSR_MVUPRECISION, 0x2082); // setting 2 bit precision for input, weights and output
    SET_CSR(CSR_MVUILENGTH_4, 0);
    SET_CSR(CSR_MVUILENGTH_3, 2);
    SET_CSR(CSR_MVUILENGTH_2, 2);
    SET_CSR(CSR_MVUILENGTH_1, 3);
    SET_CSR(CSR_MVUIJUMP_4, 0);
    SET_CSR(CSR_MVUIJUMP_3, 2);
    SET_CSR(CSR_MVUIJUMP_2, 60);
    SET_CSR(CSR_MVUIJUMP_1, -132);
    SET_CSR(CSR_MVUIJUMP_0, -132);

    SET_CSR(CSR_MVUWLENGTH_4, 0);
    SET_CSR(CSR_MVUWLENGTH_3, 8);
    SET_CSR(CSR_MVUWLENGTH_2, 3);
    SET_CSR(CSR_MVUWLENGTH_1, 0);
    
    SET_CSR(CSR_MVUWJUMP_4, 0);
    SET_CSR(CSR_MVUWJUMP_3, 2);
    SET_CSR(CSR_MVUWJUMP_2, -16);
    SET_CSR(CSR_MVUWJUMP_1, 2);
    SET_CSR(CSR_MVUWJUMP_0, -16);
    SET_CSR(CSR_MVUQUANT, 7);

    SET_CSR(CSR_MVUOMVUSEL, CALC_OMVU_SEL(hart_id));


    for (int i=0; i<4; i++){
        SET_CSR(CSR_MVUWBASEPTR, weight_addr);
        SET_CSR(CSR_MVUOBASEPTR, output_addr);
        SET_CSR(CSR_MVUIBASEPTR, input_addr);
        SET_CSR(CSR_MVUCOMMAND, 0x40000087); // counter=135, mul_mode=1
        wait_for_mvu_irq();
        output_addr += 2;
        input_addr  += 64;
    }
    (*final_waddr) = weight_addr;
    (*final_oaddr) = output_addr;
    (*final_iaddr) = input_addr;
}
#endif

void conv3x3_64(int hart_id, int iofst, int oofst, int wofst, int hart_loop_length, int* final_iaddr, int* final_oaddr, int* final_waddr){
    #ifdef STREAM
        conv3x3_64_stream(hart_id, iofst, oofst, wofst, hart_loop_length, final_iaddr, final_oaddr, final_waddr);
    #elif BATCH
        conv3x3_64_batch(hart_id, iofst, oofst, wofst, hart_loop_length, final_iaddr, final_oaddr, final_waddr);
    #endif
}
