#include <stdio.h>
#include <dlfcn.h>
#include <errno.h>
#include <string.h>

int main(int argc, char **argv) {
  void *handle = dlopen("./flag.so", RTLD_LAZY);
  if (handle == NULL) {
    printf("Failed dlopen: %s\n", dlerror());
    return 1;
  }

  void (*func)() = NULL;
  func = (void (*)())dlsym(handle, "getflag");
  if (func == NULL) {
    printf("Failed dlsym: %s\n", dlerror());
    return 1;
  }
  func();

  dlclose(handle);
  return 0;
}
