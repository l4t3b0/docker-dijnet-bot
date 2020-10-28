ARG BASE=alpine:latest
FROM ${BASE}

LABEL maintainer="l4t3b0@gmail.com"

ARG DIJNET_VERSION=v2.1.6

ENV DIJNET_USER=
ENV DIJNET_PASS=
ENV SLEEP=1
ENV LOG_MODE=default

ENV CRON=
ENV CRON_ABORT=

ENV HEALTHCHECKS_IO_URL=

ENV TZ=
ENV PUID=0
ENV PGID=0

RUN apk --no-cache add bash ca-certificates nodejs npm wget

RUN URL=https://github.com/juzraai/dijnet-bot/releases/download/${DIJNET_VERSION}/dijnet-bot.js; \
  cd / \
  && wget -q $URL

RUN mkdir /data
RUN mkdir /etc/dinet-bot
RUN mkdir /var/lib/dinet-bot && chown ${PUID}:${PGID} /var/lib/dinet-bot && chmod 775 /var/lib/dinet-bot
RUN mkdir /var/log/dinet-bot && chown ${PUID}:${PGID} /var/log/dinet-bot && chmod 775 /var/log/dinet-bot

COPY entrypoint.sh /

VOLUME ["/etc/dijnet-bot/dijnet-bot.conf"]
VOLUME ["/var/log/dijnet-bot"]
VOLUME ["/data"]

ENTRYPOINT ["/entrypoint.sh"]

CMD [""]
