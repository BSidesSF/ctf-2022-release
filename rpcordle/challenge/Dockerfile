FROM l.gcr.io/google/bazel:latest AS builder

COPY . /srcdir
WORKDIR /srcdir
RUN bazel build src:rpcordle
RUN bazel build src:rpcordle-dbg

FROM gcr.io/bsides-sf-ctf-2022/base:latest

COPY --from=builder /srcdir/bazel-bin/src/rpcordle /home/ctf/rpcordle
COPY --from=builder /srcdir/bazel-bin/src/rpcordle-dbg /home/ctf/rpcordle-dbg
COPY wordlist.txt /home/ctf/wordlist.txt
COPY flag.txt /home/ctf/flag.txt
RUN chmod 640 /home/ctf/*.txt
RUN chmod 750 /home/ctf/rpcordle*
RUN chown -R root:ctf /home/ctf

EXPOSE 5555/tcp

USER 2000

CMD ["/home/ctf/rpcordle", "/home/ctf/wordlist.txt", "0.0.0.0:5555"]
