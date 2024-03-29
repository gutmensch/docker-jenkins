ARG JENKINS_VERSION=2.363

FROM jenkins/jenkins:$JENKINS_VERSION

ARG IMAGE_UID=2010
ARG IMAGE_GID=2010
# corresponds with ubuntu host installation
ARG DOCKER_GID=120
ARG COMPOSE_VERSION=2.2.3

USER root

RUN apt-get -y update && \
  apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common && \
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/docker.gpg --import - && \
  chown _apt: /etc/apt/trusted.gpg.d/docker.gpg && \
  add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable" && \
  apt-get update && \
  apt-get -y install docker-ce-cli && \
  curl -sL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
  chmod +x /usr/local/bin/docker-compose && \
  ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose && \
  usermod -u $IMAGE_UID jenkins && \
  groupmod -g $IMAGE_GID jenkins && \
  groupadd -g $DOCKER_GID docker && \
  usermod -aG docker jenkins && \
  chown -h -R $IMAGE_UID:$IMAGE_GID /var/jenkins_home && \
  rm -rvf /var/lib/apt/lists/*

USER $IMAGE_UID
