#include <pito.h>
#include <stdio.h>
#include "conv2d.h"

#define NUM_HARTS 8
extern int get_pito_hart_id();
extern void wait_for_mvu_irq();
extern void enable_mvu_irq();
static void irq_handler(void) __attribute__ ((interrupt ("machine")));

int layer_out_row_size[] = {4, 4, 4, 4, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0};
int layer_blk_size_kb[] = {9, 9, 9, 9, 18, 36, 36, 36, 72, 144, 144, 144, 288, 576, 576, 576};
// int layer_out_row_size[] = {32, 32, 32, 32, 16, 16, 16, 16, 8, 8, 8, 8, 4, 4, 4, 4};
// int layer_loop_lebgth = [];

void irq_handler(){
    // First things first, disable mvu interrupt ...
    // Clear peending interrup
    __asm__ volatile("addi t1, x0, 1 \n\t\
                     slli t1, t1, 16 \n\t\
                     csrc mip, t1");
    enable_mvu_irq();
}

// void dma_load_data(int hart_id, int src_addr, int dst_addr, int blksize){
//     // This funciton will trigger a DMA read from host.
//     // src_addr: Host source address.
//     // dst_addr: MVU destination address.
//     // blksize: Chunk of memory to load from host
//     // The DMA engine, expects destination address and block size
//     // to be written to t0 and t1 respectively.
//     SET_CSR(CSR_DMADSTADDR, dst_addr);
//     SET_CSR(CSR_DMABLKSIZE, blksize);
//     __asm__ volatile("lw t0, %0" : "=m" (src_addr));
//     // technically we should wait for a DMA interrupt
//     // wait_for_dma_irq();
// }

void main_thread(const int hart_id){
    int iaddr, oaddr, waddr;
    int wbase_addr = 0;
    int iofst=0, oofst=0, wofst=0;

    SET_CSR(mtvec, &irq_handler);
    enable_mvu_irq();
    // dma_load_data(hart_id, wbase_addr, wofst, layer_blk_size_kb[0]);
    wbase_addr += layer_blk_size_kb[0];
    conv3x3_64(hart_id, iofst, oofst, wofst, layer_out_row_size[0], &iaddr, &oaddr, &waddr);
    iofst += *(&iaddr);
    oofst += *(&oaddr);
    wofst += *(&waddr);
    // load_weigths(hart_id);

    // dma_load_data(hart_id, wbase_addr, wofst, layer_blk_size_kb[1]);
    wbase_addr += layer_blk_size_kb[1];
    conv3x3_64(hart_id, iofst,oofst,wofst, layer_out_row_size[1], &iaddr, &oaddr, &waddr);
    iofst += *(&iaddr);
    oofst += *(&oaddr);
    wofst += *(&waddr);

    if (hart_id==0){
        printf("%d, %d, %d\n", iofst, oofst, wofst);
    }
    // while(1){};
}

int main(){
    main_thread(get_pito_hart_id());
    return 0;
}
