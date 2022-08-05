OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY {
  MEM : ORIGIN = 0x00000000, LENGTH = 0x00002000
}

SECTIONS
{
    .text : {
    *(.text.init)
    *(.text)
  } > MEM
  .data : {
    . = ALIGN(0x10);
    *(.data)
  } > MEM
  .data.string : { *(.data.string)}
  .bss : { *(.bss) }
  _end = .;
}

