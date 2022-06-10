#include <unistd.h>

int rand(void) {
  int answers[] = { 20, 22, 12, 34, 56, 67 };
  static int count = 0;

  return answers[count++];
}

// Just for laziness
unsigned int sleep(unsigned int seconds) {
  return 0;
}
