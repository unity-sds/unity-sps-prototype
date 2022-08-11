FROM hysds/pge-base:develop

USER root
RUN mkdir -p /tmp/data
RUN chown ops /tmp/data

# provision
USER ops
COPY . /home/ops/verdi/ops/hello_world_pge

# set entrypoint
#ENTRYPOINT ["/entrypoint-pge-with-stats.sh"]

WORKDIR /home/ops
CMD ["/bin/bash", "--login"]
