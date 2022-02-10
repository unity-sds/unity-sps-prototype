FROM hysds/pge-base:develop

# provision
USER ops
COPY . /home/ops/verdi/ops/hello_world_pge

# set entrypoint
#ENTRYPOINT ["/entrypoint-pge-with-stats.sh"]

WORKDIR /home/ops
CMD ["/bin/bash", "--login"]
