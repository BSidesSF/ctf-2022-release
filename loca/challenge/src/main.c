#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define CHALLENGE_LENGTH 31
#define RESPONSE_LENGTH 32
#define MAX_GUESSES 3

#define disable_buffering(_fd) setvbuf(_fd, NULL, _IONBF, 0)

char *key = "THIS_IS_KINDA_SORTA_MAYBE_AN_IV!!";

int main(int argc, char *argv[]) {
  unsigned int seed = 0xabf25330; // This must be first!
  int i;

  // Challenge (random)
  char challenge[CHALLENGE_LENGTH + 1];

  // This keeps these adjacent
  struct {
    char response[RESPONSE_LENGTH];
    char *key_position;
  } state;

  state.key_position = key;

  srand(time(NULL));
  disable_buffering(stdout);
  disable_buffering(stderr);

  memset(challenge, 0, CHALLENGE_LENGTH + 1);

  // Calculate a challenge
  for(i = 0; i < CHALLENGE_LENGTH; i++) {
    challenge[i] = (rand() % 0x5f) + 0x20;
  }
  printf("Challenge: %s\n", challenge);
  printf("\n");

  // Calculate the response
  for(i = 0; i < CHALLENGE_LENGTH; i++) {
    challenge[i] = ((challenge[i] ^ (seed & 0x000000FF)) % 0x5f) + 0x20;
    seed = (seed >> 1) ^ *state.key_position;
    state.key_position++;
  }

  for(i = 0; i < 3; i++) {
    int j;

    memset(state.response, 0, RESPONSE_LENGTH);
    printf("What is your response? (Try %d of %d)\n", i + 1, MAX_GUESSES);

    read(fileno(stdin), state.response, RESPONSE_LENGTH);
    printf("Your response: %s\n", state.response);

    if(!strncmp(state.response, challenge, CHALLENGE_LENGTH)) {
      char flag[64];
      FILE *f;

      printf("That is correct! Retrieving flag...\n");
      f= fopen("./flag.txt", "r");
      fgets(flag, 64, f);

      printf("Flag: %s\n", flag);
      exit(0);
    }

    printf("Sorry, that is not correct!\n\n");
  }

  printf("Sorry, better luck next time!\n");

	return 0;
}