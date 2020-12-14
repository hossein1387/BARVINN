# tst_arry = np.asarray(range(0,256))
# for val in tst_arry:
#     tst_arry_bin.append("{0:08b}".format(val))

# for val in tst_arry_bin:
#     txt_str = val + txt_str

# num_str = [int(txt_str[i:i+n],2) for i in range(0, len(txt_str), n)]

vals = range(192,256)
vals_str = []
vals_str = ["{0:08b}".format(val) for val in vals]

def transpose(arry):
    # import ipdb as pdb; pdb.set_trace()
    val_transposed_str = ["" for i in range(0,len(arry[0]))]
    for val in arry:
        for i,char in enumerate(val):
            val_transposed_str[i] = char + val_transposed_str[i]
    return val_transposed_str

val_transposed = transpose(vals_str)
n = 4
for val in val_transposed:
    num_str = [hex(int(val[i:i+n],2)).split("0x")[1] for i in range(0, len(val), n)]
    num_str = "".join(num_str)
    print(num_str)