ARG BASE=alpine:latest
FROM ${BASE}

LABEL maintainer="l4t3b0@gmail.com"

ENV USER=dijnet
ENV GROUP=dijnet

ARG DIJNET_CONFIG_DIR=/etc/dijnet-bot
ARG DIJNET_LOG_DIR=/var/log/${USER}
ARG DIJNET_RUN_DIR=/var/run/${USER}

ENV DIJNET_VERSION=2.1.7
ENV DIJNET_CONFIG_FILE=${DIJNET_CONFIG_DIR}/dijnet-bot.conf

ENV EXECUTE_ON_STARTUP=

ENV CRON=
ENV CRON_ABORT=

ENV HEALTHCHECKS_IO_URL=

ENV DIJNET_PID_FILE=${DIJNET_RUN_DIR}/${USER}.pid
ENV OUTPUT_DIR=/data

RUN apk --no-cache add \
  bash \
  ca-certificates \
  curl \
  nodejs \
  npm \
  shadow \
  tzdata

RUN curl -SL https://github.com/juzraai/dijnet-bot/archive/v${DIJNET_VERSION}.tar.gz \
  | tar -xzvC /usr/lib \
  && npm i -g /usr/lib/dijnet-bot-${DIJNET_VERSION}

RUN groupadd ${GROUP} && \
  useradd -s /bin/false ${USER} -g ${GROUP}

RUN mkdir ${OUTPUT_DIR}
RUN mkdir ${DIJNET_CONFIG_DIR} && chown 755 ${DIJNET_CONFIG_DIR}
RUN mkdir ${DIJNET_LOG_DIR} && chown 755 ${DIJNET_LOG_DIR}
RUN mkdir ${DIJNET_RUN_DIR} && chown 755 ${DIJNET_RUN_DIR}

COPY root/ /

VOLUME [${DIJNET_CONF_DIR}]
VOLUME [${DIJNET_LOG_DIR}]
VOLUME [${OUTPUT_DIR}]

ENTRYPOINT ["/entrypoint.sh"]

CMD [""]
