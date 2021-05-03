#!/usr/bin/env python3
#xelab bank64k_tester  -L blk_mem_gen_v8_4_3
import os
import sys
import argparse
import subprocess
import utility as util
#=======================================================================
# Globals
#=======================================================================
simulator = None
result_dir = "../results"
# Use / to indicate that you are deleting a directory and not a file.
# Everything else is intrepreted as a file type.
files_to_clean = ["jou", "vcd", "pb", ".Xil/", "xsim.dir/", "log", "wdb", "str"]
#=======================================================================
# Utility Funcs
#=======================================================================

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--simulator', help='Simulator to use', required=False)
    parser.add_argument('-f', '--files', help='Simulation files', required=False)
    parser.add_argument('-m', '--vlogmacros', help='File containing Verilog global macros', required=False)
    parser.add_argument('-l', '--libs', help='File containing list of simulation libraries', required=False)
    parser.add_argument('-t', '--top_level', help='Top level module for Xilinx tools', required=False)
    parser.add_argument('-g', '--gui', action='store_true', help=' gui mode supported in cadence irun only', required= False)
    parser.add_argument('-w', '--waveform', action='store_true', help=' compile with waveform information', required= False)
    parser.add_argument('-v', '--svseed', help=' sv seed supported in cadence irun and Xilinx xsim only', required= False)
    parser.add_argument('-c', '--coverage', action='store_true', help='add coverage supported in cadence irun only', required= False)
    parser.add_argument('-d', '--debug', action='store_true', help='create debug info supported in cadence irun only', required= False)
    parser.add_argument('-clean', '--clean', action='store_true', help='clean project', required= False)
    parser.add_argument('-silence', '--silence', action='store_true', help=' Silence mode (no log will be printed)', required= False, default=False)
    parser.add_argument('-verbosity', '--verbosity', help='Print log verbosity: VERB_NONE, VERB_LOW, VERB_MEDIUM, VERB_HIGH, VERB_FULL, VERB_DEBUG', required=False)
    parser.add_argument('-timescale', '--timescale', help='Simulation timescale', required=False, default='1ps/1ps')
    args = parser.parse_args()
    return vars(args)

def get_rtl_files(f_file):
    sv_rtl   = ""
    vhdl_rtl = ""
    v_rtl    = ""
    with open(f_file, 'r') as f:
        rtls = f.readlines()
        for rtl in rtls:
            rtl = rtl.replace("\n", "")
            if rtl != "":
                if rtl.lower().endswith(".vhdl") or rtl.lower().endswith(".vhd"):
                    vhdl_rtl += "{0} ".format(rtl)
                elif rtl.lower().endswith(".sv") or rtl.lower().endswith(".svh"):
                    sv_rtl += "{0} ".format(rtl)
                elif rtl.lower().endswith(".v") or rtl.lower().endswith(".vh"):
                    v_rtl += "{0} ".format(rtl)
                else:
                    util.print_log("unsupported file format: {0}".format(rtl), "ERROR", verbosity="VERB_LOW")
                    sys.exit()
    # import ipdb as pdb; pdb.set_trace()
    return sv_rtl, v_rtl, vhdl_rtl

def get_vlogmacros(f_file):
    vlogmacros = ""
    with open(f_file, 'r') as f:
        macros = f.readlines()
        for macro in macros:
            if macro != "":
                macro = macro.replace("\n", "")
                vlogmacros += " -d " + macro + " "
    return vlogmacros

def get_libs(f_file):
    # import ipdb as pdb; pdb.set_trace()
    libs = ""
    with open(f_file, 'r') as f:
        libslist = f.readlines()
        for lib in libslist:
            if lib != "":
                lib = lib.replace("\n", "")
                libs += " -L " + lib + " "
    return libs


