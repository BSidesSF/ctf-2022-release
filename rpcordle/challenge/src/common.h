#include <cstdio>
#include <unistd.h>

#ifdef DEBUG_BUILD
#define DEBUG(fmt, ...) std::fprintf(stderr, "[%d] " fmt "\n", getpid(), ## __VA_ARGS__)
#else
#define DEBUG(...)
#endif
