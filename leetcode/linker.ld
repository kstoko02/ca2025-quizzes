/* linker.ld - 簡單裸機 linker script for rv32emu */

ENTRY(_start)

MEMORY
{
    RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 512K
}

SECTIONS
{
    .text : {
        _start = .;
        *(.text*)
        _etext = .;
    } > RAM

    .data : AT(_etext) {
        _data = .;
        *(.data*)
        _edata = .;
    } > RAM

    .bss : {
        _bss_start = .;
        *(.bss*)
        *(COMMON)
        _bss_end = .;
    } > RAM
}

