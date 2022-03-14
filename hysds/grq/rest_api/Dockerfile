ARG PARENT_DOCKER_IMAGE=docker.io/library/hysds-core:unity-v0.0.1
FROM $PARENT_DOCKER_IMAGE


WORKDIR /home/ops

ENV WORKERS 4
ENV THREADS 1

# RUN pip3 install 'Flask<2.0.0' && \
#   pip3 install 'Werkzeug<2.0.0' && \
RUN pip3 install 'flask-cors' && \
  # Cartopy isn't used in GRQ2, --no-deps to minimize the size of image
  conda install -y --no-deps 'Cartopy>=0.13.1' && \
  conda clean --all

RUN git clone --branch optional_geonames https://github.com/hysds/grq2.git && \
  cd grq2/ && \
  pip3 install -e .

WORKDIR /home/ops/grq2

CMD ["sh", "-c", "gunicorn \
  --workers $WORKERS --threads $THREADS \
  -b 0.0.0.0:8878 -k gevent \
  --timeout=3600 --graceful-timeout=3600 --log-level=debug --limit-request-line=0 \
  grq2:app"]
