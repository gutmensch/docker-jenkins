ARG JENKINS_VERSION=2.324

FROM jenkins/jenkins:$JENKINS_VERSION

ARG JENKINS_UID=1010
ARG JENKINS_GID=120
ARG COMPOSE_VERSION=2.2.2

USER root

RUN apt-get -y update && \
  apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common && \
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/docker.gpg --import - && \
  chown _apt: /etc/apt/trusted.gpg.d/docker.gpg && \
  add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable" && \
  apt-get update && \
  apt-get -y install docker-ce docker-ce-cli containerd.io && \
  curl -sL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
  chmod +x /usr/local/bin/docker-compose && \
  ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose && \
  usermod -u $JENKINS_UID jenkins && \
  groupmod -g $JENKINS_GID docker && \
  usermod -aG docker jenkins && \
  chown -h -R $JENKINS_UID /var/jenkins_home && \
  rm -rvf /var/lib/apt/lists/*

USER jenkins
