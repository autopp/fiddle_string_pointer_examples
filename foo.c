#include <stdio.h>

static char *strs[] = { "aaa", "bbb", "ccc", "ddd", "eee", NULL };

char **get_strs_direct() {
  return strs;
}

int get_strs_indirect(char ***ptr) {
  *ptr = strs;
  return sizeof(strs) / sizeof(*strs) - 1;
}
