FROM ubuntu:18.04

ENV WORKDIR=/debug \
    LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    DEBIAN_FRONTEND=noninteractive

ARG POSTGRESQL_CLIENT_VERSION="12"

RUN set -x \
  && mkdir -p "${WORKDIR}" \
  && apt-get update -y \
  && apt-get install -y --no-install-recommends curl wget ca-certificates gnupg dirmngr lsb-release \
  && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && RELEASE=$(lsb_release -cs) \
  && echo "deb http://apt.postgresql.org/pub/repos/apt/ ${RELEASE}-pgdg main" | tee -a /etc/apt/sources.list.d/pgdg.list \
  && apt-get update -y \
  && apt-get install -y --no-install-recommends vim iputils-ping net-tools dnsutils postgresql-client-${POSTGRESQL_CLIENT_VERSION} redis-tools jq \
  && apt-get purge -y --auto-remove gnupg dirmngr lsb-release \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /root/.[pw]* \
  && echo 'alias redis="redis-cli"' | tee -a /root/.bashrc

WORKDIR ${WORKDIR}

CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
