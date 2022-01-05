FROM centos:7

ARG HOME=/root
# check https://repo.anaconda.com/miniconda/ for miniconda version
ARG VERSION="py39_4.10.3"

WORKDIR $HOME

ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"

RUN yum install gcc openssl-devel bzip2-devel libffi-devel openldap-devel readline-devel make wget git -y && \
  yum clean all && \
  wget https://repo.anaconda.com/miniconda/Miniconda3-${VERSION}-Linux-x86_64.sh && \
  sh Miniconda3-${VERSION}-Linux-x86_64.sh -b && \
  rm -f Miniconda3-${VERSION}-Linux-x86_64.sh && \
  pip3 install --no-cache-dir --upgrade pip

RUN cd $HOME && \
  git clone https://github.com/hysds/prov_es.git && \
  git clone https://github.com/hysds/osaka.git && \
  git clone https://github.com/hysds/hysds_commons.git && \
  git clone https://github.com/hysds/hysds.git && \
  pip3 install --no-cache-dir -e prov_es/ && \
  pip3 install --no-cache-dir -e osaka/ && \
  pip3 install --no-cache-dir -e hysds_commons/ && \
  pip3 install --no-cache-dir -e hysds/ && \
  yum clean all && \
  rm -r /var/cache/*

WORKDIR $HOME
CMD ["/bin/bash"]
