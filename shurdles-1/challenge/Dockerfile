FROM ruby:2.6

RUN apt-get update
RUN apt-get install -y net-tools ruby-bundler socat

ENV APP_HOME /app

COPY src/ $APP_HOME
RUN chmod +x $APP_HOME/app.rb $APP_HOME/mandrake $APP_HOME/harness
WORKDIR $APP_HOME
RUN bundle install

RUN adduser --uid 2000 --disabled-password --gecos '' ctf
USER 2000
EXPOSE 1337/tcp

CMD ["/usr/bin/socat", "TCP4-LISTEN:1337,reuseaddr,fork", "EXEC:/app/app.rb"]
