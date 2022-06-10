FROM gcr.io/bsides-sf-ctf-2022/base:latest

RUN dpkg --add-architecture i386 && apt update && \
  apt install -y libc6:i386

WORKDIR /home/ctf

COPY tutorial ./tutorial
COPY flag.txt ./flag.txt

RUN /home/ctf/fixperms.sh

EXPOSE 3232

USER 2000

CMD ["socat", "TCP4-LISTEN:3232,nodelay,fork", "EXEC:/home/ctf/tutorial"]
