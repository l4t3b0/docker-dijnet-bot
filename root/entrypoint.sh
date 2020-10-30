#!/bin/bash

eval_cron_shortcuts() {
  # Re-write cron shortcut
  case "$(echo "${CRON}" | tr '[:lower:]' '[:upper:]')" in
    *@YEARLY* ) echo "INFO: Cron shortcut ${CRON} re-written to 0 0 1 1 *" && CRONS="0 0 1 1 *";;
    *@ANNUALLY* ) echo "INFO: Cron shortcut ${CRON} re-written to 0 0 1 1 *" && CRONS="0 0 1 1 *";;
    *@MONTHLY* ) echo "INFO: Cron shortcut ${CRON} re-written to 0 0 1 * *" && CRONS="0 0 1 * * ";;
    *@WEEKLY* ) echo "INFO: Cron shortcut ${CRON} re-written to 0 0 * * 0" && CRONS="0 0 * * 0";;
    *@DAILY* ) echo "INFO: Cron shortcut ${CRON} re-written to 0 0 * * *" && CRONS="0 0 * * *";;
    *@MIDNIGHT* ) echo "INFO: Cron shortcut ${CRON} re-written to 0 0 * * *" && CRONS="0 0 * * *";;
    *@HOURLY* ) echo "INFO: Cron shortcut ${CRON} re-written to 0 * * * *" && CRONS="0 * * * *";;
    *@* ) echo "WARNING: Cron shortcut ${CRON} is not supported. Stopping." && exit 1;;
    * ) CRONS=${CRON};;
  esac
}

exec_on_startup() {
  if [ -z "${SYNC_ON_STARTUP}" ]
  then
    echo "INFO: Add SYNC_ON_STARTUP=true to perform a sync upon boot"
  else
    echo TEEEEEEEEEEEEEEEEEST 1
    su dijnet-bot -c pwd
    echo TEEEEEEEEEEEEEEEEEST 2
    su "$USER" -c /usr/bin/dijnet-bot-sync.sh
    echo TEEEEEEEEEEEEEEEEEST 3
  fi
}

init_cron() {
  if [ -z "${CRON}" ]
  then
    echo "INFO: No CRON setting found. Stopping. (Tip: Add CRON=\"0 0 * * *\" to perform sync every midnight)"
    exit 1
  else
    # Setup cron schedule
    crontab -d
    echo "${CRON} su $USER -c /usr/bin/dijnet-bot-sync.sh >> /var/log/dijnet-bot/dijnet-bot-sync.crontab.log 2>&1" > /tmp/crontab.tmp
    if [ -z "$CRON_ABORT" ]
    then
      echo "INFO: Add CRON_ABORT=\"0 6 * * *\" to cancel outstanding sync at 6am"
    else
      echo "$CRON_ABORT /usr/bin/dijnet-bot-sync-abort.sh >> /var/log/dijnet-bot/dijnet-bot-sync-abort.crontab.log 2>&1" >> /tmp/crontab.tmp
    fi
    crontab /tmp/crontab.tmp
    rm /tmp/crontab.tmp

    # Start cron
    echo "INFO: Starting crond ..."
    touch /tmp/sync.log
    touch /tmp/crond.log
    crond -b -l 0 -L /tmp/crond.log
    echo "INFO: crond started"
    tail -F /tmp/crond.log /tmp/sync.log
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
  PUID=${PUID:-$(id -u dijnet-bot)}
  PGID=${PGID:-$(id -g dijnet-bot)}

  groupmod -o -g "${PGID}" ${GROUP}
  usermod -o -u "${PUID}" ${USER}

  echo "INFO: Configuring directories ownership. PUID=${PUID}; PGID=${PGID};"
  chown -R ${USER}:${GROUP} /data
  chown -R ${USER}:${GROUP} /var/log/dijnet-bot
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

eval_cron_shortcuts

exec_on_startup

init_cron

