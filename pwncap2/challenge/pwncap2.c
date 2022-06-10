#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <arpa/inet.h>
#include <sys/ptrace.h>
#include <unistd.h>

#define SUCCESS 0
#define FAIL 1

typedef void(*hdlr)(uint32_t *);

void add_num(uint32_t *);
void get_num(uint32_t *);
void sum_num(uint32_t *);
void get_cap(uint32_t *);
void do_exit(uint32_t *);
void do_flag(uint32_t *);
void toggle_debug(uint32_t *);
void main_once(uint32_t *);
void show_menu();
hdlr handler_for_command(const char *cmd);
hdlr check_valid_handler(hdlr);
uint32_t read_uint32_or_die(char *prompt);
int read_uint32(char *prompt, uint32_t*);
int read_trimmed_line(char *, size_t);
int check_cap(uint32_t *, int);

struct command_meta {
  const char * name;
  const char * description;
  hdlr handler;
  int hidden;
  struct command_meta *next;
};

static const hdlr hdlr_allowlist[] = {
  add_num,
  get_num,
  sum_num,
  get_cap,
  do_exit,
  do_exit,
  do_flag,
  toggle_debug,
  NULL,
};

static const char add_num_name[] = "add";
static const char add_num_desc[] = "Add number to array";
static const char get_num_name[] = "get";
static const char get_num_desc[] = "Get number from array";
static const char sum_num_name[] = "sum";
static const char sum_num_desc[] = "Get sum of numbers";
static const char cap_name[] = "cap";
static const char cap_desc[] = "Get capacity";
static const char exit_name[] = "exit";
static const char quit_name[] = "quit";
static const char exit_desc[] = "Exit program";
static const char flag_name[] = "do_flag_1";
static const char flag_desc[] = "[Hidden] get flag";
static const char debug_name[] = "@@ELF32";

static struct command_meta *command_table = NULL;

union {
  uint32_t all;
  struct {
    char pad;
    char traced;
    char preloaded;
    char debug_me;
  } which;
} rip = {0};

static void __attribute__((constructor)) build_command_table() {
  static struct command_meta tbl[sizeof(hdlr_allowlist)/sizeof(hdlr_allowlist[0])];
  memset(tbl, 0, sizeof(tbl));
  tbl[0].name = add_num_name;
  tbl[0].description = add_num_desc;
  tbl[0].handler = add_num;
  tbl[1].name = get_num_name;
  tbl[1].description = get_num_desc;
  tbl[1].handler = get_num;
  tbl[2].name = sum_num_name;
  tbl[2].description = sum_num_desc;
  tbl[2].handler = sum_num;
  tbl[3].name = cap_name;
  tbl[3].description = cap_desc;
  tbl[3].handler = get_cap;
  tbl[4].name = exit_name;
  tbl[4].description = exit_desc;
  tbl[4].handler = do_exit;
  tbl[5].name = flag_name;
  tbl[5].description = flag_desc;
  tbl[5].handler = do_flag;
  tbl[5].hidden = 1;
  tbl[6].name = debug_name;
  tbl[6].description = "";
  tbl[6].hidden = 1;
  tbl[6].handler = toggle_debug;
  tbl[7].name = quit_name;
  tbl[7].description = exit_desc;
  tbl[7].hidden = 1;
  tbl[7].handler = do_exit;
  tbl[0].next = &tbl[1];
  tbl[1].next = &tbl[2];
  tbl[2].next = &tbl[3];
  tbl[3].next = &tbl[4];
  tbl[4].next = &tbl[5];
  tbl[5].next = &tbl[6];
  tbl[6].next = &tbl[7];
  tbl[7].next = NULL;
  command_table = tbl;
}

static void __attribute__((constructor)) check_preload() {
  rip.which.preloaded = getenv("LD_PRELOAD") ? 1 : 0;
}

static void __attribute__((constructor)) check_ptrace() {
  if (ptrace(PTRACE_TRACEME, 0, NULL, 0) == -1) {
    rip.which.traced = 1;
  }
}

#define INTBUF_SIZE 256

int main(int argc, char **argv) {
  uint32_t storage[INTBUF_SIZE];
  memset(storage, 0, sizeof(storage));
  storage[0] = INTBUF_SIZE;
  if (rip.all) {
    return 1;
  }
  while (1) {
    main_once(storage);
  }
  return 0;
}

void add_num(uint32_t *storage) {
  uint32_t pos = read_uint32_or_die((char *)"index> ");
  uint32_t real_pos = pos + 1; // Account for size at beginning of array
  if (check_cap(storage, real_pos) == FAIL) {
    printf("Invalid offset!\n");
    fflush(stdout);
    return;
  }
  uint32_t val = read_uint32_or_die((char *)"value> ");
  storage[real_pos] = htonl(val);
}

