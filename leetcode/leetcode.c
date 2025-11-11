#include <stdio.h>
#include <stdint.h>
#include <string.h>

#define MAX_WORDS 100
#define MAX_LEN 100

extern int highest_bit(uint32_t x);
extern int maxProduct(char *words[], int n);
extern void clear(void);

int main() {
    char *test[] = {"abcdef","abcw", "baz", "foo", "bar", "xtfn"};
    printf("Test: %d\n", maxProduct(test, 6));
    return 0;
}
