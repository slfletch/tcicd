#!/bin/bash
# shellcheck source=/dev/null

. "${TENANT_HOME}/utils.sh"

if [ -f "${TENANT_STOP}" ]; then
    run_tenant_target "stop" "${TENANT_STOP}"
else
    infralog "Using default STOP functionality (SIGTERM to run pid)."
    if [ -f "${TENANT_HOME}/run.pid" ]; then
        infralog "Sending SIGTERM to $(cat "${TENANT_HOME}"/run.pid)"
        infralog "$(kill "$(cat "${TENANT_HOME}"/run.pid)" 2>&1)"
    else
        echo "There is no pid for the run process. No action taken."
    fi
fi