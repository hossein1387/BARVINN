#!/usr/bin/env python2

import os
import sys
import argparse
import subprocess

#=======================================================================
# Globals
#=======================================================================
default_path_for_proj = ""
default_path_to_fpga_dir = "../"
#=======================================================================
# Utility Funcs
#=======================================================================
def run_command(command_str):
        try:
            print_log(command_str)
            # subprocess needs to receive args seperately
            res = subprocess.call(command_str, shell=True)
            if res == 1:
                print_log("Errors while executing: {0}".format(command_str), "ERROR")
                sys.exit()
        except OSError as e:
            print_log("Unable to run {0} command".format(command_str), "ERROR")
            sys.exit()

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-n', '--project_name', help='Project Name', required=True)
    parser.add_argument('-p', '--path_proj', help='Path for project')
    parser.add_argument('-f', '--path_fpga', help='Path for fpga (contains scripts and utilities)')

    args = parser.parse_args()
    return vars(args)

def print_log(log_str, ID_str="INFO"):
    print("[{0}]   {1}".format(ID_str, log_str))

def print_banner(banner_str):
    print_log("=======================================================================")
    print_log(banner_str)
    print_log("=======================================================================")

def check_for_file(path):
    if not os.path.exists(path):
        print_log("Path to {0} does not exist!".format(path), "ERROR")
        sys.exit()

def check_for_dir(path):
    if not os.path.isdir(path):
        print_log("Directory {0} does not exist!".format(path), "ERROR")
        sys.exit()
#=======================================================================
# Main
#=======================================================================
if __name__ == '__main__':
    cmd_to_run = ""
    args = parse_args()
    project_name = args['project_name']
    path_for_proj = args['path_proj']
    path_fpga = args['path_fpga']
    print_banner("Creating {0} Project".format(project_name))
    # import ipdb as pdb; pdb.set_trace()
    if path_for_proj == None:
        default_path_for_proj = os.getcwd() + "/"
        print_log("Using current path for creating project: {0}".format(default_path_for_proj))
        path_for_proj = default_path_for_proj
    if path_fpga == None:
        print_log("Using default path to fpga directory {0}".format(default_path_to_fpga_dir))
        path_fpga = default_path_to_fpga_dir
# Check if project has already been created
    if os.path.isdir("{0}{1}".format(path_for_proj, project_name)):
        print_log("Project path {0}{1} already exist!".format(path_for_proj, project_name), "ERROR")
        sys.exit()
    if os.getcwd() not in path_for_proj:
        proj_dir = os.getcwd() + "/" + path_for_proj + project_name
    else:
        proj_dir = path_for_proj + project_name
    script_dir = path_fpga + "scripts/do_test.py"
    tools_dir  = path_fpga + "scripts/setup_tools.py"
    util_dir   = path_fpga + "utils/utils.sv"
    check_for_file(script_dir)
    check_for_file(util_dir)
    # import ipdb as pdb; pdb.set_trace()
    command = "mkdir {0}".format(project_name)
    run_command(command)
    command = "cd {0}".format(proj_dir)
    script_dir = "../../{0}".format(script_dir)
    util_dir = "../../{0}".format(util_dir)
    run_command(command)
    command = "mkdir {0}/docs {0}/results {0}/rtl {0}/scripts {0}/sw {0}/tb".format(proj_dir)
    run_command(command)
    command = "ln -s {0} {1}/scripts/".format(script_dir, proj_dir)
    run_command(command)
    command = "ln -s {0} {1}/scripts/".format(tools_dir, proj_dir)
    run_command(command)
    command = "ln -s {0} {1}/tb/".format(util_dir, proj_dir)
    run_command(command)
    command = "touch {0}/rtl/{1}.sv".format(proj_dir, project_name.lower())
    run_command(command)
    command = "touch {0}/tb/{1}_tester.sv".format(proj_dir, project_name.lower())
    run_command(command)

