#include "game.h"
#include "common.h"
#include <string>
#include <string.h>
#include <arpa/inet.h>
#include <cstdio>
#include <errno.h>
#include <unistd.h>

char wordlist_path[256];

/** GameManager **/

GameManager::GameManager(const char *dictionary_path)
  : rng((uint64_t)this) {
  strncpy(this->dictionary_path, dictionary_path, sizeof(this->dictionary_path));
  memset(this->games, 0, sizeof(this->games));
  std::vector<std::string> words = this->read_wordlist();
  this->words.insert(this->words.begin(), words.begin(), words.end());
  DEBUG("GameManager constructed at %p", this);
  DEBUG("offsetof(dictionary_path) is %lu", (char *)&this->dictionary_path - (char *)this);
}

int GameManager::start_game() {
  for (int i=0; i<MAX_SIMULTANEOUS_GAMES; i++) {
    if (this->games[i] == NULL) {
      std::uniform_int_distribution<uint64_t> rnglimits(0, this->words.size()-1);
      for(int p=0;p<getpid();p++) this->rng();
      uint64_t choice = rnglimits(this->rng);
      const char *word_choice = this->words[choice].c_str();
      this->games[i] = new GameState(word_choice);
      DEBUG("New GameState at %p: %s", this->games[i], word_choice);
      return i;
    }
  }
  DEBUG("GameManager full, could not construct!");
  return -1;
}

GameState *GameManager::get_game(int gameid) {
  if (gameid < 0 || gameid >= MAX_SIMULTANEOUS_GAMES) {
    DEBUG("Attempt to get game out of range!");
    return NULL;
  }
  return this->games[gameid];
}

int GameManager::end_game(int gameid) {
  if (gameid < 0 || gameid >= MAX_SIMULTANEOUS_GAMES) {
    DEBUG("Attempt to end game out of range!");
    return -1;
  }
  bool won = this->games[gameid]->won();
  int guesses = this->games[gameid]->num_guesses();
  std::string default_name = this->games[gameid]->to_string();
  char winning_word[WORD_LEN];
  this->games[gameid]->winning_word(winning_word);
  DEBUG("Deleting game %d at %p", gameid, this->games[gameid]);
  delete this->games[gameid];
  if (won) {
    GameRecord *record = new GameRecord(
        default_name.c_str(),
        winning_word,
        (uint32_t)guesses,
        (uint32_t)1);
    DEBUG("Created GameRecord %p", record);
    this->records.push_back(record);
    int rv = this->records.size() - 1;
    record->set_id(rv);
    return rv;
  }
  this->games[gameid] = NULL;
  return -1;
}

std::vector<std::string> GameManager::read_wordlist() {
  std::vector<std::string> res;
  FILE *fp = std::fopen(this->dictionary_path, "r");
  if (!fp) {
    DEBUG("Error opening file: %s", strerror(errno));
    return res;
  }
  char buf[256];
  while (!std::feof(fp)) {
    if(!std::fgets(buf, sizeof(buf), fp))
      break;
    buf[strcspn(buf, "\r\n")] = '\0';
    res.push_back(std::string(buf));
  }
  std::fclose(fp);
  return res;
}

GameRecord *GameManager::get_game_record(int game_record_id) {
  if (game_record_id < 0 || (size_t)game_record_id >= this->records.size()) {
    DEBUG("Game record id out of range: %d", game_record_id);
    return NULL;
  }
  return this->records[game_record_id];
}

const char *GameManager::get_dictionary_path() {
    return this->dictionary_path;
}

/** GameState **/

GameState::GameState(const char *target)
: remote_addr(0), win_streak(0), _won(false)
{
  memcpy(this->target_word, target, WORD_LEN);
  this->target_word[WORD_LEN] = '\0';
  memset(this->guesses, 0, sizeof(this->guesses));
  DEBUG("Constructed GameState at %p", this);
}

