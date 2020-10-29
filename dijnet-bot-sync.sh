#!/bin/sh

healthchecks_io_start() {
  local url

  if [ ! -z "${HEALTHCHECKS_IO_URL}" ]
  then
    url=${HEALTHCHECKS_IO_URL}/start
    echo "INFO: Sending helatchecks.io start signal to '${url}'"

    wget ${url} -O /dev/null
  fi
}

healthchecks_io_end() {
  local return_code=$1
  local url

  # Wrap up healthchecks.io call with complete or failure signal
  if [ ! -z "${HEALTHCHECKS_IO_URL}" ]
  then
    if [ "${return_code}" == 0 ]
    then
      url=${HEALTHCHECKS_IO_URL}
      echo "INFO: Sending helatchecks.io complete signal to '${url}'"
    else
      url=${HEALTHCHECKS_IO_URL}/fail
      echo "WARNING: Sending helatchecks.io failure signal to '${url}'"
    fi

    wget ${url} -O /dev/null
  fi
}

is_dijnet_bot_running() {
  if [ $(lsof | grep $0 | wc -l | tr -d ' ') -gt 1 ]
  then
    return 0
  else
    return 1
  fi
}

dijnet_bot_cmd_exec() {
  CMD="dijnet-bot"

  if [ ! -z "$LOG_ENABLED" ]
  then
    d=$(date +%Y_%m_%d-%H_%M_%S)
    LOG_FILE="${log_dir}/dijnet-bot-$d.log"
    CMD="${CMD} > ${LOG_FILE}"
  fi

  echo "INFO: Executing: ${CMD}"
  set +e
  eval ${CMD}
  return_code=$?
  set -e

  return ${return_code}
}

rotate_logs() {
  # Delete logs by user request
  if [ ! -z "${LOG_ROTATE##*[!0-9]*}" ]
  then
    echo "INFO: Removing logs older than ${LOG_ROTATE} day(s)..."
    touch ${log_dir}/tmp.log && find ${log_dir}/*.log -mtime +${LOG_ROTATE} -type f -delete && rm -f ${log_dir}/tmp.log
  fi
}

set -e

pid_file=/var/lock/dijnet-bot-sync.pid
log_dir=/var/log/dijnet-bot

echo "INFO: Starting sync.sh pid $$ $(date)"

if is_dijnet_bot_running
then
  echo "WARNING: A previous dijnet-bot instance is still running. Skipping command."
else
  echo $$ > ${pid_file}
  echo "INFO: PID file created successfuly: ${pid_file}"

  healthchecks_io_start

  rotate_logs

  dijnet_bot_cmd_exec

  return_code=$?

  healthchecks_io_end ${return_code}

  echo "INFO: Removing PID file"
  rm -f ${pid_file}
fi
