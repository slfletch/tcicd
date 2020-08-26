ARG BASE_IMAGE=


ENV TENANT_USER="stacey"
ENV TENANT_USER_HOME="/home/${TENANT_USER}"
ENV TENANT_CMD="${TENANT_HOME}/cmd"
ENV TENANT _RUN="${TENANT_CMD}/run"

ENV TENANT _SETUP="${TENANT_CMD}/setup"
ENV TENANT _TEARDOWN="${TENANT_CMD}/teardown"
ENV MYRUNNER _STOP="${TENANT_CMD}/stop"
ENV TENANT_FINALLY="${TENANT_CMD}/finally"
ENV TENANT_INPUT="${TENANT_HOME}/input"
ENV TENANT_OUTPUT="${TENANT_HOME}/output"
ENV TENANT_FRAMEWORK_LOG="${TENANT_OUTPUT}/TENANT_framework.log"
ENV TENANT_MESSAGE_LOG="${TENANT_OUTPUT}/messages.log"
ENV TENANT_WARNING_LOG="${TENANT_OUTPUT}/warnings.log"
ENV TENANT_ERROR_LOG="${TENANT_OUTPUT}/errors.log"
ENV TENANT_FAILURE_MESSAGE_FILE="${TENANT_OUTPUT}/Runner-failure-message.txt"
ENV DOCKER_REGISTRY="mydockerregistry"
ENV TENANT_STOPPER_PORT="60106"
ENV TENANT_OUTPUT_DIAGNOSTICS="${TENANT_OUTPUT}/diagnostic"

COPY --chown=${TENANT_USER}:${TENANT_USER} "${CTX_BASE}/image_builder/scripts/setup.sh" "${TENANT_HOME}/cmd/setup"
COPY --chown= tenantUser:tenantUser "${CTX_BASE}/image_builder/scripts/run.sh" "${TENANT_HOME}/cmd/run"
COPY --chown= tenantUser:tenantUser "${CTX_BASE}/image_builder/scripts/teardown.sh" "${TENANT_HOME}/cmd/teardown"


