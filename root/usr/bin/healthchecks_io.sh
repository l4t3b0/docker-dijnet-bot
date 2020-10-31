#!/bin/sh

healthchecks_io_start() {
  local url

  if [ ! -z "${HEALTHCHECKS_IO_URL}" ]
  then
    url=${HEALTHCHECKS_IO_URL}/start
    echo "INFO: Sending helatchecks.io start signal to '${url}'"

    set +e
    curl -SL ${url}
    set -e
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

    set +e
    curl -SL ${url}
    set -e
  fi
}
