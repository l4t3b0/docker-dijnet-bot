#!/bin/bash

exec_on_startup() {
  if [ -z "${SYNC_ON_STARTUP}" ]
  then
    echo "INFO: Add SYNC_ON_STARTUP=true to perform a sync upon boot"
  else
    set +e
    su "${USER}" -s /bin/sh -c /usr/bin/dijnet-bot-sync.sh
    set -e
  fi
}

init_cron() {
  local crondlog
  local cronline
  local cronfile
  local crontablog

  cronfile=/tmp/crontab.tmp
  crontablog=${DIJNET_LOG_DIR}/dijnet-bot-sync.crontab.log 
  crondlog=${DIJNET_LOG_DIR}/dijnet-bot.crond.log

  # Setup cron schedule
  crontab -d
  echo "SHELL=/bin/sh" > ${cronfile}

  if [ -z "${CRON}" ]
  then
    echo "INFO: No CRON setting found. Stopping. (Tip: Add CRON=\"0 0 * * *\" to perform sync every midnight)"
  else
    cronline="${CRON} /usr/bin/dijnet-bot-sync.sh >> ${crondtablog} 2>&1"
    echo ${cronline} >> ${cronfile}

    if [ -z "$CRON_ABORT" ]
    then
      echo "INFO: Add CRON_ABORT=\"0 6 * * *\" to cancel outstanding sync at 6am"
    else
      cronline="${CRON_ABORT} /usr/bin/dijnet-bot-sync-abort.sh >> ${crontablog}2>&1"
      echo ${cronline} >> ${cronfile}
    fi

    crontab -u ${USER} ${cronfile}
    rm ${cronfile}
    echo "INFO: crontab content for user ${USER} is:\n$(crontab -l -u ${USER})"

    # Start cron
    echo "INFO: Starting crond ..."
    touch ${crondlog}
    crond -f -l 0 -L ${crondlog}
    echo "INFO: crond started"
    tail -F ${crondlog}
  fi
}

init_timezone() {
  # Set time zone if passed in
  if [ ! -z "${TZ}" ]
  then
    echo "INFO: Configuring timezone for: ${TZ}." 

    cp /usr/share/zoneinfo/${TZ} /etc/localtime
    echo ${TZ} > /etc/timezone
  fi
}

init_user() {
  PUID=${PUID:-$(id -u ${USER})}
  PGID=${PGID:-$(id -g ${GROUP})}

  groupmod -o -g "${PGID}" ${GROUP}
  usermod -o -u "${PUID}" ${USER}

  echo "INFO: Configuring directories ownership. PUID=${PUID}; PGID=${PGID};"
  chown -R ${USER}:${GROUP} /data
  chown -R ${USER}:${GROUP} ${DIJNET_LOG_DIR}
  chown -R ${USER}:${GROUP} ${DIJNET_PID_DIR}
}

set -e

# Announce version
echo "INFO: Running ${DIJNET_VERSION}"

if [ -z ${DIJNET_USER} ]; then
  echo "ERROR: No DIJNET_USER defined. Stopping."
  exit 1
elif [ -z "${PGID}" -a ! -z "${PUID}" ] || [ -z "${PUID}" -a ! -z "${PGID}" ]; then
  echo "WARNING: Must supply both PUID and PGID or neither. Stopping."
  exit 1
elif [ ! -z "${TZ}" -a ! -f /usr/share/zoneinfo/${TZ} ]; then
  echo "WARNING: TZ was set '${TZ}', but corresponding zoneinfo file does not exist. Stopping."
  exit 1
fi

init_user

init_timezone

exec_on_startup

init_cron

