#=================================================================================
# Global Variables
#=================================================================================
ROOT_DIR := $(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
PROJ = $(shell basename $(ROOT_DIR))
COMMON_DIR := $(ROOT_DIR)/common/
SRC_DIR := $(ROOT_DIR)/src/
RUNTIME := $(ROOT_DIR)/common/crt0.S
RUNTIME_OBJS := $(notdir $(basename $(RUNTIME))).o
STDLIB_SRC := $(shell find $(COMMON_DIR) -name "*.c")
STDLIB_OBJS := $(addsuffix .o, $(notdir $(basename $(STDLIB_SRC))))
OUT_DIR := $(ROOT_DIR)/build/
HDRFILES := $(addprefix -I, $(shell find $(INCLUDE_DIR) -name "*.h"))
SRCFILES := $(shell find $(SRC_DIR) -name "*.c")
SRC_OBJS := $(addsuffix .o, $(notdir $(basename $(SRCFILES))))
OBJS = $$(find $(OUT_DIR) -name "*.o")
#=================================================================================
# Making GCC Acronyms
#=================================================================================

LDFLAGS = -nostartfiles  -nostdlib  -T$(ROOT_DIR)/common/link.ld -Map=$(OUT_DIR)/$(PROJ).map
CCFLAGS = -march=rv32i -std=gnu99 -ffast-math -fno-builtin-printf

#=================================================================================
# GCC Acronyms
#=================================================================================
CROSS = riscv32-unknown-elf
CC  = $(CROSS)-gcc
AS  = $(CROSS)-as
LD  = $(CROSS)-ld
OC  = $(CROSS)-objcopy
OD  = $(CROSS)-objdump
CPP = $(CROSS)-cpp

#=================================================================================
# Targets and Rules
#=================================================================================
all: prep runtime $(SRC_OBJS)
	$(LD) $(LDFLAGS) -o $(OUT_DIR)/$(PROJ).elf $(OBJS)
	$(OD) -D $(OUT_DIR)/$(PROJ).elf > $(OUT_DIR)/$(PROJ).obj
	$(OC) -O binary $(OUT_DIR)/$(PROJ).elf $(OUT_DIR)/$(PROJ).text --only-section .init --only-section .text
	python3 $(COMMON_DIR)/makehex.py $(OUT_DIR)/$(PROJ).text 8192 > $(OUT_DIR)/$(PROJ)_text.hex
	$(OC) -O binary $(OUT_DIR)/$(PROJ).elf $(OUT_DIR)/$(PROJ).data --only-section .rodata --only-section .sdata  --only-section .sdata* --only-section .sbss* --only-section .bss 
	python3 $(COMMON_DIR)/makehex.py $(OUT_DIR)/$(PROJ).data 8192 > $(OUT_DIR)/$(PROJ)_data.hex

runtime:
	echo $(SRC_DIR)
	$(CC) $(CCFLAGS) -I$(COMMON_DIR) -c $(RUNTIME) -o $(OUT_DIR)/$(RUNTIME_OBJS)
	$(CC) $(CCFLAGS) -I$(COMMON_DIR) -c $(STDLIB_SRC) -o $(OUT_DIR)/$(STDLIB_OBJS)

prep:
	@mkdir -p $(OUT_DIR)

%.o: $(SRC_DIR)/%.c
	$(CC) $(CCFLAGS) -I$(COMMON_DIR) $(HDRFILES) -c $< -o $(OUT_DIR)/$@

.PHONY: clean
clean:
	rm -rf $(OUT_DIR)
