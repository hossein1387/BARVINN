Design
============

BARVINN
-----------------
BARVINN is a Barrel RISC-V Neural Network Accelerator. The main purpose of designing BARVINN was to fill the need for arbitrary precision neural network acceleration. The overall architecture of BARVINN is illustrated below:
BARVINN is an FPGA proven accelerator. :numref:`fig_barvinn_top` illustrates the overall system design for BARVINN. It is consist of the following components:

- Array of Matrix Vector Units
- RISC-V Controller Core
- Host Machine

.. figure:: _static/BARVINN_TOP.png
  :width: 800
  :alt: Alternative text
  :name: fig_barvinn_top

  BARVINN overall architecture.


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


:numref:`mvu_arch` illustrates the block diagram of an MVU. Each MVU is consist of a Matrix Vector Product unit (MVP), Collision Detection Read Unit (CDRU), Collision Detection Write Unit (CDWU), activation ram, weight ram and a set of machine learning specific blocks such as quantizers, scaler units and pooling unit that can be switched on or off (technically, data will pass through all of these blocks and user should provide proper configuration to by pass the functionality. For instance for `scaler` unit, if there is no need to scale the output, user should write `1s` in scaler rams) depending on the job configuration. As it can be seen in the :numref:`mvu_arch`, at each clock cycle, an MVU word (64 bits) is read from activation ram. At the same time, a long word of 4096 bits (64 by 64 ) is read from weight ram. This is then fed into MVP unit which can perform matrix vector product in one clock cycle. Depending on the precision configuration register (take a look at MVU_CSR_REG_TABLE_ for detailed register configuration for each MVU), multiple words will be read from weight and data memory to perform bit serial multlipicaiton.


:numref:`mvu_bit_slice` illustrates bit-serial operation in MVU. As it can be seen, an MVU data word of size 64 bit is read from data ram. This will be fed into 64 bit-serial multlipicaiton blocks. Each of these blocks perform a dot product between the two vectors. :numref:`mvu_bit_slice` shows only one bit-slice operation in the MVU, however, in reality, there are 64 modules that perform the same task on input data but with different weight vectors. For more information of MVU bit-serial operation, please refer to "Bit-Slicing FPGA Accelerator for Quantized Neural Networks" by O. Bilaniu et al.


.. figure:: _static/mvu_bitslice_ops.png
  :width: 600
  :alt: Alternative text
  :name: mvu_bit_slice

  Bit serial operation in MVU.

As we mentioned before, the MVU is capable of performing computation with different bit precision. The way we achieve this task is by storing values in MSB transposed format in memory. This format of saving data in memory allows MVU to read only as many words as the operand precision. Since all the computations are happening in this format, the user should not worry about memory layout except when it wants to read results or write inputs (such as input image) into MVU rams. To solve this issue, there is a data transposer module that transposes the data to the correct format. Data transposer's job is to write input data (that is stored in a processor RAM in linear format) into MVU RAM in a transposed format. The input word can be packed
of 2,4,8 or 16 bits data. Given the input data precision (prec) the transposer will unpack, transpose and store them in the correct format. Once the MVU word is prepared, data tranposer will go into `BUSY` state in which it will ignore any incoming new input  data. At this point, the transposed data will be written into MVU word. Once complete, it will go back into `IDLE` state and it will wait for a new posedge on start signal to start the process all over again.
 
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

To submit a job to MVU, we first need to understand how the mvu works. 

PITO: A Barrel RISC-V Processor:
------------------------------------
To make use of MVUs for neural networks, some form of the control unit is required. It is not possible to foresee and provide for all possible neural networks that may crop up in theliterature in the future. Therefore, the high-level sequencing of tensor operations should beprovided for in software, possibly assisted by `glue` logic to help drive the MVUs’ control signals. 

PITO is a Barrel RISC-V processor, designed to control the 8 MVUs in `Bilaniuk et al. (2019)` using separate but communicating hardware threads (harts) that each manage their respective MVUs. Neural network layers can then be executed either in parallel or in a pipelined fashion depending on whether the neural network software is compiled to maximize throughput or minimize latency. This design also allows MVUs to complete tensor operations independently of each other. However, the drawback is that, at least nominally, this requires 8 microprocessors to execute the 8 programs, putting serious pressure on the remaining logic of the host FPGA. We instead amortized the fixed costs of the processor by adopting an old idea: `the barrel processor`. By making the barrel processor 8-way threaded, we may assign one thread to control each of the MVUs, while amortizing the fixed costs of each microprocessor over the 8 threads. Because every thread comes up for execution only every 8 clock cycles, up to 8 pipeline stages including instruction fetch, decode, execution and data read & writes can be completely hidden. Branch prediction units arealso made unnecessary. Because even modest tensor operations can require hundreds of matrix-vector products (and therefore clock cycles) to execute on an MVU, the barrel processor has the opportunity to fully turn over dozens of times in the interim, allowing each thread to issue the next command to its MVU in a few instructions.

