#include <pito.h>

// static void irq_handler(void) __attribute__ ((interrupt ("machine")));

extern void wait_for_mvu_irq();

void conv_0(){
    int input_addr = 0, output_addr = 0, weight_addr = 0;
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
    for (int i=0; i<32; i++){
        SET_CSR(CSR_MVUWBASEPTR, weight_addr);
        SET_CSR(CSR_MVUOBASEPTR, output_addr);
        SET_CSR(CSR_MVUIBASEPTR, input_addr);
        SET_CSR(CSR_MVUCOMMAND, 0x40000438); // counter=1080, mul_mode=1
        wait_for_mvu_irq();
        output_addr += 2;
        input_addr  += 64;
    }
}