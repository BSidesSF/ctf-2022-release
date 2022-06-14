FROM gcr.io/bsides-sf-ctf-2022/base:latest

COPY rsalab /home/ctf
COPY banner.txt /home/ctf
COPY flag_easy.txt /home/ctf
COPY flag_med.txt /home/ctf
COPY flag_hard.txt /home/ctf
COPY sample_code.txt /home/ctf


RUN chmod -R ugo=rX /home/ctf
RUN chown -R root:ctf /home/ctf

EXPOSE 6537

WORKDIR /home/ctf
USER 2000

CMD ["/usr/bin/socat", "TCP4-LISTEN:6537,reuseaddr,fork", "EXEC:/home/ctf/rsalab,stderr"]
