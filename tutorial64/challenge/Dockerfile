FROM gcr.io/bsides-sf-ctf-2022/base:latest

WORKDIR /home/ctf

COPY tutorial ./tutorial
COPY flag.txt ./flag.txt

RUN /home/ctf/fixperms.sh

EXPOSE 6464

USER 2000

CMD ["socat", "TCP4-LISTEN:6464,nodelay,fork", "EXEC:/home/ctf/tutorial"]
