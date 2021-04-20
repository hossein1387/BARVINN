Design
============

Top Module
-----------------
BARVINN is a Barrel RISC-V Neural Network Accelerator. The main purpose of designing BARVINN was to fill the need for arbitrary precision neural network accelerator. The overall architecture of BARVINN is illustrated below:

.. figure:: _static/BARVINN_TOP.png
  :width: 800
  :alt: Alternative text
  :name: fig_barvinn_top

  BARVINN overall architecture.


BARVINN is an FPGA proven accelerator. :numref:`fig_barvinn_top` illustrates the overall system design for BARVINN. It is consist of the following components:

- Array of Matrix Vector Units
- RISC-V Controller Core
- Host Machine

In the following sections, we will review each part in details. 



Matrix Vector Unit (MVU) Array
------------------------------

In the base configuration, BARVINN uses 8 MVUs. At every clock cycle, each MVU is capable of performing a ternary matrix vector product of the following size:

- Input Vector of 1 x 64 with 2 bit precision
- Weight Matrix of 64 x 64 with 1 bit precision

Each MVU has a local memory to store activation and weights. The MVUs are connected through a cross bar. The crossbar allows MVUs to send part of their local memory (activations) among themselves. This allows MVUs to work on different jobs with different configurations or to work together to compute a single task. 

.. figure:: _static/MVU_ARCH.png
  :width: 800
  :alt: Alternative text
  :name: mvu_arch

  This figure illustrates an MVU block diagram.


:numref:`mvu_arch` illustrates the block diagram of an MVU. Each MVU is consist of a Matrix Vector Product unit (MVP), Collision Detection Read Unit (CDRU), Collision Detection Write Unit (CDWU), activation ram, weight ram and a set of machine learning specific blocks such as quantizers, scaler units and pooling unit that can be switched on or off depending on the job configuration. As it can be seen in the :numref:`mvu_arch`, at each clock cycle, and MVU word (64 bits) is read from activation ram. At the same time, a long word of 4096 bits (64 by 64 ) is read from weight ram. This is then fed into MVP unit which can perform matrix vector product in one clock cycle. 

To be able to use this 


 Data transposer's job is to write input data (that is stored in a processor RAM in linear format) into MVU RAM in a transposed format. The input word can be packed
 of 2,4,8 or 16 bits data. Given the input data precision (prec) the transposer will unpack, transpose and store them in the correct format. Once the MVU word is prepared,
 data tranposer will go into busy state inwhich it will ignore any incoming new input  data. At this point, the transposed data will be written into MVU word. Once complete, it will go back into IDLE state and it will wait for a new posedge on start signal to start the process all over again.
 
.. figure:: _static/Data_transposer.png
  :width: 800
  :alt: Alternative text
  :name: data_transposer

  Data transposer modlue, this module will pack vectors of size `XLEN` in MSB first transposed format.


MVU Job Configuration:
^^^^^^^^^^^^^^^^^^^^^^^
MVUs are programmed to perfom a single job. A job is started by the controller by raising the `start` signal. Once the job is finished, the MVU will generate an interrupt, informing the controller that the requested job is finished and the results are ready to be sent back to host or to other MVUs. Once MVU is busy with a job, the `busy` signal is raised. During this time, MVU can be programmed for the next job but it raising the `start` signal will not initiate the job. 


.. figure:: _static/mvu_job_config.svg
  :width: 800
  :alt: Alternative text
  :name: mvu_job_config

  Timing diagram for configuring an MVU job.


:numref:`mvu_job_config` shows the timing diagram for sending a job to MVU. For sake of breavity, all config parameters are represented by `configs` signal. In the following sections, we will review what parameters that can be set in the MVU.

To submit a job to MVU, we first need to understand how the 

RISC-V Controller
-----------------
As mentioned earlier, MVU array has many configuration settings. We used a barrel RISC-V design as a controller to send control signals to each MVU. The connection between the controller and the MVU array is through control status registers (CSRs). 


