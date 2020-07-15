#!/usr/bin/env python


import os
import sys
import argparse

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--hex_file', help='input hex file', required=False)
    parser.add_argument('-b', '--bmode', help='output binary mode: str or bytecode', required=False)
    args = parser.parse_args()
    return vars(args)

#=======================================================================
# Utility functions
#=======================================================================
def hex_to_bin(hex_file, mode, bin_file):
    with open(bin_file, "wb") as fw:
        with open(hex_file, "r") as f:
            lines = f.readlines()
            for line in lines:
                # import ipdb as pdb; pdb.set_trace()
                val = line.replace("\n", "")
                val = bin(int(val, 16))[2:].zfill(32)
                if mode == 'str':
                    bin_vals += str(val)
                elif mode == 'bytecode':
                    print(val)
                    fw.write(bitstring_to_bytes(val))
    fw.close()

def bitstring_to_bytes(s):
    return int(s, 2).to_bytes(len(s) // 8, byteorder='little')

#=======================================================================
# Main
#=======================================================================
if __name__ == '__main__':
    args = parse_args()
    hex_file = args['hex_file']
    mode = args['bmode']
    bin_file = hex_file.replace(".hex", "") + ".bin"
    hex_to_bin(hex_file, mode, bin_file)
    # if mode == 'str':
    #     with open(bin_file, "w") as f:
    #         f.write(bin_vals)
    #         f.close()
    # elif mode == 'bytecode':
    #     with open(bin_file, "wb") as f:
    #             f.write(bin_vals)
    #             f.close()
    # else:
    #     print("Unknown mode {}".format(mode))
    #     sys.exit()
