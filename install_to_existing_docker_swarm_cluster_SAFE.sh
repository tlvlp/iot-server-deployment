#!/bin/bash

# Installs the project to an existing Docker Swarm cluster
#
# NOTES:
# - Requires a Docker Swarm cluster to be set up
# - Any resources left over from a previous installation (secrets, volumes) might cause problems
# - Requires the current user's access to the docker group.
# - Currently some parts of the setup assume a single-node Docker Swarm "cluster"

# Source scripts
. ./config.sh
. ./main.sh

SCRIPT_SCOPE="Install project to an existing Docker Swarm cluster"

echo "[$(date)] [MAIN] - Starting tlvlp IoT Server Deployment: ${SCRIPT_SCOPE}"

echo -n "[$(date)] [MAIN] - Are you sure you want install the project? (y/n) "
read response

if [[ ${response} = "y" ]]; then
  echo "[$(date)] [MAIN] - Proceeding with the install!"
  install_to_existing_docker_swarm_cluster
else
  echo "[$(date)] [MAIN] - Canceling run!"
fi


echo "[$(date)] [MAIN] - End of tlvlp IoT Server Deployment: ${SCRIPT_SCOPE}"
