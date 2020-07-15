import json

from collections import defaultdict
from rv_instruction_table import instruction_table


def get_hex(binary_str):
    """
    Returns the hexadecimal string literal for the given binary string
    literal input

    :param str binary_str: Binary string to be converted to hex
    """

    return "{0:#0{1}x}".format(int(binary_str, base=2), 4)


def get_int(binary_str):
    """
    Returns the integer string literal for the given binary string
    literal input

    :param str binary_str: Binary string to be converted to int
    """
    return str(int(binary_str, base=2))


def get_output(debug=False, instr=None, rs1=None, rs2=None, imm12lo=None, imm12hi=None, rd=None, imm20=None, imm12=None,
               shamt=None, shamtw=None, rm=None):
    """
    Wraps the non-empty arguments and the instruction name into a dictionary with
    arguments as keys and vals as values

    :param str instr: Name of the instruction
    :param str rs1: Source register 1
    :param str rs2: Source register 2
    :param str rd: Destination register
    :param str rm: Extended register
    :param str imm12lo: Lower 6 bits of Immediate 12
    :param str imm12hi: Higher 6 bits of Immediate 12
    :param str imm12: Immediate 12
    :param str imm20: Immediate 20
    :param str shamt: Shift args
    :param str shamtw: Shift args
    """
    arg_list = [rs1, rs2, imm12lo, imm12hi, rd, imm20, imm12, shamt, shamtw, rm]
    arg_keys = ['rs1', 'rs2', 'imm12lo', 'imm12hi', 'rd', 'imm20', 'imm12', 'shamt', 'shamtw', 'rm']

    output_dict = defaultdict()
    output_dict['instr'] = instr

    for i in range(len(arg_list)):
        if arg_list[i] is not None:
            output_dict[arg_keys[i]] = arg_list[i]

    if debug is True:
        print_dic(output_dict)

    return output_dict


def print_dic(dictionary):
    """
    Utility function to print the output dictionary for
    debug purposes

    :param dictionary dictionary: Dictionary object of the decoded instruction
    """
    json_dict = json.dumps(dictionary, sort_keys=False, indent=4)
    print(json_dict)


