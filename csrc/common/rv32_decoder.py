import argparse
import rv_decoder

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input', help='input instruction', required=True)
    parser.add_argument('-f', '--input_fromat', help='input instruction format', required=False, choices=['h', 'b', 'd'], default='h')
    args = parser.parse_args()
    return vars(args)

if __name__ == '__main__':
    args = parse_args()
    instruction_format = args['input_fromat']
    instruction = ""
    if instruction_format == 'h':
        instruction = bin(int(args['input'], 16))[2:].zfill(32)
    elif instruction_format == 'd':
        instruction = bin(int(args['input']))[2:].zfill(32)
    elif instruction_format == 'b':
        instruction = args['input']
    else:
        import sys
        print("Unknown input type {}".format(instruction_format))
        sys.exit()
    decoded_instruction = rv_decoder.decode(instruction)
    rv_decoder.print_dic(decoded_instruction)
