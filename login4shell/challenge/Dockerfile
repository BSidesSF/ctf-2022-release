FROM gcr.io/bsides-sf-ctf-2022/base:latest

RUN apt-get -yy install openjdk-11-jre-headless

COPY --chown=root:ctf login4shell.jar /home/ctf/login4shell.jar
COPY --chown=root:ctf flag.txt /home/ctf/flag.txt
RUN chmod 440 /home/ctf/login4shell.jar

USER 2000

EXPOSE 8123/tcp

WORKDIR /home/ctf

CMD ["/usr/bin/java", \
  "-Dcom.sun.jndi.ldap.object.trustURLCodebase=true", \
  "-Dcom.sun.jndi.rmi.object.trustURLCodebase=true", \
  "-Dcom.sun.jndi.cosnaming.object.trustURLCodebase=true", \
  "-Djetty.httpConfig.relativeRedirectAllowed=true", \
  "-jar", \
  "/home/ctf/login4shell.jar", \
  "org.bsidessf.login4shell.ServerMain"]
