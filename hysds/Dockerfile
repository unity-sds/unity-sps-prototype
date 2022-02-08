FROM centos:7

RUN useradd -ms /bin/bash ops && \
  yum install gcc openssl-devel bzip2-devel libffi-devel openldap-devel readline-devel make wget git -y && \
  yum clean all

USER ops
WORKDIR /home/ops

# check https://repo.anaconda.com/miniconda/ for miniconda version
ARG VERSION="py39_4.10.3"
ENV PATH="/home/ops/miniconda3/bin:${PATH}"
ARG PATH="/home/ops/miniconda3/bin:${PATH}"

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-${VERSION}-Linux-x86_64.sh && \
  sh Miniconda3-${VERSION}-Linux-x86_64.sh -b && \
  rm -f Miniconda3-${VERSION}-Linux-x86_64.sh && \
  pip3 install --no-cache-dir --upgrade pip && \
  pip3 install --no-cache-dir supervisor && \
  pip3 cache purge

RUN git clone https://github.com/hysds/prov_es.git && \
  git clone -b unity_demo https://github.com/hysds/osaka.git && \
  git clone https://github.com/hysds/hysds_commons.git && \
  git clone https://github.com/hysds/hysds.git && \
  pip3 install --no-cache-dir -e prov_es/ && \
  pip3 install --no-cache-dir -e osaka/ && \
  pip3 install --no-cache-dir -e hysds_commons/ && \
  pip3 install --no-cache-dir -e hysds/ && \
  pip3 cache purge

CMD ["/bin/bash"]
