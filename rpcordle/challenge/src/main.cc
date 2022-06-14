#define _POSIX_C_SOURCE 201112L
#include "game.h"
#include "common.h"
#include <cstring>
#include <ctype.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <netdb.h>
#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <fcntl.h>


#define CHILD_PROCESS_LIFETIME 300


void RunServer(GameManager *manager, std::string address);
void RunServerForFD(GameManager *manager, int fd);
int debug_main(GameManager *manager, char *address);
int fork_main(GameManager *manager, char *address);
int fork_exec_main(GameManager *manager, char *address, char *fd);
int numeric(char *);
int bind_socket(char *address);
int accept_log(int sockfd);
void sigchld_handler(int signum);


int main(int argc, char **argv) {
  DEBUG("sizeof(GameState) = %lu", sizeof(GameState));
  DEBUG("sizeof(GameRecord) = %lu", sizeof(GameRecord));

  char default_addr[] = "127.0.0.1:5555";
  char default_wordlist[] = "./wordlist.txt";
  char *wordlist = default_wordlist;
  char *addr = default_addr;
  char *fd = NULL;

  for (int i=1;i<argc;i++) {
    if (numeric(argv[i])) {
      fd = argv[i];
    } else if (strchr(argv[i], ':') != NULL) {
      // Assume address
      addr = argv[i];
    } else {
      // Assume wordlist
      wordlist = argv[i];
    }
  }

  signal(SIGCHLD, sigchld_handler);

  GameManager *manager = new GameManager(wordlist);
#ifdef NOFORK
  return debug_main(manager, addr);
#else
#ifdef NOEXEC
  return fork_main(manager, addr);
#else
  return fork_exec_main(manager, addr, fd);
#endif
#endif
}

int debug_main(GameManager *manager, char *address) {
    RunServer(manager, address);
    return 0;
}

int fork_main(GameManager *manager, char *address) {
    int sock = bind_socket(address);
    while (1) {
        int child = accept_log(sock);
        if (child == -1) {
            return 1;
        }
        pid_t pid = fork();
        if (pid == -1) {
            DEBUG("Fork error: %s", strerror(errno));
            return 1;
        }
        if (pid == 0) {
            /* Child */
            close(sock);
            alarm(CHILD_PROCESS_LIFETIME);
            RunServerForFD(manager, child);
            // need some way to reap process here
            return 0;
        } else {
            /* Parent */
            close(child);
            DEBUG("Started child %d", pid);
        }
    }
    return 0;
}

int fork_exec_main(GameManager *manager, char *address, char *fdstr) {
    if (fdstr != NULL) {
        // This child has been execve'd
        int child = atoi(fdstr);
        if (fcntl(child, F_GETFD) == -1) {
            DEBUG("Got child %d, but F_GETFD failed: %s", child, strerror(errno));
            return 1;
        }
        RunServerForFD(manager, child);
        // need some way to reap process here
        return 0;
    }

    int sock = bind_socket(address);
    int exefd = open("/proc/self/exe", O_RDONLY | O_CLOEXEC);
    if (exefd < 0) {
        DEBUG("Error opening /proc/self/exe: %s", strerror(errno));
        return 1;
    }
    while (1) {
        int child = accept_log(sock);
        if (child == -1) {
            return 1;
        }
        pid_t pid = fork();
        if (pid == -1) {
            DEBUG("Fork error: %s", strerror(errno));
            return 1;
        }
        if (pid == 0) {
            /* Child */
            close(sock);
            alarm(CHILD_PROCESS_LIFETIME);
            //execve
            char pid_buf[20];
            snprintf(pid_buf, sizeof(pid_buf), "%d", child);
            char * const argv[] = {
                (char *)"rpcordle",
                (char *)manager->get_dictionary_path(),
                pid_buf,
                NULL,
            };
            fexecve(exefd, argv, environ);
            DEBUG("fexecve failed: %s", strerror(errno));
            return 1;
        } else {
            /* Parent */
            close(child);
            DEBUG("Started child %d", pid);
        }
    }

    return 0;
}

int bind_socket(char *address) {
    struct addrinfo *ai;
    char *colon = std::strchr(address, ':');
    char *host = address;
    char *port = NULL;
    if (!colon) {
        port = address;
        host = NULL;
    } else {
        port = colon+1;
        *colon = '\0';
    }
    struct addrinfo hints;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = AI_PASSIVE;

    int rv = getaddrinfo(host, port, &hints, &ai);
    if (rv != 0) {
        DEBUG("Error in getaddrinfo: %s", gai_strerror(rv));
        return -1;
    }

    int sock = socket(AF_INET, SOCK_STREAM|SOCK_CLOEXEC, 0);
    if (sock == -1) {
        DEBUG("Error in socket: %s", strerror(errno));
        freeaddrinfo(ai);
        return -1;
    }

    int enable = 1;
    setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &enable, sizeof(int));

    rv = bind(sock, ai->ai_addr, ai->ai_addrlen);
    if (rv) {
        DEBUG("Error in bind: %s", strerror(errno));
        freeaddrinfo(ai);
        close(sock);
        return -1;
    }

    rv = listen(sock, 32);
    if (rv) {
        DEBUG("Error in listen: %s", strerror(errno));
        freeaddrinfo(ai);
        close(sock);
        return -1;
    }

    freeaddrinfo(ai);
    return sock;
}

int accept_log(int sockfd) {
    struct sockaddr sa;
    socklen_t len = sizeof(sa);
    int sock = accept(sockfd, &sa, &len);
    if (sock == -1) {
        DEBUG("Error in accept: %s", strerror(errno));
    }
    char buf[64];
    char portbuf[6];
    int rv;
    if ((rv = getnameinfo(
                    &sa, len, buf, sizeof(buf), portbuf, sizeof(portbuf),
                    NI_NUMERICHOST|NI_NUMERICSERV)) != 0) {
        DEBUG("Error getnameinfo: %s", gai_strerror(rv));
    } else {
        DEBUG("Incoming connection from %s:%s", buf, portbuf);
    }
    return sock;
}

int numeric(char *str) {
    for (char *p=str;*p;p++) {
        if (!isdigit(*p))
            return 0;
    }
    return 1;
}

void sigchld_handler(int signum) {
    while (1) {
        int status;
        pid_t pid = waitpid(-1, &status, WNOHANG);
        if (pid <= 0)
            return;
        DEBUG("Child %d exited with status %d", pid, status);
    }
}
