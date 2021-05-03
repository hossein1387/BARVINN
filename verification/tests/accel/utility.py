import os
import sys
import subprocess
from termcolor import colored
import platform

verbose = {"VERB_NONE":0, "VERB_LOW":100, "VERB_MEDIUM":200,"VERB_HIGH":300, "VERB_FULL":400, "VERB_DEBUG":500}

def run_command(command_str, split=True, verbosity="VERB_HIGH"):
        try:
            print_log(command_str, id_str="command", verbosity=verbosity)
            # subprocess needs to receive args seperately
            if split:
                res = subprocess.call(command_str.split())
            else:
                res = subprocess.call(command_str, shell=True)
            if res == 1:
                print_log("Errors while executing: {0}".format(command_str), "ERROR", verbosity="VERB_LOW")
                sys.exit()
        except OSError as e:
            print_log("Unable to run {0} command".format(command_str), "ERROR")
            sys.exit()

def print_log(log_str, id_str="INFO", color="white", verbosity="VERB_LOW"):
    if verbosity not in verbose:
        print_log("Unknown verbosity {0} choose from {1}".format(verbosity, verbose.keys()), "ERROR")
        sys.exit()
    if verbose[verbosity] < verbose["VERB_MEDIUM"]:
        if "white" in color.lower():
            if "warning" in id_str.lower():
                color = "yellow"
            elif "error" in id_str.lower():
                color = "red"
            elif "command" in id_str.lower():
                color = "green"
            elif "pass" in id_str.lower():
                color = "green"
        print(colored(("[{0:<7}]   {1}".format(id_str, log_str)), color))

def print_banner(banner_str, color="white", verbosity=verbose["VERB_HIGH"]):
    print_log("=======================================================================", color=color, verbosity=verbosity)
    print_log(banner_str, color=color, verbosity=verbosity)
    print_log("=======================================================================", color=color, verbosity=verbosity)

def clean_proj(files_to_clean):
    for file in files_to_clean:
        if "/" in file:
            # clearing a directory
            command = "rm -rf {0}".format(file)
        else:
            command = "rm -rf *.{0}".format(file)
        run_command(command, split=False, verbosity="VERB_NONE")
    sys.exit()

def get_platform(verbosity="VERB_LOW"):
    platform_name = platform.system().lower()
    print_log("Working on a {0} platform".format(platform_name), "INFO", verbosity=verbosity, color="green")
    return platform_name


def create_dir(_dir, verbosity="VERB_HIGH"):
    try:
        if not os.path.exists(_dir):
            print_log("Creating {0} directory".format(_dir), verbosity=verbosity)
            os.makedirs(_dir)
    except OSError as e:
        if e.errno != errno.EEXIST:
            print_log("Unable to create {0} directory".format(_dir), "ERROR", verbosity="VERB_LOW")
            sys.exit()

def pretty_matrix(mat):
    # import ipdb as pdb; pdb.set_trace()
    s = [[str(e).replace(")","").replace("(","").replace("tensor","") for e in row] for row in mat]
    lens = [max(map(len, col)) for col in zip(*s)]
    fmt = '\t'.join('{{:{}}}'.format(x) for x in lens)
    table = [fmt.format(*row) for row in s]
    return '\n'.join(table)

def pretty_tensor(tensor):
    mat_str = ""
    for mat in tensor:
        mat_str += pretty_matrix(mat)
        mat_str += "\n\n\n\n\n"
    return mat_str