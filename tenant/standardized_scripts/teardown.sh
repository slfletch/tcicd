#!/bin/bash
# shellcheck source=/dev/null

. "${TENANT_HOME}/utils.sh"

run_tenant_target "teardown" "${TENANT_TEARDOWN}"
