FROM apache/airflow

# add editor
USER root
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
         vim \
  && apt-get autoremove -yqq --purge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
USER airflow

# add Python libraries
COPY ./requirements.txt .
RUN pip install -r requirements.txt 

# add DAGs
COPY ./dags /opt/airflow/dags
