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

These MVUs are connected through a cross bar 

Matrix Vector Unit (MVU)
^^^^^^^^^^^^^^^^^^^^^^^^



RISC-V Controller
-----------------
As mentioned earlier, MVU array has many configuration settings. We used a barrel RISC-V design as a controller to send control signals to each MVU. The connection between the controller and the MVU array is through control status registers (CSRs). 

Barrel RISC-V 
^^^^^^^^^^^^^^
A barrel processor is a form of a fine-grain multithreading processor that exploits thread-levelparallelism by switching between different threads on each clock cycle (Hennessey and Patterson,2011). The aim is to maximize the overall utilization of the processor’s resources, and instructionthroughput. This is similar to the technique of simultaneous multi-threading (SMT) that is used inmodern superscalar processors. However, unlike SMT superscalar processors, barrel processors donot issue more than one instruction per clock cycle. Instead, a single execution pipeline is shared byall threads.
