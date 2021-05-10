# BARVINN: A Barrel RISC-V Neural Network Accelerator:

![alt text](https://github.com/hossein1387/BARVINN/blob/master/docs/_static/BARVINN_LOGO.png)

## How to Use:
    
You first need to clone the repository and update the submodules:

    git clone https://github.com/hossein1387/BARVINN.git
    cd BARVINN
    git submodule update --init


Now that you cloned the BARVINN repository, you can run a sample code. First make sure the Vivado is sourced, example for Vivado 2019.1: 

    source /opt/Xilinx/Vivado/2019.1/settings64.sh

Then make sure you have fusesoc installed:

    python3 -m pip install fusesoc

Then add `mvu`, `pito` and `barvinn` to your fusesoc libraries (NOTE: if you have used FuseSoC with any of the following projects, you can skip adding it to FuseSoC) :
    
    fusesoc library add barvinn .

Then run simulation (No GUI):
   
    fusesoc run --target=sim barvinn

For synthesis:
    
    fusesoc run --target=synth barvinn

To open sim in GUI mode:

    cd build/pito_0/sim-vivado/ 
    make run-gui

And for synthesis:

    cd build/pito_0/synth-vivado/ 
    make build-gui


This should open the project for you. Make sure you have run simulation or synthesis atleast once, otherwise fusesoc would not create a 
project file for you.


## Documentation:

BARVINN documentation is available in [docs/](https://github.com/hossein1387/BARVINN/tree/master/docs) folder. However, you can follow this url for an online version of documentation hosted on readthedocs. This url will ocassionally gets updated. You can build the lates docs using the following:


    cd docs
    python pip -r install requirements
    make html

Then, you can open `./docs/_build/html/index.html` file.
