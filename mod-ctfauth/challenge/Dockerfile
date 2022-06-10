FROM httpd:2.4.53

COPY httpd.conf /usr/local/apache2/conf/httpd.conf
COPY ctfauth.so /usr/local/apache2/modules/ctfauth.so
COPY index.html /usr/local/apache2/htdocs/index.html
RUN mkdir /usr/local/apache2/htdocs/secret/
COPY secret.html /usr/local/apache2/htdocs/secret/secret.html

RUN mkdir /app
WORKDIR /app
