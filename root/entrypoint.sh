#!/bin/bash

shell=/bin/sh
name=dijnet-bot-sync
executable=/usr/bin/${name}.sh
app_version=${APP_VERSION}
cron_executable=/usr/bin/${name}-abort.sh
directories=(/data ${CONFIG_DIR} ${LOG_DIR} ${RUN_DIR})

exec_on_startup() {
  if [ -z "${EXECUTE_ON_STARTUP}" ]
  then
    echo "INFO: Add EXECUTE_ON_STARTUP=true to perform execution on startup"
  else
    set +e
    su "${USER}" -s ${shell} -c ${executable}
    set -e
  fi
}

init_cron() {
  local crond_log
  local crontab_entry
  local crontab_file
  local crontab_log

  crontab_file=$(mktemp)
  crontab_log=${LOG_DIR}/${name}.crontab.log 
  crontab_abort_log=${LOG_DIR}/${name}-abort.crontab.log 
  crond_log=${LOG_DIR}/${name}.crond.log

  crontab -d
  echo "SHELL=${shell}" > ${crontab_file}
  echo "CRON_TZ=${TZ}" >> ${crontab_file}

  if [ -z "${CRON}" ]
  then
    echo "INFO: No CRON setting found. Stopping. (Tip: Add CRON=\"0 0 * * *\" to perform execution at every midnight)"
  else
    crontab_entry="${CRON} ${exucutable} >> ${crontab_log} 2>&1"
    echo ${crontab_entry} >> ${crontab_file}

    if [ -z "$CRON_ABORT" ]
    then
      echo "INFO: Add CRON_ABORT=\"0 6 * * *\" to cancel executable at 6am"
    else
      crontab_entry="${CRON_ABORT} ${cron_executable} >> ${crontab_abort_log}2>&1"
      echo ${crontab_entry} >> ${crontab_file}
    fi

    set +e
    crontab -u ${USER} ${crontab_file}
    set -e

    rm ${crontab_file}
    echo "INFO: crontab content for user ${USER} is:"
    echo $(crontab -l -u ${USER})

    # Start cron
    echo "INFO: Starting crond ..."
    touch ${crond_log}

    set +e
    crond -b -l 0 -L ${crond_log}
    set -e

    echo "INFO: crond started"
    tail -F ${crond_log}
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
  for directory in ${directories[@]}; do
    echo "INFO: Modifying ownership of directory: ${directory}"
    chown ${USER}:${GROUP} ${directory}
  done
}

set -e

# Announce version
echo "INFO: Running ${name} version: ${app_version}"

if [ -z "${PGID}" -a ! -z "${PUID}" ] || [ -z "${PUID}" -a ! -z "${PGID}" ]; then
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

