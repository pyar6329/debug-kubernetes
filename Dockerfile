FROM ubuntu:22.04

ENV LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    DEBIAN_FRONTEND=noninteractive

ARG USERNAME=ubuntu
ARG GROUPNAME=ubuntu
ARG UID=1000
ARG GID=1000
ARG POSTGRESQL_CLIENT_VERSION="14"

RUN set -x \
  && groupadd -g $GID $GROUPNAME \
  && useradd -m -s /bin/bash -u $UID -g $GID $USERNAME \
  && apt-get update -y \
  && apt-get install -y --no-install-recommends curl wget ca-certificates gnupg dirmngr lsb-release \
  && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && RELEASE=$(lsb_release -cs) \
  && echo "deb http://apt.postgresql.org/pub/repos/apt/ ${RELEASE}-pgdg main" | tee -a /etc/apt/sources.list.d/pgdg.list \
  && apt-get update -y \
  && apt-get install -y --no-install-recommends vim iputils-ping net-tools dnsutils postgresql-client-${POSTGRESQL_CLIENT_VERSION} redis-tools jq unzip less \
  && curl -sL -o /usr/local/bin/yq $(curl -sL https://api.github.com/repos/mikefarah/yq/releases/latest | jq -r '.assets[] | select(.name == "yq_linux_amd64") | .browser_download_url') \
  && curl -sL $(curl -sL https://api.github.com/repos/fullstorydev/grpcurl/releases/latest | jq -r '.assets[] | select(.name | contains("linux_x86_64.tar.gz")) | .browser_download_url') | tar zx -C /usr/local/bin 'grpcurl' \
  && curl -sL $(curl -sL https://api.github.com/repos/ktr0731/evans/releases/latest | jq -r '.assets[] | select(.name | contains("evans_linux_amd64.tar.gz")) | .browser_download_url') | tar zx -C /usr/local/bin 'evans' \
  && chmod +x  /usr/local/bin/* \
  && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
  && unzip awscliv2.zip \
  && ./aws/install \
  && rm -rf aws awscliv2.zip \
  && apt-get purge -y --auto-remove gnupg dirmngr lsb-release \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /root/.[pw]* \
  && echo 'alias redis="redis-cli"' | tee -a /root/.bashrc \
  && echo 'alias grpc="grpcurl"' | tee -a /root/.bashrc

USER $USERNAME
WORKDIR /home/$USERNAME

CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
