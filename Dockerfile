ARG BASE=alpine:latest
FROM ${BASE}

LABEL maintainer="l4t3b0@gmail.com"

ARG DIJNET_VERSION=v2.1.6

ENV DIJNET_USER=
ENV DIJNET_PASS=
ENV SLEEP=1
ENV LOG_MODE=default

ENV SYNC_ON_STARTUP=

ENV CRON=
ENV CRON_ABORT=

ENV HEALTHCHECKS_IO_URL=

ENV TZ=
ENV PUID=0
ENV PGID=0

RUN apk --no-cache add \
  bash \
  ca-certificates \
  curl \
  nodejs \
  npm \
  wget

RUN curl -SL https://github.com/juzraai/dijnet-bot/archive/${DIJNET_VERSION}.tar.gz \
  | tar -xzvC /tmp \
  && npm i -g /tmp/dijnet-bot-2.1.6

RUN mkdir /data
RUN mkdir /var/log/dijnet-bot && chown ${PUID}:${PGID} /var/log/dijnet-bot && chmod 775 /var/log/dijnet-bot

COPY entrypoint.sh /
COPY dijnet-bot-sync.sh /usr/bin

VOLUME ["/var/log/dijnet-bot"]
VOLUME ["/data"]

ENTRYPOINT ["/entrypoint.sh"]

CMD [""]