#=======================================================================
# Main
#=======================================================================
if __name__ == '__main__':

    cmd_to_run = ""
    args = parse_args()

    simulator = args['simulator']
    top_level = args['top_level']
    files = args['files']
    vlogmacros_file = args['vlogmacros']
    libs_file = args['libs']
    gui = args['gui']
    svseed = args['svseed']
    coverage = args['coverage']
    debug = args['debug']
    waveform = args['waveform']
    clean = args['clean']
    # import ipdb as pdb; pdb.set_trace()
    silence = args['silence']
    verbosity = args['verbosity']
    if verbosity is None:
        verbosity = 'VERB_LOW'
    if util.get_platform(verbosity=verbosity) != "linux":
        util.print_log("This script works only on a Linux platform", "ERROR", verbosity="VERB_LOW")
        sys.exit()
    if clean:
        util.print_banner("Cleaning project", verbosity=verbosity)
        util.clean_proj(files_to_clean)
    if not os.path.exists(result_dir):
        util.print_log("Creating a result directory in {0}".format(result_dir), "INFO", verbosity="VERB_LOW")
        os.makedirs(result_dir)
    if simulator == None:
        util.print_log("You need to provide Simulator name", "ERROR", verbosity="VERB_LOW")
        sys.exit()

    # Load Verilog macros file, if specified
    vlogmacros = ""
    if vlogmacros_file is not None:
        if os.path.exists(vlogmacros_file):
            vlogmacros = get_vlogmacros(vlogmacros_file)
        else:
            util.print_log("Verilog macros file not found!", "ERROR", verbosity="VERB_LOW")
            sys.exit()

    # Load list of simulation libraries from file, if specified
    libs = ""
    if libs_file is not None:
        if os.path.exists(libs_file):
            libs = get_libs(libs_file)
        else:
            util.print_log("Library list file not found!", "ERROR", verbosity="VERB_LOW")
            sys.exit()

    if simulator.lower() == "xilinx":
        # For Xilinx tools we need to specify top level for creating snapshots which is needed
        # by simulator and synthesis tools
        if not('XILINX_VIVADO' in os.environ):
            util.print_log("Xilinx Vivado simulator was not found, forgot to source it?", "ERROR", verbosity="VERB_LOW")
            sys.exit()
        if top_level == None:
            util.print_log("Top level was not specified", "ERROR", verbosity="VERB_LOW")
            sys.exit()

        util.print_banner("Compiling input files", verbosity=verbosity)
        if files == None:
            util.print_log("You need to provide f-file", "ERROR", verbosity="VERB_LOW")
            sys.exit()
        sv_rtl, v_rtl, vhdl_rtl = get_rtl_files(files)
        # import ipdb as pdb; pdb.set_trace()
        if sv_rtl != "":
            cmd_to_run = "xvlog --sv {0} ".format(sv_rtl)
            cmd_to_run += vlogmacros
            if silence:
                cmd_to_run += "> /dev/null"
            util.run_command(cmd_to_run, split=False, verbosity=verbosity)
        if v_rtl != "":
            cmd_to_run = "xvlog {0} ".format(v_rtl)
            cmd_to_run += vlogmacros
            if silence:
                cmd_to_run += "> /dev/null"
            util.run_command(cmd_to_run, split=False, verbosity=verbosity)
        if vhdl_rtl != "":
            cmd_to_run = "xvhdl {0} ".format(vhdl_rtl)
            if silence:
                cmd_to_run += "> /dev/null"
            util.run_command(cmd_to_run, split=False, verbosity=verbosity)

        util.print_banner("Creating snapshot", verbosity=verbosity)
        # cmd_to_run = "xelab {0} ".format(top_level)
        # import ipdb as pdb; pdb.set_trace()
        cmd_to_run = "xelab -debug typical -L secureip -L unisims_ver -L unimacro_ver {0} ".format(top_level)
        if libs_file:
            cmd_to_run += libs
        if waveform:
            cmd_to_run += " --debug all "
        if silence:
            cmd_to_run += "> /dev/null"
        if args['timescale'] != None:
            cmd_to_run += "--timescale {} ".format(args['timescale'])
        util.run_command(cmd_to_run, split=False, verbosity=verbosity)
        util.print_banner("Running simulation", verbosity=verbosity)
        if gui:
            cmd_to_run = "xsim --g {0} ".format(top_level)
        else:
            cmd_to_run = "xsim -R {0} ".format(top_level)
        if svseed:
            cmd_to_run += "-sv_seed {0} ".format(svseed)
        if silence:
            cmd_to_run += "> /dev/null"
        util.run_command(cmd_to_run, split=False, verbosity=verbosity)

    elif simulator.lower() == "iverilog":
        util.print_banner("Running iverilog Simulation", verbosity=verbosity)
        cmd_to_run = "iverilog -Wall -g2012 -f {0} && unbuffer vvp {1}/result.out".format(files, result_dir)
        util.run_command(cmd_to_run, split=False, verbosity=verbosity)
    elif simulator.lower() == "irun":
        iruns_args = ""
        util.print_banner("Running Cadence irun Simulation", verbosity=verbosity)
        if gui:
            iruns_args += "gui "
        if svseed:
            iruns_args += "svseed {0} ".format(svseed)
        if coverage:
            iruns_args += "coverage "
        if debug:
            iruns_args += "debug "
        cmd_to_run = "irun +access+rwc -f {0} {1}".format(files, iruns_args)
        util.run_command(cmd_to_run, verbosity=verbosity)
    else:
        util.print_log("Unknown simulator {0}".format(simulator), "ERROR", verbosity="VERB_LOW")
        sys.exit()
