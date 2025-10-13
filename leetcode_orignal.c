#include <stdio.h>
#include <string.h>

int maxProduct(char *words[], int n) {
    int mask[1000] = {0};  // 每個單字的 bitmask
    int ans = 0;

    // 建立每個單字的 bitmask
    for (int i = 0; i < n; i++) {
        int m = 0;
        for (int j = 0; words[i][j] != '\0'; j++) {
            m |= 1 << (words[i][j] - 'a');
        }
        mask[i] = m;
    }

    // 比較每對單字
    for (int i = 0; i < n; i++) {
        for (int j = i + 1; j < n; j++) {
            if ((mask[i] & mask[j]) == 0) {  // 沒有共同字母
                int len = strlen(words[i]) * strlen(words[j]);
                if (len > ans) ans = len;
            }
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
