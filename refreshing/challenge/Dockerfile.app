FROM php:7.2-apache

COPY ./app/ /var/www/html/
COPY ./flag.txt /flag.txt
RUN chmod -R ugo+rX /var/www/html /flag.txt
RUN echo 'Listen 127.0.0.1:8123' > /etc/apache2/ports.conf
