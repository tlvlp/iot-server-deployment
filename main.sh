#!/usr/bin/env bash

########################################################################################################################
# HOST_ENVIRONMENT_SETUP
########################################################################################################################

### RUN DEPENDENCIES ###

apt_get_update_done=''

_ensure_bash_dependency() {
  local package_name=$1
  if [[ ! $(dpkg -s ${package_name} 2>/dev/null) ]]; then
    echo "[$(date)] [HOST_ENVIRONMENT_SETUP] - Installing bash dependency: ${package_name}"
    [[ ! ${apt_get_update_done} ]] && sudo apt-get update && apt_get_update_done=true
    sudo apt-get -y install ${package_name}
  fi
}

_remove_bash_dependency() {
  local package_name=$1
  if [[ $(dpkg -s ${package_name} 2>/dev/null) ]]; then
    echo "[$(date)] [HOST_ENVIRONMENT_SETUP] - Removing bash dependency: ${package_name}"
    sudo apt-get -y remove ${package_name}
  fi
}

ensure_run_dependencies() {
  _ensure_bash_dependency 'gettext-base'
  _ensure_bash_dependency 'apache2-utils'
}

remove_run_dependencies() {
  _remove_bash_dependency 'gettext-base'
  _remove_bash_dependency 'apache2-utils'
}

### DOCKER ###

add_current_usert_to_docker_group() {
  echo "[$(date)] [HOST_ENVIRONMENT_SETUP] - Adding current user (${USER}) to the Docker group"
  sudo groupadd docker
  sudo usermod -aG docker ${USER}
}

remove_current_usert_from_docker_group_and_delete_group() {
  echo "[$(date)] [HOST_ENVIRONMENT_SETUP] - Removing current user (${USER}) from the Docker group"
  sudo deluser ${USER} docker
  sudo delgroup docker
}

install_docker() {
  echo "[$(date)] [HOST_ENVIRONMENT_SETUP] - Installing Docker"
  _ensure_bash_dependency 'curl'
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  rm get-docker.sh
  sudo systemctl enable docker
}

uninstall_docker() {
  sudo apt-get purge docker-ce
  sudo rm -rf /var/lib/docker
}

initialize_docker_swarm() {
  echo "[$(date)] [HOST_ENVIRONMENT_SETUP] - Initializing Docker Swarm"
  docker swarm init
}

log_in_to_project_docker_repositories() {
  echo "[$(date)] [HOST_ENVIRONMENT_SETUP] - Please log in to Docker Hub!"
  docker login
  echo "[$(date)] [HOST_ENVIRONMENT_SETUP] - Please log in to the project's Docker repository: ${DOCKER_PROJECT_REPO}!"
  docker login ${DOCKER_PROJECT_REPO}
}

### FIREWALL PORTS ON THE HOST ###

open_firewall_ports_on_current_host() {
  echo "[$(date)] [HOST_ENVIRONMENT_SETUP] - Opening firewall ports on the host"
  # Check if ufw is the default firewall
  if [[ ! $(dpkg -s ufw 2>/dev/null) ]]; then
    echo "[$(date)] [HOST_ENVIRONMENT_SETUP] - Error! UFW is not found. Please manually open the required ports!"
    exit 1
  fi
  # Open firewall ports
  sudo ufw allow ${DB_PORT_EXTERNAL}/tcp comment "${PROJECT_NAME}-database"
  sudo ufw allow ${DB_PORT_EXTERNAL}/udp comment "${PROJECT_NAME}-database"
  sudo ufw allow ${MQTT_BROKER_PORT_TLS}/tcp comment "${PROJECT_NAME}-mqtt_broker"
  sudo ufw allow ${MQTT_BROKER_PORT_TLS}/udp comment "${PROJECT_NAME}-mqtt_broker"
  sudo ufw allow ${API_GATEWAY_PORT}/tcp comment "${PROJECT_NAME}-api_gateway"
  sudo ufw allow ${API_GATEWAY_PORT}/udp comment "${PROJECT_NAME}-api_gateway"
  # Apply port changes
  sudo ufw reload
  sudo ufw enable
}