Control Status Registers (RISC-V):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
+------+---------------+-----------------------+-----------------------------------------------------------------+
| ADRR | CSR           | RO/RW                 | Description                                                     |
+======+===============+=======================+=================================================================+
|0x301 | misa          | RO                    | A constant, but MSB = 0 for open-source implementation..        |
+------+---------------+-----------------------+-----------------------------------------------------------------+
|0xF11 | mvendorid     | RO/Zero               | Identification. Can be zero.                                    |
+------+---------------+-----------------------+-----------------------------------------------------------------+
|0xF12 | marchid       | RO/Zero               | Identification. Can be zero.                                    |
+------+---------------+-----------------------+-----------------------------------------------------------------+
|0xF13 | mimpid        | RO/Zero               | Identification. Can be zero.                                    |
+------+---------------+-----------------------+-----------------------------------------------------------------+
|0xF14 | mhartid       | RO, cycle counter % 8 | Shared with cycle counter.                                      |
+------+---------------+-----------------------+-----------------------------------------------------------------+
|0x300 | mstatus       | RW,                   | Critically-important bits like Global Interrupt Enables         |
|      |               | per-thread            |                                                                 |
+------+---------------+-----------------------+-----------------------------------------------------------------+
|0x305 | mtvec         | RO or RW if wanted    | Interrupt vector, or interrupt vector table base address.       |
|      |               |                       | Register is RW if we want to be able to choose between these    |
|      |               |                       | two modes, or change the address.                               |
+------+---------------+-----------------------+-----------------------------------------------------------------+
|0x344 | mip           | RO,                   | Pending interrupts bitfield                                     |
|      |               | per-thread            |                                                                 |
+------+---------------+-----------------------+-----------------------------------------------------------------+
|0x304 | mie           | RW,                   | Enabled interrupts bitfield                                     |
|      |               | per-thread            |                                                                 |
+------+---------------+-----------------------+-----------------------------------------------------------------+
|0xB00 | mcycle        | RW                    | Cycles counter, low 32 bits                                     |
|      |               | per-thread            |                                                                 |
+------+---------------+-----------------------+-----------------------------------------------------------------+
|0xB80 | mcycleh       | RW                    | Cycles counter, high 32 bits                                    |
|      |               | per-thread            |                                                                 |
+------+---------------+-----------------------+-----------------------------------------------------------------+
|0xB02 | minstret      | RW                    | Instructions retired counter, low 32 bits                       |
|      |               | per-thread            |                                                                 |
+------+---------------+-----------------------+-----------------------------------------------------------------+
|0xB82 | minstreth     | RW                    | Instructions retired counter, high 32 bits                      |
|      |               | per-thread            |                                                                 |
+------+---------------+-----------------------+-----------------------------------------------------------------+
|0xxxx | mhpm*         | RO/Zero               | High-performance counter control registers, not supported       |
+------+---------------+-----------------------+-----------------------------------------------------------------+
|0xxxx | mcountinhibit | RO/Zero               | High-performance counter inhibit, not supported                 |
+------+---------------+-----------------------+-----------------------------------------------------------------+
|0x340 | mscratch      | RW,                   | Scratch register, necessary to support interrupts               |
|      |               | per-thread            |                                                                 |
+------+---------------+-----------------------+-----------------------------------------------------------------+
|0x341 | mepc          | RW,                   | Exception program counter                                       |
|      |               | per-thread            |                                                                 |
+------+---------------+-----------------------+-----------------------------------------------------------------+
|0x342 | mcause        | RW,                   | Interrupt cause                                                 |
|      |               | per-thread            |                                                                 |
+------+---------------+-----------------------+-----------------------------------------------------------------+
|0x343 | mtval         | RW,                   | Stores either faulting address, or contains illegal instruction |
|      |               | per-thread            |                                                                 |
+------+---------------+-----------------------+-----------------------------------------------------------------+

Control Status Registers (MVU):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