def decode(instruction, debug=False):
    """
    Decodes the binary instruction string input and returns a
    dictionary with the instruction name and arguments as keys and
    their vals as values

    :param str instruction: Binary string that contains the encoded instruction
    :param bool debug: Flag to print decoded dictionary (if true).
    """
    # import ipdb as pdb; pdb.set_trace()
    family = instruction[-7:-2]

    if get_hex(family) == '0x18':
        funct3 = get_int(instruction[-15:-12])
        instruction_name = instruction_table[get_hex(family)][funct3]

        rs1 = instruction[-20:-15]
        rs2 = instruction[-25:-20]
        imm12hi = instruction[0] + instruction[-8] + instruction[-31:-27]
        imm12lo = instruction[-27:-25] + instruction[-12:-8]

        return get_output(instr=instruction_name, rs1=rs1, rs2=rs2, imm12lo=imm12lo, imm12hi=imm12hi, debug=debug)

    elif get_hex(family) == '0x1b':
        instruction_name = instruction_table[get_hex(family)]

        rd = instruction[-12:-7]
        imm20 = instruction[0] + instruction[-20:-12] + instruction[-21] + instruction[-31:-21]

        return get_output(instr=instruction_name, rd=rd, imm20=imm20, debug=debug)

    elif get_hex(family) == '0x19':
        instruction_name = instruction_table[get_hex(family)]

        rs1 = instruction[-20:-15]
        rd = instruction[-12:-7]
        imm12 = instruction[:12]

        return get_output(instr=instruction_name, rd=rd, imm12=imm12, rs1=rs1, debug=debug)

    elif get_hex(family) == '0x0d' or get_hex(family) == '0x05':
        instruction_name = instruction_table[get_hex(family)]

        imm20 = instruction[:20]
        rd = instruction[-12:-7]

        return get_output(instr=instruction_name, rd=rd, imm20=imm20, debug=debug)

    elif get_hex(family) == '0x04':
        funct3 = get_int(instruction[-15:-12])

        if funct3 in ['0', '2', '3', '4', '6', '7']:
            instruction_name = instruction_table[get_hex(family)][funct3]
            rd = instruction[-12:-7]
            rs1 = instruction[-20:-15]
            imm12 = instruction[:12]
            return get_output(instr=instruction_name, rs1=rs1, rd=rd, imm12=imm12, debug=debug)

        elif funct3 in ['1', '5']:
            if funct3 == '5':
                slice_5 = str(get_int(instruction[:7]))
                instruction_name = instruction_table[get_hex(family)][funct3][slice_5]
            else:
                instruction_name = instruction_table[get_hex(family)][funct3]
            rd = instruction[-12:-7]
            rs1 = instruction[-20:-15]
            shamt = instruction[-25:-20]
            return get_output(instr=instruction_name, rs1=rs1, rd=rd, shamt=shamt, debug=debug)

    elif get_hex(family) == '0x0c':
        funct3 = get_int(instruction[-15:-12])

        slice_7 = get_int(instruction[:7])
        instruction_name = instruction_table[get_hex(family)][funct3][slice_7]

        rd = instruction[-12:-7]
        rs1 = instruction[-20:-15]
        rs2 = instruction[-25:-20]
        return get_output(instr=instruction_name, rs1=rs1, rs2=rs2, rd=rd, debug=debug)

    elif get_hex(family) == '0x06':
        funct3 = get_int(instruction[-15:-12])

        rs1 = instruction[-20:-15]
        rd = instruction[-12:-7]
        if funct3 == '0':
            imm12 = instruction[:12]
            instruction_name = instruction_table[get_hex(family)][funct3]
            return get_output(instr=instruction_name, rs1=rs1, rd=rd, imm12=imm12, debug=debug)

        elif funct3 == '1':
            shamtw = instruction[-25:-20]
            instruction_name = instruction_table[get_hex(family)][funct3]
            return get_output(instr=instruction_name, rs1=rs1, rd=rd, shamtw=shamtw, debug=debug)

        else:
            shamtw = instruction[-25:-20]
            slice_6 = get_int(instruction[:6])
            instruction_name = instruction_table[get_hex(family)][funct3][slice_6]
            return get_output(instr=instruction_name, rs1=rs1, rd=rd, shamtw=shamtw, debug=debug)

    elif get_hex(family) == '0x0e':
        funct3 = get_int(instruction[-15:-12])

        slice_7 = get_int(instruction[:7])
        instruction_name = instruction_table[get_hex(family)][funct3][slice_7]

        rd = instruction[-12:-7]
        rs1 = instruction[-20:-15]
        rs2 = instruction[-25:-20]
        return get_output(instr=instruction_name, rs1=rs1, rs2=rs2, rd=rd, debug=debug)

    elif get_hex(family) == '0x00':
        funct3 = get_int(instruction[-15:-12])
        instruction_name = instruction_table[get_hex(family)][funct3]

        rd = instruction[-12:-7]
        rs1 = instruction[-25:-20]
        imm12 = instruction[:12]
        return get_output(instr=instruction_name, rs1=rs1, imm12=imm12, rd=rd, debug=debug)

    elif get_hex(family) == '0x08':
        funct3 = get_int(instruction[-15:-12])
        instruction_name = instruction_table[get_hex(family)][funct3]

        rs1 = instruction[-20:-15]
        rs2 = instruction[-25:-20]
        imm12lo = instruction[6] + instruction[-12:-7]
        imm12hi = instruction[:6]
        return get_output(instr=instruction_name, rs1=rs1, rs2=rs2, imm12lo=imm12lo, imm12hi=imm12hi, debug=debug)

    elif get_hex(family) == '0x03':
        funct3 = get_int(instruction[-15:-12])
        instruction_name = instruction_table[get_hex(family)][funct3]
        rs1 = instruction[-20:-15]
        rd = instruction[-12:-7]

        if funct3 == '0':
            return get_output(instr=instruction_name, rs1=rs1, rd=rd, debug=debug)

        else:
            imm12 = instruction[:12]
            return get_output(instr=instruction_name, rs1=rs1, rd=rd, imm12=imm12, debug=debug)

    elif get_hex(family) == '0x0c' or get_hex(family) == '0x0e':
        funct3 = get_int(instruction[-15:-12])

        slice_7 = get_int(instruction[:7])
        instruction_name = instruction_table[get_hex(family)][funct3][slice_7]

        rs1 = instruction[-20:-15]
        rs2 = instruction[-25:-20]
        rd = instruction[-12:-7]

        return get_output(instr=instruction_name, rs1=rs1, rd=rd, rs2=rs2, debug=debug)

    elif get_hex(family) == '0x0b':
        funct3 = get_int(instruction[-15:-12])

        slice_3 = get_int(instruction[:3])
        slice_2 = get_int(instruction[-29:-27])

        instruction_name = instruction_table[get_hex(family)][funct3][slice_2][slice_3]

        rs1 = instruction[-20:-15]
        rd = instruction[-12:-7]

        if slice_2 != '2':
            rs2 = instruction[-25:-20]
            return get_output(instr=instruction_name, rs1=rs1, rd=rd, rs2=rs2, debug=debug)
        else:
            return get_output(instr=instruction_name, rs1=rs1, rd=rd, debug=debug)

    elif get_hex(family) == '0x14':
        slice_5 = get_int(instruction[:5])
        slice_2 = get_int(instruction[-27:-25])

        rs2 = instruction[-25:-20]
        rs1 = instruction[-20:-15]
        rd = instruction[-12:-7]

        if slice_5 in ['4', '5', '20', '30']:
            funct3 = get_int(instruction[-15:-12])
            instruction_name = instruction_table[get_hex(family)][slice_5][slice_2][funct3]
            if slice_5 == '30':
                return get_output(instr=instruction_name, rs1=rs1, rd=rd, debug=debug)
            else:
                return get_output(instr=instruction_name, rs1=rs1, rs2=rs2, rd=rd, debug=debug)

        elif slice_5 == '8':
            instruction_name = instruction_table[get_hex(family)][slice_5][get_int(rs2)]
            rm = instruction[-15:-12]
            return get_output(instr=instruction_name, rs1=rs1, rd=rd, rm=rm, debug=debug)

        elif slice_5 == '24' or slice_5 == '26':
            instruction_name = instruction_table[get_hex(family)][slice_5][slice_2][get_int(rs2)]
            rm = instruction[-15:-12]
            return get_output(instr=instruction_name, rs1=rs1, rd=rd, rm=rm, debug=debug)

        elif slice_5 == '28':
            funct3 = get_int(instruction[-15:-12])
            instruction_name = instruction_table[get_hex(family)][slice_5][slice_2][get_int(rs2)][funct3]
            return get_output(instr=instruction_name, rs1=rs1, rd=rd, debug=debug)

        else:
            instruction_name = instruction_table[get_hex(family)][slice_5][slice_2]
            rm = instruction[-15:-12]
            return get_output(instr=instruction_name, rs1=rs1, rs2=rs2, rd=rd, rm=rm, debug=debug)

    elif get_hex(family) == '0x01':
        funct3 = get_int(instruction[-15:-12])
        instruction_name = instruction_table[get_hex(family)][funct3]

        rs1 = instruction[-20:-15]
        rd = instruction[-12:-7]
        imm12 = instruction[:12]

        return get_output(instr=instruction_name, rd=rd, imm12=imm12, rs1=rs1, debug=debug)

    elif get_hex(family) == '0x09':
        funct3 = get_int(instruction[-15:-12])
        instruction_name = instruction_table[get_hex(family)][funct3]

        rs1 = instruction[-20:-15]
        rs2 = instruction[-25:-20]
        imm12lo = instruction[6] + instruction[-12:-7]
        imm12hi = instruction[:6]

        return get_output(instr=instruction_name, rs1=rs1, imm12lo=imm12lo, imm12hi=imm12hi, rs2=rs2, debug=debug)

    elif get_hex(family) in ['0x10', '0x11', '0x12', '0x13']:
        slice_2 = get_int(instruction[-27:-25])
        instruction_name = instruction_table[get_hex(family)][slice_2]

        rs1 = instruction[-20:-15]
        rs2 = instruction[-25:-20]
        rs3 = instruction[:5]
        rm = instruction[-15:-12]

        return get_output(instr=instruction_name, rs1=rs1, rs2=rs2, rm=rm, debug=debug)

    elif get_hex(family) == '0x1c':
        funct3 = get_int(instruction[-15:-12])

        if funct3 == '0':
            slice_12 = get_int(instruction[:12])

            if slice_12 == '260':
                instruction_name = instruction_table[get_hex(family)][funct3][slice_12]
                rs1 = instruction[-20:-15]
                return get_output(instr=instruction_name, rs1=rs1, debug=debug)
            else:
                instruction_name = instruction_table[get_hex(family)][funct3][slice_12]
                return get_output(instr=instruction_name, debug=debug)

        else:
            instruction_name = instruction_table[get_hex(family)][funct3]

            rs1 = instruction[-20:-15]
            rd = instruction[-12:-7]
            imm12 = instruction[:12]
            return get_output(instr=instruction_name, rd=rd, imm12=imm12, rs1=rs1, debug=debug)

    else:
        print("Instruction does not match any known instruction")
        print("Family :" + family)