delete_firewall_port_rules_on_current_host() {
  echo "[$(date)] [HOST_ENVIRONMENT_SETUP] - Deleting firewall port rules on the host"
  # Check if ufw is the default firewall
  if [[ ! $(dpkg -s ufw 2>/dev/null) ]]; then
    echo "[$(date)] [HOST_ENVIRONMENT_SETUP] - Error! UFW is not found. Please manually delete the port rules!"
    exit 1
  fi
  # Open firewall ports
  sudo ufw delete allow ${DB_PORT_EXTERNAL}/tcp comment "${PROJECT_NAME}-database"
  sudo ufw delete allow ${DB_PORT_EXTERNAL}/udp comment "${PROJECT_NAME}-database"
  sudo ufw delete allow ${MQTT_BROKER_PORT_TLS}/tcp comment "${PROJECT_NAME}-mqtt_broker"
  sudo ufw delete allow ${MQTT_BROKER_PORT_TLS}/udp comment "${PROJECT_NAME}-mqtt_broker"
  sudo ufw delete allow ${API_GATEWAY_PORT}/tcp comment "${PROJECT_NAME}-api_gateway"
  sudo ufw delete allow ${API_GATEWAY_PORT}/udp comment "${PROJECT_NAME}-api_gateway"
  # Apply port changes
  sudo ufw reload
  sudo ufw enable
}

########################################################################################################################
# REMOVE_SERVICES
########################################################################################################################

### REMOVE DOCKER STACK ###

remove_services_docker_stack() {
  echo "[$(date)] [RESET_SERVICES] - Removing services stack: ${PROJECT_NAME}"
  docker stack rm ${PROJECT_NAME}
}

### DELETE DOCKER VOLUMES ###

_delete_docker_volume() {
  local volume=$1
  local exit=false
  local counter=0
  echo "[$(date)] [RESET_SERVICES] - Deleting Docker volume: ${volume}"
  while [[ ${exit} == false ]]; do
    deletion_result=$(docker volume rm -f ${volume} 2>/dev/null | sed -n 1p)
    if [[ ${deletion_result} == ${volume} ]]; then
      exit=true
      echo "[$(date)] [RESET_SERVICES] - Volume deleted successfully: ${volume}"
    elif [[ ${counter} == 10 ]]; then
      exit=true
      echo "[$(date)] [RESET_SERVICES] - Timeout reached. Unable to delete volume: ${volume}"
    else
      # Loop until the deletion confirmation is received.
      counter=$((++counter))
      sleep 1
    fi
  done
}

delete_docker_volumes_for_services() {
    _delete_docker_volume ${DB_DATA_VOLUME_NAME}
    _delete_docker_volume ${DB_CONFIG_VOLUME_NAME}
    _delete_docker_volume ${MQTT_BROKER_VOLUME_NAME}
}


### DELETE DOCKER SECRETS ###

_delete_docker_secret() {
    local secret=$1
    local exit=false
    local counter=0
    echo "[$(date)] [RESET_SERVICES] - Deleting Docker secret: ${secret}"
    while [[ ${exit} == false ]]; do
    deletion_result=$(docker secret rm "${secret}" 2>/dev/null | sed -n 1p)
    if [[ ${deletion_result} == "${secret}" ]]; then
      exit=true
      echo "[$(date)] [RESET_SERVICES] - Secret deleted successfully: ${secret}"
    elif [[ ${counter} == 10 ]]; then
      exit=true
      echo "[$(date)] [RESET_SERVICES] - Timeout reached. Unable to delete secret: ${secret}"
    else
      # Loop until the deletion confirmation is received.
      counter=$((++counter))
      sleep 1
    fi
    done
}

