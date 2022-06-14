FROM gcr.io/bsides-sf-ctf-2022/base:latest

COPY pwncap /home/ctf/pwncap
COPY flag.txt /home/ctf/flag.txt

RUN chown root:ctf /home/ctf/pwncap /home/ctf/flag.txt && \
  chmod 550 /home/ctf/pwncap && \
  chmod 440 /home/ctf/flag.txt

USER 2000

EXPOSE 5555/tcp

CMD ["/usr/bin/socat", "TCP4-LISTEN:5555,reuseaddr,fork", "EXEC:/home/ctf/pwncap"]
