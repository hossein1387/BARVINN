import os
import sys
import argparse
from os import listdir
from os.path import isfile, join
import shutil

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--hex_file', help='input hex file', required=False)
    args = parser.parse_args()
    return vars(args)
#=======================================================================
# Main
#=======================================================================
if __name__ == '__main__':
    top_dir_path = os.getcwd()
    common_dir = top_dir_path+"/common/"
    args = parse_args()
    all_files = [f for f in listdir("./") if isfile(join("./", f))]
    all_asm_files = []
    for file in all_files:
        if len(file.split(".S")) > 1:
            all_asm_files.append(file)
            path = top_dir_path + "/" + file.split(".S")[0]
            # import ipdb as pdb; pdb.set_trace()
            os.mkdir(path)
            shutil.copy(file, path)
            os.symlink(common_dir + "Makefile"            , path + "/Makefile"           )
            os.symlink(common_dir + "link.ld"             , path + "/link.ld"            )
            os.symlink(common_dir + "makehex.py"          , path + "/makehex.py"         )
            os.symlink(common_dir + "riscv_hex_to_bin.py" , path + "/riscv_hex_to_bin.py")
            os.symlink(common_dir + "riscv_test.h"        , path + "/riscv_test.h"       )
            os.symlink(common_dir + "test_macros.h"       , path + "/test_macros.h"      )
