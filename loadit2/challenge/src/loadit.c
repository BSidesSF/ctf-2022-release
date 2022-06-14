#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>

#define STARTING_TIME 100000 // ms

#define KEY "\x09\xa9\xd4\x55\x0d\x3d\xcd\x74\x4c\x9b\x24\xbe\x8c\x9d\x92\x36\x05\x54\xaf\xe7\x10\x8c\xd4\xd9\xaf\xec\x24\x8f\x1f"
#define FLAG "\x4a\xfd\x92\x2e\x64\x53\x92\x00\x24\xfe\x7b\xce\xe5\xed\xf7\x69\x63\x3d\xd9\x82\x4f\xee\xad\x86\xc9\x85\x52\xea\x62"

int main(int argc, char *argv[]) {
  int i;

  char a[] = "AAAAAAAAAAAAAAAA";
  char b[] = "BBBBBBBBBBBBBBBB";

  printf("Performing check (try ltrace to see what the check is!)......\n");
  if(strcmp(a, b)) {
    printf("\nCheck failed!\n");
    exit(0);
  }

  printf("\nSucceeded!\n\n");
  for(i = 0; i < sizeof(KEY); i++) {
    printf("%c", KEY[i] ^ FLAG[i]);
    fflush(stdout);
  }
  printf("\n");

  return 0;
}
