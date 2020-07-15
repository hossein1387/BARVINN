import argparse
import rv_decoder as decoder

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input_file', help='input instruction file in hex format', required=True)
    args = parser.parse_args()
    return vars(args)

def clear_file(filename):
    with open(filename, "w") as f:
        f.close()

if __name__ == '__main__':
    args = parse_args()
    text = ""
    input_hex_file = args['input_file']
    with open(input_hex_file, "r") as f:
        lines = f.readlines()
        # import ipdb as pdb; pdb.set_trace()
        for line in lines:
            line = line.replace("\n","")
            instruction = bin(int(line, 16))[2:].zfill(32)
            decoded_instruction = decoder.decode(instruction)
            vals = " ".join(["{}:{} ".format(key, val) for key, val in zip(decoded_instruction.keys(), decoded_instruction.values())])
            text += "{} // {}\n".format(line, vals)
        f.close()
    clear_file(input_hex_file)
    with open(input_hex_file, "w") as f:
        f.write(text)
        f.close()