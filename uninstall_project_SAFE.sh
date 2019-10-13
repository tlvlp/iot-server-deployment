#!/bin/bash

# Safely uninstalls the project deleting all data but leaving all dependencies
#
# NOTES:
# - Requires the current user's access to the docker group.
# - Currently some parts of the setup assume a single-node Docker Swarm "cluster"

# Source scripts
. ./config.sh
. ./main.sh

SCRIPT_SCOPE="SAFE Uninstall"

echo "[$(date)] [MAIN] - Starting tlvlp IoT Server Deployment: ${SCRIPT_SCOPE}"

echo -n "[$(date)] [MAIN] - This will remove all data but leave other dependencies intact.\
Are you sure you want uninstall the project? (y/n) "
read response

if [[ ${response} = "y" ]]; then
  echo "[$(date)] [MAIN] - Proceeding with the uninstall!"
  uninstall_project_SAFE
else
  echo "[$(date)] [MAIN] - Canceling run!"
fi

echo "[$(date)] [MAIN] - End of tlvlp IoT Server Deployment: ${SCRIPT_SCOPE}"
