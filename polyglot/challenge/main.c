#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

// #define KEY  "This program cannot be run in DOS mode."
// #define FLAG "CTF{technically_correct_is_best_correct}"
#define ENCODED_FLAG "\x17\x3c\x2f\x08\x54\x15\x11\x07\x09\x1b\x02\x0c\x4c\x0f\x18\x31\x0d\x00\x06\x52\x07\x06\x54\x2d\x1c\x1d\x7f\x0b\x0b\x53\x30\x10\x30\x4f\x1f\x1d\x01\x06\x5a\x77"

int main(int argc, char *argv[]) {
  int i;
  char key[sizeof(ENCODED_FLAG)];

  printf("Figure out the polyglot and enter the key here --> ");
  fgets(key, sizeof(ENCODED_FLAG), stdin);

  for(i = 0; i < sizeof(ENCODED_FLAG) - 1; i++) {
    char c = (ENCODED_FLAG[i] ^ key[i]);
    printf("%c", (c < 0x20 || c > 0x7e) ? '?' : c);
  }

  return 0;
}