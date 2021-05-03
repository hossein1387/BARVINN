  #include "pito_def.h"

  jal sp, enable_mvu_irq
  jal sp, __startup_code__
  jal sp, mat_mul
  jal t3, wait_for_mvu_irq
  jal sp, prog_end


  // in startup code, we need to set the following:
  //   -> mtvec addresses
  //
  __startup_code__:
      // addi x1, x0, pito_mtvec_mask
      // creating mtvec mask
      lui  a0, %hi(mvu_irq_handler)
      addi a0, a0, %lo(mvu_irq_handler )
      csrw mtvec, a0
      addi ra, sp, 0
      ret

  wait_for_mvu_irq:
      csrr t0, mcause
      srli t0, t0, 31
      addi t1, x0, 1
      // wait for mcause[31] interrupt to go high
      bne t0, t1, wait_for_mvu_irq
      addi ra, t3, 0
      ret

  mvu_irq_handler:
      // make sure global interrupt is disabled
      csrwi mstatus, 0x0
      // first things first, clear mvu intterupts pending bit while processing current irq.
      addi x1, x0, 1
      slli x1, x1, 16
      csrc mip, x1
      // do whatever to make MVU happy 
      addi x0, x0, 0
      // we can now start processing incoming interrupts
      addi gp, sp, 0
      jal sp, enable_mvu_irq
      addi ra, gp, 0
      mret

  enable_mvu_irq:
      // make sure global interrupt is enabled
      csrwi mstatus, 0x8
      // set MVU specific MIE bit aka mie[16]
      addi t0, x0, 1
      slli t0, t0, 16
      csrw mie, t0
      addi ra, sp, 0
      ret

  disable_mvu_irq:
      // clear MVU specific MIE bit
      addi t0, x0, 1
      slli t0, t0, 16
      not t0, t0
      csrw mie, t0
      addi ra, sp, 0
      ret

  clear_mvu_pending_irq:
      csrrci x0, mip, 0
      ret

  mat_mul:
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

      ret

  // Done with our awesome program!
  prog_end:
      lui a0,0x10000000>>12
      addi  a1,zero,'O'
      addi  a2,zero,'K'
      addi  a3,zero,'\n'
      sw  a1,0(a0)
      sw  a2,0(a0)
      sw  a3,0(a0)
      ebreak