+------+-----------------+-------+-------------------------------------------------------------+
| ADRR | CSR             | RO/RW | Description                                                 |
+======+=================+=======+=============================================================+
|0xF20 | mvuwbaseptr     | RW    | Base address for weight memory                              |
+------+-----------------+-------+-------------------------------------------------------------+
|0xF21 | mvuibaseptr     | RW    | Base address for input memory                               |
+------+-----------------+-------+-------------------------------------------------------------+
|0xF22 | mvusbaseptr     | RW    | Base address for scaler memory (6-bit)                      |
+------+-----------------+-------+-------------------------------------------------------------+
|0xF23 | mvubbaseptr     | RW    | Base address for bias memory (6-bit)                        |
+------+-----------------+-------+-------------------------------------------------------------+
|0xF24 | mvuobaseptr     | RW    | Output base address                                         |
|      |                 |       |  0-23: address                                              |
|      |                 |       |  31-24: destination MVUs (bit 24 -> MVU 0)                  |
+------+-----------------+-------+-------------------------------------------------------------+
|0xF25 | mvuwjump[0-4]   | RW    | Weight address jumps in loops 0-4                           |
+------+-----------------+-------+-------------------------------------------------------------+
|0xF26 | mvuijump[0-4]   | RW    | Input data address jumps in loops 0-4                       |
+------+-----------------+-------+-------------------------------------------------------------+
|0xF27 | mvusjump[0-1]   | RW    | Scaler memory address jumps (6-bit)                         |
+------+-----------------+-------+-------------------------------------------------------------+
|0xF28 | mvubjump[0-1]   | RW    | Bias memory address jumps (6-bit)                           |
+------+-----------------+-------+-------------------------------------------------------------+
|0xF29 | mvuojump[0-4]   | RW    | Output data address jumps in loops 0-4                      |
+------+-----------------+-------+-------------------------------------------------------------+
|0xF2A | mvuwlength[1-4] | RW    | Weight length in loops 1-4                                  |
+------+-----------------+-------+-------------------------------------------------------------+
|0xF2B | mvuilength[1-4] | RW    | Input data length in loops 1-4                              |
+------+-----------------+-------+-------------------------------------------------------------+
|0xF2C | mvuslength[1]   | RW    | Scaler tensor lengths(15-bit)                               |
+------+-----------------+-------+-------------------------------------------------------------+
|0xF2D | mvublength[1]   | RW    | Bias tensor lengths (15-bit)                                |
+------+-----------------+-------+-------------------------------------------------------------+
|0xF2E | mvuolength[1-4] | RW    | Output data length in loops 1-4                             |
+------+-----------------+-------+-------------------------------------------------------------+
|0xF2F | mvuprecision    | RW    | Precision in bits for all tensors:\n                        |
|      |                 |       |  0-5: weights precision\n                                   |
|      |                 |       |  6-11: input data precision\n                               |
|      |                 |       |  12-17: output data precision\n                             |
|      |                 |       |  24: weights signed (0: unsigned, 1: signed)                |
|      |                 |       |  25: input data signed (0: unsigned, 1: signed)             |
+------+-----------------+-------+-------------------------------------------------------------+
|0xF30 | mvustatus       | RO    | Status of MVU                                               |
|      |                 |       |  0: busy                                                    |
|      |                 |       |  1: done                                                    |
+------+-----------------+-------+-------------------------------------------------------------+
|0xF30 | mvucommand      | RW    | Kick to send command.                                       |
|      |                 |       |  30-31: MulMode (00:{0,0} 01:{0,+1} 10:{-1,+1} 11:{0, -1})  |
|      |                 |       |  29: MaxPool enable                                         |
|      |                 |       |  0-28: Clock cycle countdown                                |
+------+-----------------+-------+-------------------------------------------------------------+
|0xF30 | mvuquant        | RW    | 6-11: MSB index position                                    |
|      |                 |       | 12-31: reserved (possibly for activation params)            |
+------+-----------------+-------+-------------------------------------------------------------+
|0xF30 | mvuscaler       | RW    | 0-15: fixed point operand for multiplicative scaling        |
+------+-----------------+-------+-------------------------------------------------------------+
|0xF30 | mvuconfig1      | RW    | 0-7: Shift/accumulator load on jump select (only 0-4 valid) |
|      |                 |       | 8-16: Pool/Activation clear on jump select (only 0-4 valid) |
+------+-----------------+-------+-------------------------------------------------------------+


Barrel RISC-V 
^^^^^^^^^^^^^^
A barrel processor is a form of a fine-grain multithreading processor that exploits thread-levelparallelism by switching between different threads on each clock cycle (Hennessey and Patterson,2011). The aim is to maximize the overall utilization of the processor’s resources, and instructionthroughput. This is similar to the technique of simultaneous multi-threading (SMT) that is used inmodern superscalar processors. However, unlike SMT superscalar processors, barrel processors donot issue more than one instruction per clock cycle. Instead, a single execution pipeline is shared byall threads.
