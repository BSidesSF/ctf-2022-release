FROM gcr.io/bsides-sf-ctf-2022/base:latest

RUN apt-get install -yy perl imagemagick

WORKDIR /home/ctf

COPY --chown=ctf:ctf . /home/ctf/

USER 2000

CMD ["/home/ctf/run.sh"]