delete_docker_secrets_for_services() {
    _delete_docker_secret ${MQTT_CLIENT_DB_PASS_SECRET_FILE}
    _delete_docker_secret ${UNIT_SERVICE_DB_PASS_SECRET_FILE}
    _delete_docker_secret ${SCHEDULER_SERVICE_DB_PASS_SECRET_FILE}
    _delete_docker_secret ${REPORTING_SERVICE_DB_PASS_SECRET_FILE}
    _delete_docker_secret ${API_GATEWAY_DB_PASS_SECRET_FILE}
    _delete_docker_secret ${MQTT_CLIENT_MQTT_BROKER_PASS_SECRET_FILE}
    _delete_docker_secret ${API_GATEWAY_SECURITY_PASS_BACKEND_SECRET_FILE}
 }


########################################################################################################################
# SET_UP_SERVICES
########################################################################################################################

_generate_password() {
  echo -n $(tr </dev/urandom -dc _A-Z-a-z-0-9 | head -c${1:-32})
}

### DATABASE ###

_generate_and_save_db_passwords_for_all_services() {
    echo "[$(date)] [SERVICE_INIT] - Generating database passwords and saving them as Docker secrets"

    DB_ROOT_PASS=$(_generate_password)
    # Docker secret is not created for the root pass
    echo "[$(date)] Database user: ${DB_ROOT_USER} password: ${DB_ROOT_PASS}" >>${PLAIN_TEXT_PASS_FILE}

    MQTT_CLIENT_DB_PASS=$(_generate_password)
    echo -n ${MQTT_CLIENT_DB_PASS} | docker secret create ${MQTT_CLIENT_DB_PASS_SECRET_FILE} -
    echo $"[$(date)] Database user: ${MQTT_CLIENT_DB_USER} password: ${MQTT_CLIENT_DB_PASS}" >>${PLAIN_TEXT_PASS_FILE}

    UNIT_SERVICE_DB_PASS=$(_generate_password)
    echo -n ${UNIT_SERVICE_DB_PASS} | docker secret create ${UNIT_SERVICE_DB_PASS_SECRET_FILE} -
    echo $"[$(date)] Database user: ${UNIT_SERVICE_DB_USER} password: ${UNIT_SERVICE_DB_PASS}" >>${PLAIN_TEXT_PASS_FILE}

    SCHEDULER_SERVICE_DB_PASS=$(_generate_password)
    echo -n ${SCHEDULER_SERVICE_DB_PASS} | docker secret create ${SCHEDULER_SERVICE_DB_PASS_SECRET_FILE} -
    echo $"[$(date)] Database user: ${SCHEDULER_SERVICE_DB_USER} password: ${SCHEDULER_SERVICE_DB_PASS}" >>${PLAIN_TEXT_PASS_FILE}

    REPORTING_SERVICE_DB_PASS=$(_generate_password)
    echo -n ${REPORTING_SERVICE_DB_PASS} | docker secret create ${REPORTING_SERVICE_DB_PASS_SECRET_FILE} -
    echo $"[$(date)] Database user: ${REPORTING_SERVICE_DB_USER} password: ${REPORTING_SERVICE_DB_PASS}" >>${PLAIN_TEXT_PASS_FILE}

    API_GATEWAY_DB_PASS=$(_generate_password)
    echo -n ${API_GATEWAY_DB_PASS} | docker secret create ${API_GATEWAY_DB_PASS_SECRET_FILE} -
    echo $"[$(date)] Database user: ${API_GATEWAY_DB_USER} password: ${API_GATEWAY_DB_PASS}" >>${PLAIN_TEXT_PASS_FILE}
}


_generate_password_hash() {
    local password=$1
    echo -n $(htpasswd -bnBC 10 "" ${password} | tr -d ':\n')
}

