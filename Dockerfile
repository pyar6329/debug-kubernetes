FROM ubuntu:16.04

ENV MIX_ENV=dev PORT=4000 WORKDIR=/usr/src/app

RUN set -x \
  && mkdir -p "${WORKDIR}" \
  && apt-get update -y \
  && apt-get install -y curl wget vim iputils-ping net-tools dnsutils postgresql-client mysql-client redis-tools \
  && echo 'alias redis="redis-cli"' | tee -a /root/.bashrc \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR ${WORKDIR}

CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
