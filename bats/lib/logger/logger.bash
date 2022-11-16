#!/usr/bin/env bash

# If the log level is not provided then TEST_LOG_LEVEL is set to INFO
if [ -z "$TEST_LOG_LEVEL" ]; then
  TEST_LOG_LEVEL="INFO";
fi
# This function translate the log level name to int priority, we wouldn't need this if we could use newer bash with proper arrays (-A)
get_log_level() {
  local priority

  case $1 in

      INFO)
        priority=0
        ;;

      DEBUG)
        priority=1
        ;;

      ERROR)
        priority=2
        ;;

      *)
        priority=-1
        ;;
    esac

    echo $priority
}

log() {
 local log_level_priority
 log_level_priority=$(get_log_level $TEST_LOG_LEVEL)
 local message_level=$1
 local message_priority
 message_priority=$(get_log_level $message_level)
 local message=$2

 if (( message_priority < 0 )) ; then
    echo "The log level '${message_level}' is incorrect, supported log levels: INFO, DEBUG, ERROR."
    exit 1
  fi

  # Check if message should be printed based on the message level
  if (( log_level_priority >= message_priority )); then
    # print the log message
    echo "${message_level} : ${message}" >&3
  fi
}
