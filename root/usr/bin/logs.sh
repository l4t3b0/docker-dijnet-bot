#!/bin/sh

logs_purge() {
  local log_dir=$1
  local n_days=${2:-365}

  # Delete logs by user request
  if [ ! -z "${LOG_ROTATE##*[!0-9]*}" ]
  then
    echo "INFO: Purging logs older than ${n_days} day(s)..."
    touch ${log_dir}/tmp.log && find ${log_dir}/*.log -mtime +${n_days} -type f -delete && rm -f ${log_dir}/tmp.log
  fi
}
