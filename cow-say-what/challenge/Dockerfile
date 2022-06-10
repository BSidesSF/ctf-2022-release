FROM gcr.io/bsides-sf-ctf-2022/base:latest

RUN apt-get install -yy cowsay cowsay-off

COPY --chown=root:ctf cowsay /home/ctf/cowsay
COPY --chown=root:ctf cowsay.go /home/ctf/cowsay.go
COPY --chown=root:ctf flag.txt /home/ctf/flag.txt

WORKDIR /home/ctf
USER 2000

CMD ["/home/ctf/cowsay"]
