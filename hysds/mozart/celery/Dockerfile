FROM python:3.8-slim

WORKDIR /root
COPY . /root/tasks

RUN apt-get update -y && \
  apt-get install supervisor -y && \
  apt-get clean  && \
  pip install celery redis msgpack

COPY tasks /root/tasks
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8089

CMD ["/usr/bin/supervisord", "--nodaemon"]