std::string GameState::to_string() {
  struct in_addr a;
  char buf[64], addr_buf[32];
  a.s_addr = this->remote_addr;
  inet_ntop(AF_INET, (const void *)&a, addr_buf, sizeof(addr_buf));
  std::string res("");
  snprintf(buf, sizeof(buf), "[%s] ", addr_buf);
  res += buf;
  snprintf(buf, sizeof(buf), "Target: %s ", this->target_word);
  res += buf;
  if (_won) {
    res += "WON ";
  }
  snprintf(buf, sizeof(buf), "%d guesses", this->num_guesses());
  res += buf;
  return res;
}

bool GameState::won() {
  return _won;
}

void GameState::winning_word(char *dest) {
  if (!dest) {
    DEBUG("Got null pointer in winning_word!");
    return;
  }
  memcpy(dest, this->target_word, sizeof(this->target_word));
}

int GameState::num_guesses() {
  for (int i=0; i<MAX_GUESSES; i++) {
    if (guesses[i][0] == '\0')
      return i;
  }
  return MAX_GUESSES;
}

// Returns 1 if this is a win, 0 if it's a non-winning guess, 2 if they're out
// of turns
int GameState::guess(const char *guess, ResultValue *results) {
  int turn = this->num_guesses();
  if (turn == MAX_GUESSES) {
    DEBUG("Out of turns!");
    return 2;
  }
  memcpy(this->guesses[turn], guess, WORD_LEN);
  if (memcmp(guess, this->target_word, WORD_LEN) == 0) {
    // Exact match!
    this->_won = true;
    return 1;
  }
  // Which target word positions have been used?
  bool matched[WORD_LEN];
  // First check for exact matches
  for (int i=0; i < WORD_LEN; i++) {
    matched[i] = false;
    results[i] = NO_MATCH;
    if (guess[i] == this->target_word[i]) {
      matched[i] = true;
      results[i] = MATCH_OK;
    }
  }
  // Now look for wrong-position matches
  for (int i=0; i < WORD_LEN; i++) {
    if (results[i] == MATCH_OK)
      continue;
    for (int k=0; k < WORD_LEN; k++) {
      if (matched[k])
        continue;
      if (guess[i] == this->target_word[k]) {
        matched[k] = true;
        results[i] = MATCH_BADPOS;
        break;
      }
    }
  }
  return 0;
}

void GameState::set_metadata(const char *ip, uint32_t win_streak) {
  DEBUG("Metadata pre: %p", (void *)*((uint64_t *)this));
  this->win_streak = win_streak;
  struct in_addr a;
  if (inet_pton(AF_INET, ip, &a) == 1) {
    this->remote_addr = a.s_addr;
  }
  DEBUG("Metadata updated: %s, %d, %p", ip, win_streak, (void *)*((uint64_t *)this));
}

/** GameRecord **/

GameRecord::GameRecord(const char *name, const char *last_word,
    uint32_t guesses, uint32_t win_streak)
  : guesses(guesses), win_streak(win_streak)
{
  this->name = strdup(name);
  this->name_max_len = strlen(name);
  memcpy(this->last_word, last_word, WORD_LEN);
  this->last_word[WORD_LEN] = '\0';
  DEBUG("Constructed GameRecord at %p, name at %p", this, this->name);
}

int GameRecord::set_name(const char *name) {
  DEBUG("Updating name at %p", this->name);
  if (strlen(name) >= this->name_max_len) {
    return 0;
  }
  strncpy(this->name, name, this->name_max_len);
  return strlen(this->name);
}

void GameRecord::set_id(uint32_t id) {
  this->id = id;
}

std::string GameRecord::get_name() const {
  return std::string(this->name);
}

uint32_t GameRecord::get_id() const {
  return this->id;
}

uint32_t GameRecord::get_guesses() const {
  return this->guesses;
}

time_t GameRecord::get_game_finished() const {
  return this->game_finished;
}

std::string GameRecord::get_target_word() const {
  return std::string(this->last_word);
}
