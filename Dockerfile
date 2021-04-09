ARG PYTHON_VERSION=3.8
FROM python:${PYTHON_VERSION}-alpine

ARG VERSION=latest

ARG USER_ID=45000
ARG GROUP_ID=45000

ENV PYTHONUNBUFFERED=1
ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1

COPY files/requirements.txt /requirements.txt
COPY files/run.sh /run.sh
COPY files/run.yml /run.yml

RUN apk add --no-cache \
      dumb-init \
      libstdc++ \
      py3-setuptools \
    && apk add --no-cache --virtual .build-deps \
      build-base \
      libffi-dev \
      openssl-dev \
      python3-dev \
    && pip3 --no-cache-dir install -r /requirements.txt \
    && pip3 --no-cache-dir install awxkit==$VERSION \
    && ansible-galaxy collection install -p /usr/share/ansible/collections awx.awx:==$VERSION \
    && rm -rf /requirements.txt /requirements.yml \
    && apk del .build-deps \
    && addgroup -g $GROUP_ID dragon \
    && adduser -D -u $USER_ID -G dragon dragon

USER dragon

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["awx"]

LABEL "org.opencontainers.image.documentation"="https://docs.osism.de" \
      "org.opencontainers.image.licenses"="ASL 2.0" \
      "org.opencontainers.image.source"="https://github.com/osism/docker-image-awxclient" \
      "org.opencontainers.image.url"="https://www.osism.de" \
      "org.opencontainers.image.vendor"="Betacloud Solutions GmbH"
