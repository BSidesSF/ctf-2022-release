#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <limits.h>

#define MAX_NUMS 65536

struct fibcache {
  uint64_t nums[MAX_NUMS];
  int maxnum;
};

int cme(const char *path);

uint64_t getfib(struct fibcache *c, int num) {
  if (num < c->maxnum) {
    return c->nums[num-1];
  }
  if (c->maxnum < 2) {
    c->nums[0] = 1;
    c->nums[1] = 1;
    c->maxnum = 2;
  }
  for(;c->maxnum < num; c->maxnum++) {
    c->nums[c->maxnum] = c->nums[c->maxnum-1] + c->nums[c->maxnum-2];
  }
  return c->nums[num-1];
}

int main(int argc, char **argv) {
  struct fibcache cache;
  char buf[256];

  memset(&cache, 0, sizeof(cache));
  setvbuf(stdout, NULL, _IONBF, 0);

  printf("Want to run this service locally? Try `exe`!\n");

  while(1) {
    printf("Fibonnaci number> ");
    if (!fgets(buf, INT_MAX, stdin)) {
      return 0;
    }
    if (*buf == '\0' || *buf == '\n') {
      return 0;
    }
    buf[strcspn(buf, "\n\r")] = '\0';
    if (!strcmp(buf, "exe")) {
      cme("/proc/self/exe");
      return 0;
    }
    int n = atoi(buf);
    if (!n) {
      break;
    }
    uint64_t fib = getfib(&cache, n);
    printf("fib(%d) = %lu\n", n, fib);
  }
  return 0;
}

int cme(const char *path) {
  FILE *fp = fopen(path, "r");
  if (!fp) {
    return -1;
  }
  int c;
  int n = 0;
  while ((c = fgetc(fp)) != EOF) {
    if (n % 16 == 0) {
      printf("%08x  ", n);
    }
    printf("%02x", c);
    ++n;
    if (n % 16 == 0) {
      printf("\n");
    } else {
      printf(" ");
    }
  }
  fclose(fp);
  return 0;
}
