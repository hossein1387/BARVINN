#include <pito.h>
#include <stdio.h>

#define N 8
extern int get_pito_hart_id();
extern void wait_for_mvu_irq();
extern void enable_mvu_irq();
extern void conv_0();
int loop_cnt=0;
int done = 0;
static void irq_handler(void) __attribute__ ((interrupt ("machine")));

void irq_handler(){
    // First things first, disable mvu interrupt ...
    // Clear peending interrup
    __asm__ volatile("addi t1, x0, 1 \n\t\
                     slli t1, t1, 16 \n\t\
                     csrc mip, t1");
    // printf("Done with loop %d\n", loop_cnt);
    // Enable global interrupt now that we are all done
    loop_cnt += 1;
    enable_mvu_irq();
}

void main_thread(const int hart_id){
    SET_CSR(mtvec, &irq_handler);
    enable_mvu_irq();
    printf("Waking up HART:%d\n", hart_id);
    while(done==0){
        if (hart_id==0){
            conv_0();
            done =1;
        }
    }
}

int main(){
    main_thread(get_pito_hart_id());
    return 0;
}