void get_num(uint32_t *storage) {
  uint32_t pos = read_uint32_or_die((char *)"index> ");
  uint32_t real_pos = pos + 1; // Account for size at beginning of array
  if (check_cap(storage, real_pos) == FAIL) {
    printf("Invalid offset!\n");
    fflush(stdout);
    return;
  }
  const char *fmt_debug = rip.which.debug_me ? "%1$03d: [%3$p] %2$lu (%2$x)" : "%03d: %lu";
  printf(fmt_debug, pos, ntohl(storage[real_pos]), &storage[real_pos]);
  printf("\n");
  fflush(stdout);
}

void sum_num(uint32_t *storage) {
  uint32_t tot = 0;
  for(int i=1; i<*storage; i++) {
    tot += ntohl(storage[i]);
  }
  printf("total: %ud\n", tot);
}

void get_cap(uint32_t *storage) {
  printf("capacity: %u\n", *storage);
}

void do_exit(uint32_t *unused) {
  exit(0);
}

void do_flag(uint32_t *unused) {
  static const char path[] = "/home/ctf/flag.txt";
  const char key[] = {
    0x47, 0x1c, 0x1b, 0x1d, 0x16, 0x15, 0x4c, 0x5b, 0x03, 0x41, 0x48, 0x1b,
    0x08, 0x0c, 0x47, 0x04, 0x1d, 0x10, 0x46, 0x09, 0x41, 0x02, 0x17, 0x48,
    0x4c, 0x03, 0x0f, 0x44, 0x0f, 0x43, 0x33, 0x02, 0x4a, 0x2b, 0x10, 0x11,
    0x5d, 0x1a, 0x06, 0x03, 0x02, 0x2f
  };
  int path_len = strlen(path);
  int i=0;
  while(1) {
    char c = key[i] ^ path[i % path_len];
    if (!c)
      return;
    printf("%c", c);
    i++;
    usleep(i*128*1024);
  }
}

void toggle_debug(uint32_t *unused) {
  rip.which.debug_me ^= 1;
}

void main_once(uint32_t *storage) {
  char choice[256];
  show_menu();
  printf("> ");
  fflush(stdout);
  if (read_trimmed_line(choice, sizeof(choice)) == FAIL)
    exit(0);
  hdlr h = handler_for_command(choice);
  if (!h)
    return;
  h = check_valid_handler(h);
  if (!h)
    return;
  h(storage);
  puts("");
  fflush(stdout);
}

void show_menu() {
  struct command_meta *head = command_table;
  puts("Menu");
  while(head) {
    if (!head->hidden) {
      printf("%12s: %s", head->name, head->description);
      if (rip.which.debug_me) {
        printf(" %p", head->handler);
      }
      printf("\n");
    }
    head = head->next;
  }
}

hdlr handler_for_command(const char *cmd) {
  struct command_meta *head = command_table;
  while(head) {
    if (!strcasecmp(cmd, head->name)) {
      return head->handler;
    }
    head = head->next;
  }
  return NULL;
}

hdlr check_valid_handler(hdlr tgt) {
  for (int i=0; i<sizeof(hdlr_allowlist)/sizeof(hdlr_allowlist[0]); i++) {
    if (hdlr_allowlist[i] == tgt) {
      return tgt;
    }
  }
  return NULL;
}

uint32_t read_uint32_or_die(char *prompt) {
  uint32_t rv;
  if (read_uint32(prompt, &rv) == FAIL) {
    exit(1);
  }
  return rv;
}

int read_uint32(char *prompt, uint32_t *dest) {
  char buf[256];
  if (dest == NULL)
    return FAIL;
  if (prompt != NULL) {
    printf("%s", prompt);
    fflush(stdout);
  }
  if (read_trimmed_line(buf, sizeof(buf)) == FAIL)
    return FAIL;
  if (*buf == '\0')
    return FAIL;
  if (*buf == '-') {
    printf("unsigned values only\n");
    return FAIL;
  }
  char *end;
  unsigned long rv = strtoul(buf, &end, 0);
  if (*end != '\0') // did not consume entire line
    return FAIL;
  *dest = rv;
  return SUCCESS;
}

int read_trimmed_line(char *buf, size_t cap) {
  if (fgets(buf, cap, stdin) == NULL) {
    return FAIL;
  }
  buf[strcspn(buf, "\n")] = '\0';
  return SUCCESS;
}

int check_cap(uint32_t *arr, int v) {
  if (v > (int)*arr)
    return FAIL;
  return SUCCESS;
}
