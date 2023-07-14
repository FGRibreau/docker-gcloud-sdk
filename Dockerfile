# docker build .
# echo "docker tag xx fgribreau/docker-gcloud-base:$(gcloud --version | head -n 1 | tr ' ' '-')-$(kubectl version -o=json | jq -r '.clientVersion.gitVersion')-$(docker --version | tr ' ' '-' | tr ',' '-')-node-$(node --version)"
# docker push fgribreau/docker-gcloud-base:{gcloud --version}-{kubectl version}-{docker --version}
# docker push fgribreau/docker-gcloud-base:228.0.0-{kubectl version}-{docker --version}



# docker build -t fgribreau/docker-gcloud-base:Google-Cloud-SDK-438.0.0-Docker-version-18.09.1--build-node-v16.20.1 -f Dockerfile .

# https://hub.docker.com/r/lakoo/node-alpine-gcloud/dockerfile
FROM node:16.20.1-buster
MAINTAINER William Chong <williamchong@lakoo.com>

RUN mkdir -p /opt
WORKDIR /opt

RUN apt-get update && apt-get install -y \
	bash \
	ca-certificates \
	git \
	openssh-client \
	python \
	tar \
	gzip


ENV CLOUDSDK_PYTHON_SITEPACKAGES 1
ENV GCLOUD_VERSION 438.0.0
RUN wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz && tar -xvf google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz && rm google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz
RUN google-cloud-sdk/install.sh --path-update=true --bash-completion=true --rc-path=/root/.bashrc --additional-components alpha beta app kubectl

RUN sed -i -- 's/\"disable_updater\": false/\"disable_updater\": true/g' /opt/google-cloud-sdk/lib/googlecloudsdk/core/config.json

RUN mkdir ${HOME}/.ssh
ENV PATH /opt/google-cloud-sdk/bin:$PATH

WORKDIR /root

RUN apt-get update && apt-get install -y docker.io=18.09.1+dfsg1-7.1+deb10u3 curl openssl make jq gcc gettext rsync build-essential libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev \
	&& docker -v

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