A barrel processor is a form of a fine-grain multithreading processor that exploits thread-levelparallelism by switching between different threads on each clock cycle (Hennessey and Patterson,2011). The aim is to maximize the overall utilization of the processor’s resources, and instructionthroughput. This is similar to the technique of simultaneous multi-threading (SMT) that is used inmodern superscalar processors. However, unlike SMT superscalar processors, barrel processors donot issue more than one instruction per clock cycle. Instead, a single execution pipeline is shared byall threads.


As mentioned earlier, MVU array has many configuration settings. We used a barrel RISC-V design as a controller to send control signals to each MVU. The connection between the controller and the MVU array is through control status registers (CSRs). 



Interrupts :
^^^^^^^^^^^^^

In BARVINN, MVUs can send interrupts to their associated hart. These interrupts are added to RISC-V custom interrupts `mie` field. To reduce complexity, there are no supports for nested interrupts or interrupt priorities. However, we followed RISC-V's interrupt operation flow. :numref:`pito_irq` illustrates servicing interrupt flow in software and hardware.


.. figure:: _static/pito_interrupt.png
  :width: 800
  :alt: Alternative text
  :name: pito_irq

  Interrupt service routine in hardware and software 


Control Status Registers (RISC-V):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. _RV32_CSR_REG_TABLE:

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

.. _MVU_CSR_REG_TABLE:

+-----------------+-------+-------------------------------------------------------------+
| CSR             | RO/RW | Description                                                 |
+=================+=======+=============================================================+
| mvuwbaseptr     | RW    | Base address for weight memory                              |
+-----------------+-------+-------------------------------------------------------------+
| mvuibaseptr     | RW    | Base address for input memory                               |
+-----------------+-------+-------------------------------------------------------------+
| mvusbaseptr     | RW    | Base address for scaler memory (6-bit)                      |
+-----------------+-------+-------------------------------------------------------------+
| mvubbaseptr     | RW    | Base address for bias memory (6-bit)                        |
+-----------------+-------+-------------------------------------------------------------+
| mvuobaseptr     | RW    | Output base address:                                        |
|                 |       +-------------------------------------------------------------+
|                 |       | 0-23: address                                               |
|                 |       +-------------------------------------------------------------+
|                 |       | 31-24: destination MVUs (bit 24 -> MVU 0)                   |
+-----------------+-------+-------------------------------------------------------------+
| mvuwjump[0-4]   | RW    | Weight address jumps in loops 0-4                           |
+-----------------+-------+-------------------------------------------------------------+
| mvuijump[0-4]   | RW    | Input data address jumps in loops 0-4                       |
+-----------------+-------+-------------------------------------------------------------+
| mvusjump[0-1]   | RW    | Scaler memory address jumps (6-bit)                         |
+-----------------+-------+-------------------------------------------------------------+
| mvubjump[0-1]   | RW    | Bias memory address jumps (6-bit)                           |
+-----------------+-------+-------------------------------------------------------------+
| mvuojump[0-4]   | RW    | Output data address jumps in loops 0-4                      |
+-----------------+-------+-------------------------------------------------------------+
| mvuwlength[1-4] | RW    | Weight length in loops 1-4                                  |
+-----------------+-------+-------------------------------------------------------------+
| mvuilength[1-4] | RW    | Input data length in loops 1-4                              |
+-----------------+-------+-------------------------------------------------------------+
| mvuslength[1]   | RW    | Scaler tensor lengths(15-bit)                               |
+-----------------+-------+-------------------------------------------------------------+
| mvublength[1]   | RW    | Bias tensor lengths (15-bit)                                |
+-----------------+-------+-------------------------------------------------------------+
| mvuolength[1-4] | RW    | Output data length in loops 1-4                             |
+-----------------+-------+-------------------------------------------------------------+
| mvuprecision    | RW    | Precision in bits for all tensors:                          |
|                 |       +-------------------------------------------------------------+
|                 |       | 0-5: weights precision                                      |
|                 |       +-------------------------------------------------------------+
|                 |       | 6-11: input data precision                                  |
|                 |       +-------------------------------------------------------------+
|                 |       | 12-17: output data precision                                |
|                 |       +-------------------------------------------------------------+
|                 |       | 24: weights signed (0: unsigned, 1: signed)                 |
|                 |       +-------------------------------------------------------------+
|                 |       | 25: input data signed (0: unsigned, 1: signed)              |
+-----------------+-------+-------------------------------------------------------------+
| mvustatus       | RO    | Status of MVU:                                              |
|                 |       +-------------------------------------------------------------+
|                 |       | 0: busy                                                     |
|                 |       +-------------------------------------------------------------+
|                 |       | 1: done                                                     |
+-----------------+-------+-------------------------------------------------------------+
| mvucommand      | RW    | Kick to send command:                                       |
|                 |       +-------------------------------------------------------------+
|                 |       | 30-31: MulMode (00:{0,0} 01:{0,+1} 10:{-1,+1} 11:{0, -1})   |
|                 |       +-------------------------------------------------------------+
|                 |       | 29: MaxPool enable                                          |
|                 |       +-------------------------------------------------------------+
|                 |       | 0-28: Clock cycle countdown                                 |
+-----------------+-------+-------------------------------------------------------------+
| mvuquant        | RW    | MVU Quantization Configs:                                   |
|                 |       +-------------------------------------------------------------+
|                 |       | 6-11: MSB index position                                    |
|                 |       +-------------------------------------------------------------+
|                 |       | 12-31: reserved (possibly for activation params)            |
+-----------------+-------+-------------------------------------------------------------+
| mvuscaler       | RW    | 0-15: fixed point operand for multiplicative scaling        |
+-----------------+-------+-------------------------------------------------------------+
| mvuconfig1      | RW    | MVU General Configurations                                  |
|                 |       +-------------------------------------------------------------+
|                 |       | 0-7: Shift/accumulator load on jump select (only 0-4 valid) |
|                 |       +-------------------------------------------------------------+
|                 |       | 8-16: Pool/Activation clear on jump select (only 0-4 valid) |
+-----------------+-------+-------------------------------------------------------------+


