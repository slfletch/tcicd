#!/bin/bash

# Use the environment variable or a default.
[ "${TENANT_FRAMEWORK_LOG}" ] && LOG_FILE="${TENANT_FRAMEWORK_LOG}" || LOG_FILE="/home/tenant/output/tenant_framework.log"

# Print out a usage for the invoked method, and return a failure code
usage() {
    echo "Usage:"
    echo "$1"
    return 1
}

# Run the command specified, capture system out to the framework log, and return the
# code generated by the target command.
# A return code of 99 indicates a failure in framework expectations.
USAGE_RUN_TENANT_TARGET="run_tenant_target [name] [command]"
run_tenant_target() {
  echo "Run tenant target kubectl commands!"
}