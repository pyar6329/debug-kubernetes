FROM ubuntu:20.04

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
  && curl -sL -o /usr/local/bin/yq $(curl -sL https://api.github.com/repos/mikefarah/yq/releases/latest | jq -r '.assets[] | select(.name == "yq_linux_amd64") | .browser_download_url') \
  && curl -sL $(curl -sL https://api.github.com/repos/fullstorydev/grpcurl/releases/latest | jq -r '.assets[] | select(.name | contains("linux_x86_64.tar.gz")) | .browser_download_url') | tar zx -C /usr/local/bin 'grpcurl' \
  && curl -sL $(curl -sL https://api.github.com/repos/ktr0731/evans/releases/latest | jq -r '.assets[] | select(.name | contains("evans_linux_amd64.tar.gz")) | .browser_download_url') | tar zx -C /usr/local/bin 'evans' \
  && chmod +x  /usr/local/bin/* \
  && apt-get purge -y --auto-remove gnupg dirmngr lsb-release \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /root/.[pw]* \
  && echo 'alias redis="redis-cli"' | tee -a /root/.bashrc \
  && echo 'alias grpc="grpcurl"' | tee -a /root/.bashrc

WORKDIR ${WORKDIR}

CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