mvubbaseptr:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. figure:: _static/wavedrom/mvubbaseptr.svg
  :width: 800
  :alt: Alternative text

mvubjump:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. figure:: _static/wavedrom/mvubjump.svg
  :width: 800
  :alt: Alternative text

mvublength:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. figure:: _static/wavedrom/mvublength.svg
  :width: 800
  :alt: Alternative text

mvucommand:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. figure:: _static/wavedrom/mvucommand.svg
  :width: 800
  :alt: Alternative text

mvuconfig1:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. figure:: _static/wavedrom/mvuconfig1.svg
  :width: 800
  :alt: Alternative text

mvuibaseptr:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. figure:: _static/wavedrom/mvuibaseptr.svg
  :width: 800
  :alt: Alternative text

mvuijump:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. figure:: _static/wavedrom/mvuijump.svg
  :width: 800
  :alt: Alternative text

mvuilength:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. figure:: _static/wavedrom/mvuilength.svg
  :width: 800
  :alt: Alternative text

mvuobaseptr:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
`mvuobaseptr` output address, results of each operation will be written into this address.
Destination MVU, results can be sent to other MVUs by setting the appropriate MVU (0 to7 ) field. The result can be broadcasted to any number of MVUs in the system.

.. figure:: _static/wavedrom/mvuobaseptr.svg
  :width: 800
  :alt: Alternative text

mvuojump:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. figure:: _static/wavedrom/mvuojump.svg
  :width: 800
  :alt: Alternative text

mvuolength:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. figure:: _static/wavedrom/mvuolength.svg
  :width: 800
  :alt: Alternative text

mvuprecision:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
`weight precision`, `input precision` and `output precision` that indicates the computation precision accordingly. 
`isign` and `wsign` can be used to set if the data is signed `1` or not `0`.

.. figure:: _static/wavedrom/mvuprecision.svg
  :width: 800
  :alt: Alternative text

mvuquant:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
In the case we need to quantize results, `msbidx` can be used. This field indicates that where does the `msb` position starts. 

.. figure:: _static/wavedrom/mvuquant.svg
  :width: 800
  :alt: Alternative text

mvusbaseptr:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. figure:: _static/wavedrom/mvusbaseptr.svg
  :width: 800
  :alt: Alternative text

mvuscaler:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. figure:: _static/wavedrom/mvuscaler.svg
  :width: 800
  :alt: Alternative text

mvusjump:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. figure:: _static/wavedrom/mvusjump.svg
  :width: 800
  :alt: Alternative text

mvuslength:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. figure:: _static/wavedrom/mvuslength.svg
  :width: 800
  :alt: Alternative text

mvustatus:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. figure:: _static/wavedrom/mvustatus.svg
  :width: 800
  :alt: Alternative text

mvuwbaseptr:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. figure:: _static/wavedrom/mvuwbaseptr.svg
  :width: 800
  :alt: Alternative text

mvuwjump:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. figure:: _static/wavedrom/mvuwjump.svg
  :width: 800
  :alt: Alternative text

mvuwlength:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. figure:: _static/wavedrom/mvuwlength.svg
  :width: 800
  :alt: Alternative text