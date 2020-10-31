ARG BASE=alpine:latest
FROM ${BASE}

LABEL maintainer="l4t3b0@gmail.com"

ENV APP_VERSION=2.1.7
ENV APP_NAME=dijnet-bot

ENV USER=dijnet
ENV GROUP=dijnet

ENV CONFIG_DIR=/etc/${APP_NAME}
ENV LOG_DIR=/var/log/${APP_NAME}
ENV RUN_DIR=/var/run/${APP_NAME}

ENV CONFIG_FILE=${CONFIG_DIR}/${APP_NAME}.conf
ENV PID_FILE=${RUN_DIR}/${APP_NAME}.pid

ENV EXECUTE_ON_STARTUP=

ENV CRON=
ENV CRON_ABORT=

ENV HEALTHCHECKS_IO_URL=

ENV OUTPUT_DIR=/data

RUN apk --no-cache add \
  bash \
  ca-certificates \
  curl \
  nodejs \
  npm \
  shadow \
  tzdata

RUN curl -SL https://github.com/juzraai/dijnet-bot/archive/v${APP_VERSION}.tar.gz \
  | tar -xzvC /usr/lib \
  && npm i -g /usr/lib/dijnet-bot-${APP_VERSION}

RUN groupadd ${GROUP} && \
  useradd -s /bin/false ${USER} -g ${GROUP}

RUN mkdir ${OUTPUT_DIR}
RUN mkdir ${CONFIG_DIR} && chown 755 ${CONFIG_DIR}
RUN mkdir ${LOG_DIR} && chown 755 ${LOG_DIR}
RUN mkdir ${RUN_DIR} && chown 755 ${RUN_DIR}

COPY root/ /

VOLUME [${CONF_DIR}]
VOLUME [${LOG_DIR}]
VOLUME [${OUTPUT_DIR}]

ENTRYPOINT ["/entrypoint.sh"]

CMD [""]
