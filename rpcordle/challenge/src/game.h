#include <arpa/inet.h>
#include <stdint.h>
#include <string>
#include <vector>
#include <random>

#define WORD_LEN 5
#define MAX_GUESSES 6
#define MAX_SIMULTANEOUS_GAMES 32
#define DICTIONARY_PATH_LEN 128

class GameState;
class GameRecord;

class GameManager {
  GameState *games[MAX_SIMULTANEOUS_GAMES];
  std::vector<GameRecord *> records;
  char dictionary_path[DICTIONARY_PATH_LEN];
  std::mt19937_64 rng;
  std::vector<std::string> words;

public:
  GameManager(const char *dictionary_path);
  int start_game();
  GameState *get_game(int);
  GameRecord *get_game_record(int);
  int end_game(int);
  std::vector<std::string> read_wordlist();
  const char *get_dictionary_path();
};

enum ResultValue {
  NO_MATCH, // Not in target word
  MATCH_BADPOS, // In word, but in wrong position
  MATCH_OK, // In the right place
};

class GameState {
  in_addr_t remote_addr;
  uint32_t win_streak;
  char target_word[WORD_LEN+1];
  char guesses[WORD_LEN][MAX_GUESSES];
  bool _won;

public:
  GameState(const char *target);
  int guess(const char *guess, ResultValue *results);
  void set_metadata(const char *ip, uint32_t win_streak);
  std::string to_string();
  bool won();
  int num_guesses();
  void winning_word(char *dest);
};

class GameRecord {
  char *name;
  uint32_t id;
  size_t name_max_len;
  char last_word[WORD_LEN+1];
  uint32_t guesses;
  uint32_t win_streak;
  time_t game_finished;

public:
  GameRecord(const char *name, const char *last_word, uint32_t guesses, uint32_t win_streak);
  int set_name(const char *name);
  void set_id(uint32_t id);
  std::string get_name() const;
  uint32_t get_id() const;
  uint32_t get_guesses() const;
  time_t get_game_finished() const;
  std::string get_target_word() const;
};
