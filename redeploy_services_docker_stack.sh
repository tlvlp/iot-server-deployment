#!/bin/bash

# Redeploy services Docker stack
#
# NOTES:
# - Requires the current user's access to the docker group.
# - Currently some parts of the setup assume a single-node Docker Swarm "cluster"

# Source scripts
. ./config.sh
. ./main.sh

SCRIPT_SCOPE="Redeploy services Docker stack"

echo "[$(date)] [MAIN] - Starting tlvlp IoT Server Deployment: ${SCRIPT_SCOPE}"

redeploy_services_docker_stack

echo "[$(date)] [MAIN] - End of tlvlp IoT Server Deployment: ${SCRIPT_SCOPE}"
