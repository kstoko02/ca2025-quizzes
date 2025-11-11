    .section .bss
    .align 4

    .global mask
mask:       .space 400      # 100 個 int32_t (4 bytes * 100)

    .global highest
highest:    .space 400      # 100 個 int32_t

    .global indices
indices:    .space 400      # 100 個 int32_t

    .global len_arr
len_arr:    .space 400      # 100 個 int32_t

    .section .rodata
    .align 4

    .global newline
newline:
    .asciz "\n"