_generate_and_save_api_gateway_security_credentials() {
    echo "[$(date)] [SERVICE_INIT] - Generating API Gateway passwords and saving some as Docker secrets"

    API_GATEWAY_SECURITY_PASS_BACKEND=$(_generate_password)
    API_GATEWAY_SECURITY_PASS_BACKEND_HASH=$(_generate_password_hash ${API_GATEWAY_SECURITY_PASS_BACKEND})
    echo -n ${API_GATEWAY_SECURITY_PASS_BACKEND} | docker secret create ${API_GATEWAY_SECURITY_PASS_BACKEND_SECRET_FILE} -
    echo $"[$(date)] API Gateway user: ${API_GATEWAY_SECURITY_USER_BACKEND} password: ${API_GATEWAY_SECURITY_PASS_BACKEND}" >>${PLAIN_TEXT_PASS_FILE}

    API_GATEWAY_SECURITY_PASS_USER=$(_generate_password)
    API_GATEWAY_SECURITY_PASS_USER_HASH=$(_generate_password_hash ${API_GATEWAY_SECURITY_PASS_USER})
    echo $"[$(date)] API Gateway user: ${API_GATEWAY_SECURITY_USER_USER} password: ${API_GATEWAY_SECURITY_PASS_USER}" >>${PLAIN_TEXT_PASS_FILE}

    API_GATEWAY_SECURITY_PASS_ADMIN=$(_generate_password)
    API_GATEWAY_SECURITY_PASS_ADMIN_HASH=$(_generate_password_hash ${API_GATEWAY_SECURITY_PASS_ADMIN})
    echo $"[$(date)] API Gateway user: ${API_GATEWAY_SECURITY_USER_ADMIN} password: ${API_GATEWAY_SECURITY_PASS_ADMIN}" >>${PLAIN_TEXT_PASS_FILE}
}


_initialize_database_with_credentials() {
    echo "[$(date)] [SERVICE_INIT] - Initializing database with credentials"

    envsubst <${DB_INIT_SCRIPT_TEMPLATE} >${DB_INIT_SCRIPT}

    DB_INIT_CONTAINER=$(docker run -d --rm \
        -v ${PWD}/${DB_INIT_SCRIPT}:/docker-entrypoint-initdb.d/${DB_INIT_SCRIPT}:ro \
        -v ${DB_DATA_VOLUME_NAME}:/data/db:rw \
        -v ${DB_CONFIG_VOLUME_NAME}:/data/configdb:rw \
        -e MONGO_INITDB_ROOT_USERNAME=${DB_ROOT_USER} \
        -e MONGO_INITDB_ROOT_PASSWORD=${DB_ROOT_PASS} \
        -e MONGO_INITDB_DATABASE=${DB_USER_DB} \
        ${DB_IMAGE})

    docker container stop ${DB_INIT_CONTAINER}
    rm ${DB_INIT_SCRIPT}
}

set_up_database_with_login_credentials() {
    echo "[$(date)] [SERVICE_INIT] - Database initialization"
    _generate_and_save_db_passwords_for_all_services
    _generate_and_save_api_gateway_security_credentials
    _initialize_database_with_credentials
}


### MQTT BROKER ###

_add_user_to_mqtt_acl_and_save_credentials_to_docker_secrets() {
    # Generate password
    local mqtt_acl_user=$1
    local mqtt_acl_pass=$(_generate_password)
    local mqtt_acl_docker_secret=$2
    # Save user/pass in plain text
    echo "[$(date)] MQTT borker user: ${mqtt_acl_user} password: ${mqtt_acl_pass}" >>${PLAIN_TEXT_PASS_FILE}
    # Add user/pass to ACL
    ./${MQTT_BROKER_PASSWORD_GENERATOR} -b ${MQTT_BROKER_ACL_FILE} ${mqtt_acl_user} ${mqtt_acl_pass}
    # Create Docker secret if the argument is present
    if [[ ${mqtt_acl_docker_secret} ]]; then
    echo -n ${mqtt_acl_pass} | docker secret create ${mqtt_acl_docker_secret} -
    mqtt_acl_docker_secret=''
    fi
}

