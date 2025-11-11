#include <stdio.h>
#include <stdint.h>

extern uint64_t mul32(uint32_t a, uint32_t b);

void print_q16(uint32_t y) {
    uint32_t int_part = y >> 16; 
    uint32_t frac_part = y & 0xFFFF;  

    uint64_t tmp = (uint64_t)(mul32(frac_part, 1000000));
    uint32_t frac_scaled = (uint32_t)(tmp >> 16); 

    printf("y/2^16 = %u.%06u\n", int_part, frac_scaled);
}
