#!/bin/bash

# Installs the project to a clean environment eg. a new server
#
# NOTES:
# - Requires a clean environment without Docker or any of the project artifacts installed
# - Requires sudo privileges.
# - Currently some parts of the setup assume a single-node Docker Swarm "cluster"

# Source scripts
. ./config.sh
. ./main.sh

SCRIPT_SCOPE="Complete install"

echo "[$(date)] [MAIN] - Starting tlvlp IoT Server Deployment: ${SCRIPT_SCOPE}"


echo -n "[$(date)] [MAIN] - Are you sure you want to make a full install?
This should only be done on a clean machine without Docker installed. Otherwise it might result in conflicts. (y/n) "
read response

if [[ ${response} = "y" ]]; then
  echo "[$(date)] [MAIN] - Proceeding with the install!"
  install_to_clean_environment
else
  echo "[$(date)] [MAIN] - Canceling run!"
fi


echo "[$(date)] [MAIN] - End of tlvlp IoT Server Deployment: ${SCRIPT_SCOPE}"
