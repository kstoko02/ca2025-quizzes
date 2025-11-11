#include <stdint.h>
#include <stdio.h>
extern uint32_t fast_rsqrt(uint32_t x);
extern void print_q16(uint32_t y);
extern uint64_t get_cycles();
extern uint64_t get_instret();

int main() {
    uint32_t x = UINT32_MAX;
    uint64_t start_cycles, end_cycles, cycles_elapsed;
    uint64_t start_instret, end_instret, instret_elapsed;
    
    start_instret = get_instret();
    start_cycles = get_cycles();
    
    uint32_t y = fast_rsqrt(x);
    printf("y = %u\n", y);
    print_q16(y);
    
    end_cycles = get_cycles();
    end_instret = get_instret();
    cycles_elapsed = end_cycles - start_cycles;
    instret_elapsed = end_instret - start_instret;
    printf("cycle count: %u\n", (unsigned int) cycles_elapsed);
    printf("instret:  %u\n", (unsigned int) instret_elapsed);
    return 0;
}

