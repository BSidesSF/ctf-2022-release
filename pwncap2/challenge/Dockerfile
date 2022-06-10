FROM gcr.io/bsides-sf-ctf-2022/base:latest

COPY pwncap2 /home/ctf/pwncap2
COPY flag.txt /home/ctf/flag.txt

RUN chown root:ctf /home/ctf/pwncap2 /home/ctf/flag.txt && \
  chmod 550 /home/ctf/pwncap2 && \
  chmod 440 /home/ctf/flag.txt

USER 2000

WORKDIR /home/ctf

EXPOSE 5555/tcp

CMD ["/usr/bin/socat", "TCP4-LISTEN:5555,reuseaddr,fork", "EXEC:/home/ctf/pwncap2"]
