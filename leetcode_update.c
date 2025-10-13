#include <stdio.h>
#include <stdint.h>
#include <string.h>

#define MAX_WORDS 100
#define MAX_LEN 100

// 計算整數 x 的最高位（0-indexed, -1 表示 x==0）
int highest_bit(uint32_t x) {
    if (x == 0) return -1;
    return 31 - __builtin_clz(x);
}

int maxProduct(char *words[], int n) {
    int mask[MAX_WORDS] = {0};
    int ans = 0;

    // 建立 bitmask
    for (int i = 0; i < n; i++) {
        for (int j = 0; words[i][j]; j++)
            mask[i] |= 1 << (words[i][j] - 'a');
    }

    // 記錄最高位和索引
    int highest[MAX_WORDS];
    for (int i = 0; i < n; i++)
        highest[i] = highest_bit(mask[i]);

    // 用簡單選擇排序按最高位排序（從大到小）
    int indices[MAX_WORDS];
    for (int i = 0; i < n; i++)
        indices[i] = i;

    for (int i = 0; i < n - 1; i++) {
        for (int j = i + 1; j < n; j++) {
            if (highest[indices[i]] < highest[indices[j]]) {
                int tmp = indices[i];
                indices[i] = indices[j];
                indices[j] = tmp;
            }
        }
    }

    // 比較單字
    for (int i = 0; i < n; i++) {
        int idx1 = indices[i];
        for (int j = i + 1; j < n; j++) {
            int idx2 = indices[j];

            // 剪枝：如果長度乘積不可能大於 ans
            int prod = (int)strlen(words[idx1]) * (int)strlen(words[idx2]);
            if (prod <= ans) break;

            if ((mask[idx1] & mask[idx2]) == 0)
                if (prod > ans) ans = prod;
        }
    }

    return ans;
}

int main() {
    // 測資 1
    char *test1[] = {"abcw", "baz", "foo", "bar", "xtfn", "abcdef"};
    int n1 = sizeof(test1)/sizeof(test1[0]);
    printf("Test1: %d\n", maxProduct(test1, n1));

    // 測資 2
    char *test2[] = {"a", "ab", "abc", "d", "cd", "bcd", "abcd"};
    int n2 = sizeof(test2)/sizeof(test2[0]);
    printf("Test2: %d\n", maxProduct(test2, n2));

    // 測資 3
    char *test3[] = {"a", "aa", "aaa", "aaaa"};
    int n3 = sizeof(test3)/sizeof(test3[0]);
    printf("Test3: %d\n", maxProduct(test3, n3));

    return 0;
}




