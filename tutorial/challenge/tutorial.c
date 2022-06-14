#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define BUF_SZ 64

int decodenibble(char a) {
  if (a >= '0' && a <= '9') {
    return a - '0';
  }
  if (a >= 'a' && a <= 'f') {
    return (a - 'a') + 10;
  }
  if (a >= 'A' && a <= 'F') {
    return (a - 'A') + 10;
  }
  return -1;
}

int decodehex(const char *src) {
  int high = decodenibble(*src);
  if (high == -1)
    return -1;
  int low = decodenibble(src[1]);
  if (low == -1)
    return -1;
  return (high << 4) | low;
}

int readhex(char *dest) {
  char buf[BUF_SZ];
  int done = 0;
  while(1) {
    ssize_t len = read(STDIN_FILENO, buf, BUF_SZ);
    if (len < 1) {
      break;
    }
    for (int i=0; i<len; i+=2) {
      int ch = decodehex(&buf[i]);
      if (ch == -1) {
        return done;
      }
      dest[done++] = (char)(ch);
    }
  }
  return done;
}

void jmpesp();
__asm__(".global jmpesp\njmpesp:\njmp *%esp");

void challenge() {
  char dest[BUF_SZ];
  printf("Allocated a %d byte buffer at %p\n", BUF_SZ, dest);
  printf("There happens to be a `jmp esp` instruction at %p.\n", jmpesp);
  void *raddr = __builtin_extract_return_addr(__builtin_return_address(0));
  void *fp = __builtin_frame_address(0);
  fp = (void *)((char *)fp + sizeof(void *));
  if (*(void **)fp != raddr) {
    printf("Not the right place!\n");
    exit(1);
  }
  printf("EIP from the calling function is %p and saved at %p.\n", raddr, fp);
  printf("Send whatever you'd like as hex-encoded bytes, followed by a newline.\n");
  printf("Do not include anything but the hex characters.\n");
  printf("\"Hello World!\" would be 48656c6c6f20576f726c6421.\n");
  printf("---------------------------------------------\n\n");
  readhex(dest);
}

int main(int argc, char **argv) {
  setvbuf(stdout, NULL, _IONBF, 0);
  printf("This is a simple tutorial pwnable.\n");
  printf("Stack cookies, ASLR, and NX are all disabled.\n");
  printf("The flag is in /home/ctf/flag.txt.\n");
  printf("Good luck!\n");
  printf("---------------------------------------------\n\n");
  challenge();
  return 0;
}