set_up_mqtt_broker_with_login_credentials() {
    echo "[$(date)] [SERVICE_INIT] - Initializing MQTT broker with credentials"
    # Create volume
    docker volume create ${MQTT_BROKER_VOLUME_NAME}
    # Create directories
    local_mosquitto_folder=${PWD}/mosquitto
    mkdir -p ${local_mosquitto_folder}/config \
    ${local_mosquitto_folder}/data \
    ${local_mosquitto_folder}/auth
    # Generate ACL passwords
    touch ${MQTT_BROKER_ACL_FILE}
    _add_user_to_mqtt_acl_and_save_credentials_to_docker_secrets ${MQTT_CLIENT_MQTT_BROKER_USER} ${MQTT_CLIENT_MQTT_BROKER_PASS_SECRET_FILE}
    _add_user_to_mqtt_acl_and_save_credentials_to_docker_secrets ${MCU_MQTT_BROKER_USER}
    # Fill in the config file template
    envsubst <${MQTT_BROKER_CONF_TEMPLATE} >${MQTT_BROKER_CONF}
    # Copy the config and ACL to the volume
    mv ${MQTT_BROKER_ACL_FILE} ${local_mosquitto_folder}/auth/
    mv ${MQTT_BROKER_CONF} ${local_mosquitto_folder}/config/
    # Copy to volume and set directory privileges to the 1883 group (required by the official Docker image)
    docker run --rm -ti \
    -v ${local_mosquitto_folder}:/local \
    -v ${MQTT_BROKER_VOLUME_NAME}:/volume \
    alpine:latest \
    sh -c 'cp -rfp /local/* /volume; \
          chmod -R 770 /volume; \
          chown -R root:1883 /volume'
    rm -rf ${local_mosquitto_folder}
}


########################################################################################################################
# STACK_DEPLOY
########################################################################################################################

deploy_services_docker_stack() {
  echo "[$(date)] [STACK_DEPLOY] - Deploying service stack"
  envsubst <${STACK_DEPLOY_YML_TEMPLATE} >${STACK_DEPLOY_YML}
  docker stack deploy -c ${STACK_DEPLOY_YML} --with-registry-auth ${PROJECT_NAME}
  rm ${STACK_DEPLOY_YML}
}

########################################################################################################################
# RUN_CONFIGURATIONS
########################################################################################################################

install_to_existing_docker_swarm_cluster() {
  ensure_run_dependencies
  open_firewall_ports_on_current_host
  set_up_database_with_login_credentials
  set_up_mqtt_broker_with_login_credentials
  deploy_services_docker_stack
}
export -f install_to_existing_docker_swarm_cluster

install_to_clean_environment() {
  ensure_run_dependencies
  open_firewall_ports_on_current_host
  add_current_usert_to_docker_group
  install_docker
  initialize_docker_swarm
  log_in_to_project_docker_repositories
  set_up_database_with_login_credentials
  set_up_mqtt_broker_with_login_credentials
  deploy_services_docker_stack
}
export -f install_to_clean_environment

uninstall_complete_project_and_dependencies_UNSAFE() {
  remove_run_dependencies
  delete_firewall_port_rules_on_current_host
  remove_services_docker_stack
  delete_docker_volumes_for_services
  delete_docker_secrets_for_services
  uninstall_docker
  remove_current_usert_from_docker_group_and_delete_group
}
export -f uninstall_complete_project_and_dependencies_UNSAFE

uninstall_project_SAFE() {
  delete_firewall_port_rules_on_current_host
  remove_services_docker_stack
  delete_docker_volumes_for_services
  delete_docker_secrets_for_services
}
export -f uninstall_project_SAFE

redeploy_services_docker_stack() {
  deploy_services_docker_stack
}
export -f redeploy_services_docker_stack
