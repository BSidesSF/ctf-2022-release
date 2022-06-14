FROM debian:testing

RUN apt-get -yy update && \
  apt-get -yy install \
    openjdk-11-jre-headless openjdk-11-jdk-headless \
    python3-pip netcat-traditional

RUN mkdir /poc

WORKDIR /poc

COPY poc.py /poc/poc.py
COPY requirements.txt /poc/requirements.txt
COPY log4j-shell-poc/target/marshalsec-0.0.3-SNAPSHOT-all.jar /poc/marshalsec-0.0.3-SNAPSHOT-all.jar

RUN pip install -r requirements.txt
COPY solve.py /poc/solve.py

EXPOSE 1389/tcp
EXPOSE 8000/tcp

CMD ["python3", "/poc/solve.py"]
