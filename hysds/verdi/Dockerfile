ARG PARENT_DOCKER_IMAGE=hysds-core:unity-v1.0.0
FROM $PARENT_DOCKER_IMAGE

USER root

ARG CONTAINERD=containerd.io-1.4.9-3.1.el7.x86_64.rpm
ARG DOCKERCLI=docker-ce-cli-18.09.0-3.el7.x86_64.rpm

RUN wget -O /tmp/${CONTAINERD} https://download.docker.com/linux/centos/7/x86_64/stable/Packages/${CONTAINERD} && \
  wget -O /tmp/${DOCKERCLI} https://download.docker.com/linux/centos/7/x86_64/stable/Packages/${DOCKERCLI} && \
  yum localinstall -y /tmp/${CONTAINERD} && \
  yum localinstall -y /tmp/${DOCKERCLI} && \
  yum clean all && \
  rm -rf /tmp/*

RUN pip install cwltool cwl-runner

USER ops
WORKDIR /home/ops

CMD ["/bin/bash"]
