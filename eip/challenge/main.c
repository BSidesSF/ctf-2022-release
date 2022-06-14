// You're probably not supposed to mix all these feature flags.
// This entire program is an exercise in abusing glibc.
#define _POSIX_C_SOURCE 200112L
#define _XOPEN_SOURCE 600
#define _DEFAULT_SOURCE 1
#define _GNU_SOURCE 1
#ifndef DEBUG
#define DEBUG 1
#endif

#ifndef __i386__
# error "This was designed only for x86 32 bit!"
#endif

#include <signal.h>
#include <stdio.h>
#include <unistd.h>
#include <ucontext.h>
#include <string.h>

void sigsegv_handler(int signum, siginfo_t *info, void *ctxvoid) {
  // Check EIP?
  ucontext_t *uc = (ucontext_t *)ctxvoid;
  mcontext_t *mc = &(uc->uc_mcontext);
#if DEBUG == 1
  printf("EIP is: %p\n", (void *)mc->gregs[REG_EIP]);
#endif
  fflush(stdout);

  if (mc->gregs[REG_EIP] != 0x41414141) {
    _exit(0);
  }

  // This is unsafe, but I'll do it anyway.
  FILE *fp = fopen("./flag.txt", "r");
  if (!fp) {
    fprintf(stderr, "Could not find flag.txt!!\n");
    fflush(stderr);
    _exit(1);
  }
  char buf[256];
  fgets(buf, sizeof(buf), fp);
  fclose(fp);
  puts(buf);
  fflush(stdout);
  _exit(0);
}

__attribute__((constructor))
void setup_signal_handler() {
  struct sigaction segv = {{0}};
  segv.sa_sigaction = sigsegv_handler;
  segv.sa_flags = SA_ONSTACK|SA_SIGINFO;
  sigaction(SIGSEGV, &segv, NULL);
}

void challenge() {
  char buf[64];
  puts("All I want you to do is set EIP to 0x41414141.");
  fflush(stdout);
  read(STDIN_FILENO, buf, 128);
  if (strstr(buf, "AAAAA")) {
    puts("Try more precisely!");
#if DEBUG != 1
    _exit(0);
#endif
  }
}

int main(int argc, char **argv) {
  challenge();
  return 0;
}
