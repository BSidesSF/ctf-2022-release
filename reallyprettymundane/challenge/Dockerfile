# Tested exclusively on ruby-2.6.3, so far
FROM ruby:2.6.3

RUN apt-get update
RUN apt-get install -y net-tools ruby-bundler netcat-traditional wget curl rpm

# Configuration
ENV HOST 0.0.0.0
ENV PORT 8371
ENV APP_HOME /app
ENV HOME /root

# Install gems
COPY src/ $APP_HOME
COPY flag.txt /

WORKDIR $APP_HOME
RUN bundle install --system

RUN adduser --uid 2000 --disabled-password --gecos '' ctf
RUN chmod -R ugo+rX $APP_HOME
USER 2000

# Start server
CMD ["ruby", "./server.rb"]
