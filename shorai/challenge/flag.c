#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>

#define MICROS_PER_MILLI 1000
#define DEFAULT_SLEEP 500 * MICROS_PER_MILLI
#define MAX_SLEEP DEFAULT_SLEEP * 16

void bounded_sleep(int i) {
  useconds_t tm = (1 << (useconds_t)(i)) * DEFAULT_SLEEP;
  if (tm > MAX_SLEEP)
    tm = MAX_SLEEP;
  usleep(tm);
}

int scmp(char *a, char *b) {
  if (a == b)
    return 0;
  if (!a || !b)
    return 0xFFFFFFFF;
  char cmp = 0;
  while(1) {
    cmp |= *a ^ *b;
    if (!*a || !*b) break;
    a++; b++;
  }
  return cmp;
}

void getflag() {
  if (scmp(getenv("MAGIC_WORD"), (char *)"Pl3453")) {
    int i=0;
    while(1) {
      puts("ah, ah, ah, you didn't say the magic word!");
      bounded_sleep(i++);
    }
    return;
  }
  puts("CTF{r3v3rsing_for_funds_and_profits}");
}
