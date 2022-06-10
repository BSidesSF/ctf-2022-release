FROM gcr.io/bsides-sf-ctf-2022/base:latest

COPY src/sequels /home/ctf/sequels
COPY templates /home/ctf/templates

RUN /home/ctf/fixperms.sh

WORKDIR /home/ctf
USER 2000

CMD ["./sequels"]
