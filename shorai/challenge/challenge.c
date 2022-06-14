#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#include <stdio.h>
#include <dlfcn.h>
#include <string.h>
#include <malloc.h>
#include <openssl/crypto.h>
#include <openssl/evp.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <unistd.h>
#include <openssl/err.h>

extern size_t E_LEN;
extern const uint8_t E_KEYSUM[];
extern const uint8_t E_DATA[];
extern const uint8_t E_SALT[];
extern const uint8_t E_MAC[];
extern const uint8_t E_IV[];
extern const uint8_t PPPP[];
extern const uint8_t FFFF[];
const char nibbles[] = "0123456789abcdef";

size_t round_up_page(size_t n);
int self_test();
ssize_t loader(uint8_t *dest, char *hexkey);
int expect_byte(char c, char d);
int validate_key(char *key);


int main(int argc, char **argv) {
  int rv;
  char fdp[256];
  if (argc != 2)
    return 1;
  if ((rv = self_test()) != 0) {
    printf("BUG IN CHALLENGE: SELF TEST FAILED\n");
    return rv;
  }
  if ((rv = validate_key(argv[1])) != 0)
    return rv;
  // allocate dest
  size_t flen = round_up_page(E_LEN);
  int fd = memfd_create(argv[0], MFD_CLOEXEC);
  if (fd == -1) {
    return 2;
  }
  if (ftruncate(fd, flen)) {
    return 3;
  }
  uint8_t *buf = (uint8_t *)mmap(NULL, flen, PROT_WRITE|PROT_READ|PROT_EXEC, MAP_SHARED, fd, 0);
  if (buf == NULL)
    return 4;
  if (loader(buf, argv[1]) < 1) {
    return 5;
  }

  // hehe, load /proc/%d/fd/%d for funsies
  memset(fdp, 0, sizeof(fdp));
  memcpy(fdp, PPPP, (size_t)(*PPPP)+1);
  char k = *PPPP;
  for (int i=0;i<=k;i++)
    fdp[i] ^= k;
  fdp[k+3] = '\0';
  char *fdpp = fdp+k+4;
  int e = snprintf(fdpp, sizeof(fdp)-(k+5), &fdp[1], gettid(), fd);
  fdpp[e] = '\0';

  // Now dlopen
  void *dlh = dlopen(fdpp, RTLD_NOW|RTLD_LOCAL);
  if (!dlh) {
    return 9;
  }

  // Now the function name
  memset(fdp, 0, sizeof(fdp));
  memcpy(fdp, FFFF, (size_t)(*FFFF)+1);
  k = *FFFF;
  for (int i=0;i<=k;i++)
    fdp[i] ^= k;
  memmove(fdp, &fdp[1], sizeof(fdp)-1);
  void (*func)() = NULL;
  func = (void (*)())dlsym(dlh, fdp);
  if (!func) {
    return 10;
  }

  func();
  return 0;
}

int self_test() {
  if (round_up_page(1) != 0x1000)
    return 6;
  if (round_up_page(4096) != 0x1000)
    return 7;
  if (round_up_page(8191) != 0x2000)
    return 8;
  uint16_t bitmap = 0;
  for (int i=0; i<0x10; i++) {
    char d = expect_byte(nibbles[i], 0xFF);
    for (int k=0; k<0x10; k++) {
      if (nibbles[k] == d) {
        uint16_t bit = 1 << k;
        if (bitmap & bit)
          return 11;
        bitmap |= bit;
      }
    }
  }
  if (bitmap != 0xFFFF)
    return 12;
  return 0;
}

size_t round_up_page(size_t n) {
  n += 0xFFF;
  return n & ~0xFFF;
}

ssize_t loader(uint8_t *dest, char *hexkey) {
  unsigned char rawkey[256/8];
  long klen;
  unsigned char *keybuf = OPENSSL_hexstr2buf(hexkey, &klen);
  if (!keybuf) {
    printf("OPENSSL_hexstr2buf\n");
    return -1;
  }
  if (klen != sizeof(rawkey)) {
    printf("sz\n");
    OPENSSL_free(keybuf);
    return -1;
  }
  memcpy(rawkey, keybuf, klen);
  memset(keybuf, 0, klen);
  OPENSSL_free(keybuf);
  EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
  EVP_CIPHER_CTX_init(ctx);
  if (!EVP_DecryptInit_ex(ctx, EVP_aes_256_gcm(), NULL, rawkey, E_IV)) {
    printf("EVP_DecryptInit_ex\n");
    ERR_print_errors_fp(stderr);
    EVP_CIPHER_CTX_free(ctx);
    return -1;
  }
  if (!EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_TAG, 16, (void *)E_MAC)) {
    printf("EVP_CIPHER_CTX_ctrl\n");
    ERR_print_errors_fp(stderr);
    EVP_CIPHER_CTX_free(ctx);
    return -1;
  }
  int len = 0;
  if (!EVP_DecryptUpdate(ctx, dest, &len, E_DATA, E_LEN)) {
    printf("EVP_DecryptUpdate\n");
    ERR_print_errors_fp(stderr);
    EVP_CIPHER_CTX_free(ctx);
    return -1;
  }
  int flen;
  if (!EVP_DecryptFinal_ex(ctx, dest+len, &flen)) {
    printf("EVP_DecryptFinal_ex\n");
    ERR_print_errors_fp(stderr);
    EVP_CIPHER_CTX_free(ctx);
    return -1;
  }
  return len+flen;
}

int validate_key(char *key) {
  int rv;
  int i = 0;
  for (char *p = key; *p; p++) {
    rv = expect_byte(*p, E_KEYSUM[i++]);
    if (rv)
      return rv;
  }
  return 0;
}

int expect_byte(char c, char d) {
  unsigned char tmpbuf[3] = {0};
  unsigned char outbuf[256/8] = {0};
  memcpy(tmpbuf, E_SALT, 2);
  tmpbuf[2] = c;
  d ^= 0xFF;
  if (EVP_MD_size(EVP_sha256()) != sizeof(outbuf)) {
    return -1;
  }
  EVP_MD_CTX *ctx = EVP_MD_CTX_create();
  if (ctx == NULL) {
    return -1;
  }
  if (!EVP_DigestInit_ex(ctx, EVP_sha256(), NULL)) {
    EVP_MD_CTX_destroy(ctx);
    return -1;
  }
  if (!EVP_DigestUpdate(ctx, tmpbuf, sizeof(tmpbuf))) {
    EVP_MD_CTX_destroy(ctx);
    return -1;
  }
  if (!EVP_DigestFinal_ex(ctx, outbuf, NULL)) {
    EVP_MD_CTX_destroy(ctx);
    return -1;
  }
  EVP_MD_CTX_destroy(ctx);
  int nibble = outbuf[sizeof(outbuf)-1] & 0xF;
  return d ^ nibbles[nibble];
}
