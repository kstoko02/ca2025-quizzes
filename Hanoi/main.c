#include <stdio.h>
#include <stdint.h>

extern void hanoi_init(void);
extern void hanoi(int input, int *out1, int *out2, int *out3);
extern void hanoi_finish(void);
extern uint64_t get_cycles();
extern uint64_t get_instret();

int main(void) {
    int disk, rest1, rest2;
    char *str1, *str2;
    uint64_t start_cycles, end_cycles, cycles_elapsed;
    uint64_t start_instret, end_instret, instret_elapsed;
    
    start_instret = get_instret();
    start_cycles = get_cycles();
    hanoi_init();
    printf("=== Start Hanoi ===\n");
    for (int i = 1; i < 8; i++) {
        hanoi(i, &disk, &rest1, &rest2);
        disk = disk + 1;
        switch (rest1) {
        case 0: str1 = "A"; break;
        case 1: str1 = "B"; break;
        case 2: str1 = "C"; break;
        default: printf("str1 = unknown\n"); break;
        }
        switch (rest2) {
        case 0: str2 = "A"; break;
        case 1: str2 = "B"; break;
        case 2: str2 = "C"; break;
        default: printf("str2 = unknown\n"); break;
        }
        printf("Moke Disk %d from %s to %s\n", disk, str1, str2);
    }
    end_cycles = get_cycles();
    end_instret = get_instret();
    cycles_elapsed = end_cycles - start_cycles;
    instret_elapsed = end_instret - start_instret;
    printf("cycle count: %u\n", (unsigned int) cycles_elapsed);
    printf("instret:  %u\n", (unsigned int) instret_elapsed);

    printf("=== Done ===\n");
    return 0;
}
