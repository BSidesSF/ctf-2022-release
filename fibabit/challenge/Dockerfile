FROM gcr.io/bsides-sf-ctf-2022/base:latest

ADD ./fibabit /home/ctf/fibabit
ADD ./flag.txt /home/ctf/flag.txt

RUN /home/ctf/fixperms.sh

USER 2000

EXPOSE 5555/tcp

CMD ["/usr/bin/socat", "TCP4-LISTEN:5555,reuseaddr,fork", "EXEC:/home/ctf/fibabit"]
