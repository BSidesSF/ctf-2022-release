FROM gcr.io/bsides-sf-ctf-2022/base:latest

RUN dpkg --add-architecture i386 && apt-get update && \
  apt-get -yy install libc6:i386

COPY 0x41414141 /home/ctf/0x41414141
COPY flag.txt /home/ctf/flag.txt
RUN /home/ctf/fixperms.sh

WORKDIR /home/ctf
USER 2000

EXPOSE 5555/tcp

CMD ["socat", "TCP4-LISTEN:5555,nodelay,fork", "EXEC:/home/ctf/0x41414141"]
