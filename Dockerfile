# docker build -t fgribreau/docker-gcloud-base:{gcloud --version}-{kubectl version}-{docker --version}-{node --version} -f Dockerfile .
# docker push fgribreau/docker-gcloud-base:{gcloud --version}-{kubectl version}-{docker --version}
# docker push fgribreau/docker-gcloud-base:228.0.0-{kubectl version}-{docker --version}

# https://hub.docker.com/r/lakoo/node-alpine-gcloud/dockerfile
FROM node:12-alpine
MAINTAINER William Chong <williamchong@lakoo.com>

RUN mkdir -p /opt
WORKDIR /opt

RUN apk add --no-cache \
	bash \
	ca-certificates \
	git \
	openssh-client \
	python \
	tar \
	gzip

ENV CLOUDSDK_PYTHON_SITEPACKAGES 1
ENV GCLOUD_VERSION 287.0.0
RUN wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz && tar -xvf google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz && rm google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz
RUN google-cloud-sdk/install.sh --path-update=true --bash-completion=true --rc-path=/root/.bashrc --additional-components alpha beta app kubectl

RUN sed -i -- 's/\"disable_updater\": false/\"disable_updater\": true/g' /opt/google-cloud-sdk/lib/googlecloudsdk/core/config.json

RUN mkdir ${HOME}/.ssh
ENV PATH /opt/google-cloud-sdk/bin:$PATH

WORKDIR /root

# https://hub.docker.com/r/lakoo/node-gcloud-docker
FROM lakoo/node-alpine-gcloud:latest
MAINTAINER William Chong <williamchong@lakoo.com>

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 17.03.0-ce
ENV DOCKER_SHA256 4a9766d99c6818b2d54dc302db3c9f7b352ad0a80a2dc179ec164a3ba29c2d3e

COPY --from=0 /opt/google-cloud-sdk /opt/google-cloud-sdk

RUN apk add --no-cache curl openssl make build-base gcc gettext rsync \
	&& set -x \
	&& curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz" -o docker.tgz \
	&& echo "${DOCKER_SHA256} *docker.tgz" | sha256sum -c - \
	&& tar -xzvf docker.tgz \
	&& mv docker/* /usr/local/bin/ \
	&& rmdir docker \
	&& rm docker.tgz \
	&& docker -v \
	&& apk del openssl

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
