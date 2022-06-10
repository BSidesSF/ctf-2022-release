#include <stdio.h>
#include <unistd.h>

#define STARTING_TIME 100000 // ms

// For future me:
//
// irb(main):024:0> a = ['a3913193b844e32cb8f1897c78a91457ff03461d2a03d8e546711c8d'].pack('H*')
// => "\xA3\x911\x93\xB8D\xE3,\xB8\xF1\x89|x\xA9\x14W\xFF\x03F\x1D*\x03\xD8\xE5Fq\x1C\x8D"
//
// irb(main):025:0> b = "CTF{load_it_like_you_got_it}"
// => "CTF{load_it_like_you_got_it}"
//
// irb(main):026:0> puts 0.upto(a.length - 1).map { |i| "\\x%02x" % (a[i].ord ^ b[i].ord) }.join
// \xe0\xc5\x77\xe8\xd4\x2b\x82\x48\xe7\x98\xfd\x23\x14\xc0\x7f\x32\xa0\x7a\x29\x68\x75\x64\xb7\x91\x19\x18\x68\xf0

#define KEY "\xa3\x91\x31\x93\xb8\x44\xe3\x2c\xb8\xf1\x89\x7c\x78\xa9\x14\x57\xff\x03\x46\x1d\x2a\x03\xd8\xe5\x46\x71\x1c\x8d"
#define FLAG "\xe0\xc5\x77\xe8\xd4\x2b\x82\x48\xe7\x98\xfd\x23\x14\xc0\x7f\x32\xa0\x7a\x29\x68\x75\x64\xb7\x91\x19\x18\x68\xf0"

int main(int argc, char *argv[]) {
  int i;

  printf("This sleeps longer and lonnnnnger and lonnnnnnnnnnnger!\n");
  printf("\n");
  printf("Try using `ltrace ./loadit1` to see what's going on, then use the files from `skeleton.zip` to solve it!");
  printf("\n");

  int sleep_time = STARTING_TIME;
  for(i = 0; i < sizeof(KEY); i++) {
    printf("%c", KEY[i] ^ FLAG[i]);
    fflush(stdout);
    usleep(sleep_time);
    sleep_time = sleep_time * 2;
  }
  printf("\n");

  return 0;
}
