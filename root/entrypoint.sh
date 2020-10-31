#!/bin/bash

shell=/bin/sh
app_name=${APP_NAME}
app_version=${APP_VERSION}
executable=/usr/bin/${app_name}-sync.sh
executable_abort=/usr/bin/${app_name}-sync-abort.sh
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

init_config_file() {
  if [ ! -f ${CONFIG_FILE} ]
  then
    echo "INFO: Configuration file ${CONFIG_FILE} does not exists. Copyin template file to location"
    cp /usr/local/dijnet-bot/dijnet-bot.conf.template ${CONFIG_FILE}
    echo "WARNING: please initialize necessary environment variables in config file and restart the container. Exiting"
    exit 1
  fi
}

init_cron() {
  local crond_log
  local crontab_entry
  local crontab_file
  local crontab_log

  crontab_file=$(mktemp)
  crontab_log=${LOG_DIR}/${app_name}.crontab.log 
  crontab_abort_log=${LOG_DIR}/${app_name}-abort.crontab.log 
  crond_log=${LOG_DIR}/${app_name}.crond.log

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
      crontab_entry="${CRON_ABORT} ${executable_abort} >> ${crontab_abort_log}2>&1"
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
echo "INFO: Running ${app_name} version: ${app_version}"

if [ -z "${PGID}" -a ! -z "${PUID}" ] || [ -z "${PUID}" -a ! -z "${PGID}" ]; then
  echo "WARNING: Must supply both PUID and PGID or neither. Stopping."
  exit 1
elif [ ! -z "${TZ}" -a ! -f /usr/share/zoneinfo/${TZ} ]; then
  echo "WARNING: TZ was set '${TZ}', but corresponding zoneinfo file does not exist. Stopping."
  exit 1
fi

init_config_file

init_user

init_timezone

exec_on_startup

init_cron

