FROM golang:1.18-buster as builder

WORKDIR /usr/src/app
COPY src .

RUN cd quirc/quirc && make libquirc.a
RUN go build -v -o /usr/src/app/sequels .

FROM gcr.io/bsides-sf-ctf-2022/base:latest

COPY --from=builder /usr/src/app/sequels /home/ctf/sequels
COPY templates /home/ctf/templates

RUN /home/ctf/fixperms.sh

WORKDIR /home/ctf
USER 2000

CMD ["./sequels"]
