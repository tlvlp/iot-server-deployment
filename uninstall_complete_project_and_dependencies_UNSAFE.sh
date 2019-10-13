#!/bin/bash

# Uninstalls the complete project removing all dependencies
#
# This includes uninstalling Docker as well!
# For details see the RUN_CONFIGURATIONS section of the main.sh
#
# NOTES:
# - Requires the current user's access to the docker group.
# - Currently some parts of the setup assume a single-node Docker Swarm "cluster"

# Source scripts
. ./config.sh
. ./main.sh

SCRIPT_SCOPE="UNSAFE - Uninstall complete project and dependencies"

echo "[$(date)] [MAIN] - Starting tlvlp IoT Server Deployment: ${SCRIPT_SCOPE}"

echo -n "[$(date)] [MAIN] - Are you sure you want to remove the project with all dependencies?
This will also completely uninstall Docker and others that might have severe side-effects.
Type 'yes remove everything' to proceed or anything else to exit: "
read response

if [[ ${response} = "yes remove everything" ]]; then
  echo "[$(date)] [MAIN] - Proceeding with the uninstall!"
  uninstall_complete_project_and_dependencies_UNSAFE
else
  echo "[$(date)] [MAIN] - Canceling run!"
fi

echo "[$(date)] [MAIN] - End of tlvlp IoT Server Deployment: ${SCRIPT_SCOPE}"
