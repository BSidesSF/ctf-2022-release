#include <stdio.h>
#include <stdint.h>
#include <arpa/inet.h>
#include <unistd.h>

#define MAX_BUFFER 256
#define MAX_DEST_SIZE MAX_BUFFER*4

typedef void(*callback)(char *src, char *dst, uint16_t len);

struct converter {
  uint16_t len;
  char buf[MAX_BUFFER];
  callback handler;
};

void print_converted(struct converter *c) {
  char dest[MAX_DEST_SIZE];
  c->handler((char *)c->buf, (char *)dest, c->len);
  printf("%s\n", dest);
}

void convert_hex(char *src, char *dst, uint16_t len) {
  const char alphabet[] = "0123456789abcdef";
  for (int i=0; i<len; i++) {
    *dst++ = alphabet[src[i] >> 4];
    *dst++ = alphabet[src[i] & 0xf];
    *dst++ = ' ';
  }
  *dst = '\0';
}

void choose_converter(callback cb1, callback cb2, uint16_t which, char *src, char *dst, uint16_t len) {
  if (which & 1)
    cb1(src, dst, len);
  else
    cb2(src, dst, len);
}

int main(int argc, char **argv) {
  struct converter ct;
#if 0
  fprintf(stderr, "print_converted %p convert_hex %p choose_converter %p\n",
      &print_converted, &convert_hex, &choose_converter);
#endif
  read(STDIN_FILENO, &ct.len, sizeof(ct.len));
  ct.len = ntohs(ct.len);
  fprintf(stderr, "len %d\n", ct.len);
  fflush(stderr);
  if (ct.len > MAX_DEST_SIZE) {
    printf("Error: too long!\n");
    fflush(stdout);
    return 1;
  }
  ct.handler = convert_hex;
  read(STDIN_FILENO, &ct.buf, ct.len);
  print_converted(&ct);
  return 0;
}
