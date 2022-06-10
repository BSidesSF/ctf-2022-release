FROM gcr.io/bsides-sf-ctf-2022/base:latest

RUN apt-get install -yy python3-pip

WORKDIR /home/ctf

COPY requirements.txt /home/ctf
RUN umask 022 && pip install -r requirements.txt
RUN umask 022 && pip install gunicorn

COPY . /home/ctf
RUN /home/ctf/fixperms.sh

USER 2000

ENV PORT=3123
EXPOSE ${PORT}/tcp

CMD ["sh", "-c", "gunicorn --workers=8 --bind=0.0.0.0:${PORT} --access-logfile=- --error-logfile=- --capture-output addons:app"]
