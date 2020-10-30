ARG BASE=alpine:latest
FROM ${BASE}

LABEL maintainer="l4t3b0@gmail.com"

ARG DIJNET_VERSION=2.1.6

ENV DIJNET_USER=
ENV DIJNET_PASS=
ENV SLEEP=1
ENV LOG_MODE=default
ENV OUTPUT_DIR=/data

ENV SYNC_ON_STARTUP=

ENV CRON=
ENV CRON_ABORT=

ENV HEALTHCHECKS_IO_URL=

ENV USER=dijnet-bot
ENV GROUP=dijnet-bot

RUN apk --no-cache add \
  bash \
  ca-certificates \
  curl \
  nodejs \
  npm \
  shadow \
  tzdata \
  wget

RUN curl -SL https://github.com/juzraai/dijnet-bot/archive/v${DIJNET_VERSION}.tar.gz \
  | tar -xzvC /tmp \
  && npm i -g /tmp/dijnet-bot-${DIJNET_VERSION}

RUN groupadd ${GROUP} && \
  useradd -s /bin/false ${USER} -g ${GROUP}

RUN mkdir /data
RUN mkdir /var/log/dijnet-bot

COPY root/ /

VOLUME ["/var/log/dijnet-bot"]
VOLUME ["/data"]

ENTRYPOINT ["/entrypoint.sh"]

CMD [""]
