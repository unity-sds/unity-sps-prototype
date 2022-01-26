FROM hysds-core:unity-ol8-v0.0.1

ARG CONTAINERD=containerd.io-1.4.9-3.1.el7.x86_64.rpm
ARG DOCKERCLI=docker-ce-cli-18.09.0-3.el7.x86_64.rpm

RUN wget -O /tmp/${CONTAINERD} https://download.docker.com/linux/centos/7/x86_64/stable/Packages/${CONTAINERD} && \
  wget -O /tmp/${DOCKERCLI} https://download.docker.com/linux/centos/7/x86_64/stable/Packages/${DOCKERCLI} && \
  yum localinstall -y /tmp/${CONTAINERD} && \
  yum localinstall -y /tmp/${DOCKERCLI} && \
  pip3 install --no-cache-dir supervisor && \
  yum clean all && \
  rm -rf /tmp/*

CMD ["/bin/bash"]
