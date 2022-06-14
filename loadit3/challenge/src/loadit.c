#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>

// For future me:
//
// irb(main):037:0> flag = "CTF{i_win_i_win_ding_ding_ding}"
// => "CTF{i_win_i_win_ding_ding_ding}"
//
// irb(main):038:0> key = SecureRandom::bytes(flag.length)
// => "`\x1C\x11[\xF8\x14\x93\xC8\xBF4\xE1n\a\f\x8BTP\xB7mW\x9C\x1E\xF4T\x04\xC1\x18Y\xD8j\xBA"
//
// irb(main):039:0> puts 0.upto(flag.length - 1).map { |i| "\\x%02x" % (flag[i].ord ^ key[i].ord) }.join
// \x23\x48\x57\x20\x91\x4b\xe4\xa1\xd1\x6b\x88\x31\x70\x65\xe5\x0b\x34\xde\x03\x30\xc3\x7a\x9d\x3a\x63\x9e\x7c\x30\xb6\x0d\xc7
// => nil
//
// irb(main):040:0> puts key.bytes.map { |b| '\x%02x' % b }.join()
// \x60\x1c\x11\x5b\xf8\x14\x93\xc8\xbf\x34\xe1\x6e\x07\x0c\x8b\x54\x50\xb7\x6d\x57\x9c\x1e\xf4\x54\x04\xc1\x18\x59\xd8\x6a\xba
// => nil

#define KEY "\x23\x48\x57\x20\x91\x4b\xe4\xa1\xd1\x6b\x88\x31\x70\x65\xe5\x0b\x34\xde\x03\x30\xc3\x7a\x9d\x3a\x63\x9e\x7c\x30\xb6\x0d\xc7"
#define FLAG "\x60\x1c\x11\x5b\xf8\x14\x93\xc8\xbf\x34\xe1\x6e\x07\x0c\x8b\x54\x50\xb7\x6d\x57\x9c\x1e\xf4\x54\x04\xc1\x18\x59\xd8\x6a\xba"

#define N1 20
#define N2 22
#define N3 12
#define N4 34
#define N5 56
#define N6 67

int main(int argc, char *argv[]) {
  int problems = 0;
  int choice;

  srand(time(NULL));

  printf("Drawing lottery numbers!\n");
  printf("\n");
  printf("My lucky numbers are: %d %d %d %d %d %d\n", N1, N2, N3, N4, N5, N6);
  printf("\n");
  printf("I hope I win the lottery!\n");

  printf("\n");
  printf("Drawing a number....... ");
  sleep(1);
  choice = rand() % 100;
  printf("%d!\n", choice);
  if(choice == N1) {
    printf("It's a match!!\n\n");
  } else {
    printf("We wanted %d, sad trombone :(\n", N1);
    problems++;
  }

  printf("\n");
  printf("Drawing a number....... ");
  sleep(1);
  choice = rand() % 100;
  printf("%d!\n", choice);
  if(choice == N2) {
    printf("It's a match!!\n\n");
  } else {
    printf("We wanted %d, sad trombone :(\n", N2);
    problems++;
  }

  printf("\n");
  printf("Drawing a number....... ");
  sleep(1);
  choice = rand() % 100;
  printf("%d!\n", choice);
  if(choice == N3) {
    printf("It's a match!!\n\n");
  } else {
    printf("We wanted %d, sad trombone :(\n", N3);
    problems++;
  }

  printf("\n");
  printf("Drawing a number....... ");
  sleep(1);
  choice = rand() % 100;
  printf("%d!\n", choice);
  if(choice == N4) {
    printf("It's a match!!\n\n");
  } else {
    printf("We wanted %d, sad trombone :(\n", N4);
    problems++;
  }

  printf("\n");
  printf("Drawing a number....... ");
  sleep(1);
  choice = rand() % 100;
  printf("%d!\n", choice);
  if(choice == N5) {
    printf("It's a match!!\n\n");
  } else {
    printf("We wanted %d, sad trombone :(\n", N5);
    problems++;
  }

  printf("\n");
  printf("Drawing a number....... ");
  sleep(1);
  choice = rand() % 100;
  printf("%d!\n", choice);
  if(choice == N6) {
    printf("It's a match!!\n\n");
  } else {
    printf("We wanted %d, sad trombone :(\n", N6);
    problems++;
  }

  printf("\n");
  if(problems > 0) {
    printf("Sorry, you only got %d out of %d correct!\n", 6 - problems, 6);
    printf("Better luck next time! Hopefully rand() returns better values for you next time");
    exit(1);
  }

  printf("You did it!! Here's your prize:\n");
  printf("\n");

  int i;
  for(i = 0; i < sizeof(KEY); i++) {
    printf("%c", KEY[i] ^ FLAG[i]);
    fflush(stdout);
  }
  printf("\n");

  return 0;
}
