#!/usr/bin/env bash

########################################################################################################################
# TEMPLATES AND TEMPORARY FILES
########################################################################################################################

export MQTT_BROKER_CONF_TEMPLATE=config/mosquitto.conf-TEMPLATE
export MQTT_BROKER_CONF=config/mosquitto.conf
export MQTT_BROKER_PASSWORD_GENERATOR=config/mosquitto_passwd
export MQTT_BROKER_DEPLOY_YML=config/docker-compose-mqtt-broker.yml
export MQTT_BROKER_DEPLOY_YML_TEMPLATE=config/docker-compose-mqtt-broker-TEMPLATE.yml
export STACK_DEPLOY_YML=config/docker-compose-services.yml
export STACK_DEPLOY_YML_TEMPLATE=config/docker-compose-services-TEMPLATE.yml
export DB_INIT_SCRIPT_TEMPLATE=config/mongo-database-access-rights-TEMPLATE.js
export DB_INIT_SCRIPT=mongo-database-access-rights.js
export PLAIN_TEXT_PASS_FILE=passwords-DELETE_AFTER_SAVING

########################################################################################################################
# PROJECT
########################################################################################################################

# Project name used throughout the services
export PROJECT_NAME=tlvlp-iot

# TLS
export TLS_LETSENCRYPT_PARENT_LOCATION=/etc
export TLS_CERT_PATH_INSIDE_THE_CONTAINER=/tls/letsencrypt/live/tlvlp.com-0001
export TLS_KEYSTORE_PASSWORD_SECRET_FILE=tls-keystore-pass
export API_GATEWAY_TLS_ON=true
export API_GATEWAY_TLS_KEYSTORE_TYPE=PKCS12
export API_GATEWAY_TLS_KEY_ALIAS=tomcat

# Docker
export DOCKER_PROJECT_REPO=tlvlp
export DOCKER_SECRETS_FOLDER=/run/secrets

# Spring
export SPRING_ACTIVE_PROFILE=prod
export SPRING_LOG_LEVEL=INFO
export SPRING_LOG_PATTERN='%d{yyyy-MMM-dd HH:mm:ss.SSS} %-5level [%thread] %logger{15} - %msg%n'

# MCU
export MCU_MQTT_BROKER_USER=tlvlp-iot-mcu
export MCU_MQTT_TOPIC_GLOBAL_STATUS_REQUEST=/global/status_request
export MCU_MQTT_TOPIC_GLOBAL_STATUS=/global/status
export MCU_MQTT_TOPIC_GLOBAL_ERROR=/global/error
export MCU_MQTT_TOPIC_GLOBAL_INACTIVE=/global/inactive


########################################################################################################################
# SERVICES
########################################################################################################################

#############################
# Database
#############################
export DB_IMAGE=mongo:4.1-bionic
export DB_NUMBER_OF_REPLICAS=1
export DB_SERVICE_NAME=mongo-db
export DB_PORT_INTERNAL=27017
export DB_PORT_EXTERNAL=27027
export DB_USER_DB=admin
export DB_ROOT_USER=root
export DB_ROOT_PASS="PLACEHOLDER - SET IN THE MAIN.SH"
export DB_DATA_VOLUME_NAME=${PROJECT_NAME}_${DB_SERVICE_NAME}_data_volume
export DB_CONFIG_VOLUME_NAME=${PROJECT_NAME}_${DB_SERVICE_NAME}_config_volume

#############################
# MQTT Broker
#############################
export MQTT_BROKER_IMAGE=eclipse-mosquitto:1.6
export MQTT_BROKER_NUMBER_OF_REPLICAS=1
export MQTT_BROKER_SERVICE_NAME=mqtt-broker
export MQTT_BROKER_PORT_INTERNAL=1883
export MQTT_BROKER_PORT_TLS=8883
export MQTT_BROKER_ACL_FILE=passwords
export MQTT_BROKER_VOLUME_NAME=${PROJECT_NAME}_${MQTT_BROKER_SERVICE_NAME}_volume
export MQTT_BROKER_NETWORK_NAME=${PROJECT_NAME}_${MQTT_BROKER_SERVICE_NAME}_network

#############################
# MQTT Client service
#############################
export MQTT_CLIENT_IMAGE=${DOCKER_PROJECT_REPO}/iot-mqtt-client:latest
export MQTT_CLIENT_NUMBER_OF_REPLICAS=1
export MQTT_CLIENT_SERVICE_NAME=mqtt-client
export MQTT_CLIENT_SERVICE_PORT=8100
export MQTT_CLIENT_DEFAULT_QOS=2
export MQTT_CLIENT_BROKER_URI=tcp://${MQTT_BROKER_SERVICE_NAME}:${MQTT_BROKER_PORT_INTERNAL}
export MQTT_CLIENT_TOPIC_SUBSCRIPTIONS_CSV=${MCU_MQTT_TOPIC_GLOBAL_STATUS},${MCU_MQTT_TOPIC_GLOBAL_INACTIVE},${MCU_MQTT_TOPIC_GLOBAL_ERROR}

export MQTT_CLIENT_DB=mqtt-client
export MQTT_CLIENT_DB_USER=mqtt-client
export MQTT_CLIENT_DB_PASS="PLACEHOLDER - SET IN THE MAIN.SH"
export MQTT_CLIENT_DB_PASS_SECRET_FILE=${PROJECT_NAME}_${MQTT_CLIENT_SERVICE_NAME}_db_pass
export MQTT_CLIENT_MQTT_BROKER_USER=${PROJECT_NAME}_${MQTT_CLIENT_SERVICE_NAME}
export MQTT_CLIENT_MQTT_BROKER_PASS_SECRET_FILE=${PROJECT_NAME}_${MQTT_CLIENT_SERVICE_NAME}_mqtt_broker_pass

export MQTT_CLIENT_API_OUTGOING_MESSAGE=/messages

#############################
# Unit service
#############################
export UNIT_SERVICE_IMAGE=${DOCKER_PROJECT_REPO}/iot-unit-service:latest
export UNIT_SERVICE_NUMBER_OF_REPLICAS=1
export UNIT_SERVICE_NAME=unit-service
export UNIT_SERVICE_PORT=8200

export UNIT_SERVICE_DB=unit-service
export UNIT_SERVICE_DB_USER=unit-service
export UNIT_SERVICE_DB_PASS="PLACEHOLDER - SET IN THE MAIN.SH"
export UNIT_SERVICE_DB_PASS_SECRET_FILE=${PROJECT_NAME}_${UNIT_SERVICE_NAME}_db_pass

export UNIT_SERVICE_API_INCOMING_MESSAGE=/messages
export UNIT_SERVICE_API_LIST_ALL_UNIT=/units
export UNIT_SERVICE_API_GET_UNIT_BY_ID=/units/id
export UNIT_SERVICE_API_REQUEST_GLOBAL_STATUS=/units/request
export UNIT_SERVICE_API_MODULE_CONTROL=/units/module-control
export UNIT_SERVICE_API_ADD_SCHEDULED_EVENT=/units/events/add
export UNIT_SERVICE_API_DELETE_SCHEDULED_EVENT=/units/events/delete
export UNIT_SERVICE_API_GET_UNIT_LOGS=/units/logs

#############################
# Scheduler service
#############################
export SCHEDULER_SERVICE_IMAGE=${DOCKER_PROJECT_REPO}/iot-scheduler-service:latest
export SCHEDULER_SERVICE_NUMBER_OF_REPLICAS=1
export SCHEDULER_SERVICE_NAME=scheduler-service
export SCHEDULER_SERVICE_PORT=8300

export SCHEDULER_SERVICE_DB=scheduler-service
export SCHEDULER_SERVICE_DB_USER=scheduler-service
export SCHEDULER_SERVICE_DB_PASS="PLACEHOLDER - SET IN THE MAIN.SH"
export SCHEDULER_SERVICE_DB_PASS_SECRET_FILE=${PROJECT_NAME}_${SCHEDULER_SERVICE_NAME}_db_pass

export SCHEDULER_SERVICE_API_GET_EVENTS_FROM_LIST=/events/fromlist
export SCHEDULER_SERVICE_API_POST_MQTT_MESSAGE_SEND_EVENT=/events/mqtt
export SCHEDULER_SERVICE_API_DELETE_EVENT=/events/delete

#############################
# Reporting service
#############################
export REPORTING_SERVICE_IMAGE=${DOCKER_PROJECT_REPO}/iot-reporting-service:latest
export REPORTING_SERVICE_NUMBER_OF_REPLICAS=1
export REPORTING_SERVICE_NAME=reporting-service
export REPORTING_SERVICE_PORT=8400

export REPORTING_SERVICE_DB=reporting-service
export REPORTING_SERVICE_DB_USER=reporting-service
export REPORTING_SERVICE_DB_PASS="PLACEHOLDER - SET IN THE MAIN.SH"
export REPORTING_SERVICE_DB_PASS_SECRET_FILE=${PROJECT_NAME}_${REPORTING_SERVICE_NAME}_db_pass

export REPORTING_SERVICE_API_GET_AVERAGES=/values/averages
export REPORTING_SERVICE_API_POST_VALUES=/values

#############################
# API gateway
#############################

export API_GATEWAY_IMAGE=${DOCKER_PROJECT_REPO}/iot-api-gateway:latest
export API_GATEWAY_NUMBER_OF_REPLICAS=1
export API_GATEWAY_NAME=api-gateway
export API_GATEWAY_PORT=8500
export API_GATEWAY_PORT_TLS=8544
# TLS Related variables are at the top of the config with the other TLS options.

export API_GATEWAY_DB=api-gateway
export API_GATEWAY_DB_USER=api-gateway
export API_GATEWAY_DB_PASS="PLACEHOLDER - SET IN THE MAIN.SH"
export API_GATEWAY_DB_PASS_SECRET_FILE=${PROJECT_NAME}_${API_GATEWAY_NAME}_db_pass

export API_GATEWAY_SECURITY_USER_BACKEND="backend"
export API_GATEWAY_SECURITY_PASS_BACKEND="PLACEHOLDER - SET IN THE MAIN.SH"
export API_GATEWAY_SECURITY_PASS_BACKEND_HASH="PLACEHOLDER - SET IN THE MAIN.SH"
export API_GATEWAY_SECURITY_PASS_BACKEND_SECRET_FILE=${PROJECT_NAME}_${API_GATEWAY_NAME}_backend_pass
export API_GATEWAY_SECURITY_USER_USER="user"
export API_GATEWAY_SECURITY_PASS_USER="PLACEHOLDER - SET IN THE MAIN.SH"
export API_GATEWAY_SECURITY_PASS_USER_HASH="PLACEHOLDER - SET IN THE MAIN.SH"
export API_GATEWAY_SECURITY_USER_ADMIN="admin"
export API_GATEWAY_SECURITY_PASS_ADMIN="PLACEHOLDER - SET IN THE MAIN.SH"
export API_GATEWAY_SECURITY_PASS_ADMIN_HASH="PLACEHOLDER - SET IN THE MAIN.SH"

export API_GATEWAY_API_INCOMING_MQTT_MESSAGE=/backend/mqtt/incoming
export API_GATEWAY_API_OUTGOING_MQTT_MESSAGE=/backend/mqtt/outgoing
export API_GATEWAY_API_GET_ALL_UNITS=/units
export API_GATEWAY_API_GET_UNIT_BY_ID=/units/id
export API_GATEWAY_API_GET_UNIT_BY_ID_WITH_SCHEDULES_AND_LOGS=/units/collected
export API_GATEWAY_API_REQUEST_GLOBAL_UNIT_STATUS=/units/request
export API_GATEWAY_API_UNIT_MODULE_CONTROL=/units/modules/control
export API_GATEWAY_API_ADD_SCHEDULED_EVENT_TO_UNIT=/units/events/add
export API_GATEWAY_API_DELETE_SCHEDULED_EVENT_FROM_UNIT=/units/events/delete
export API_GATEWAY_API_GET_REPORTS_FOR_UNIT_MODULE=/units/modules/report
export API_GATEWAY_API_GET_ALL_USERS=/users/admin/all
export API_GATEWAY_API_SAVE_USER=/users/admin/save
export API_GATEWAY_API_DELETE_USER=/users/admin/delete
export API_GATEWAY_API_GET_ROLES=/users/admin/roles
export API_GATEWAY_API_AUTHENTICATE_USER=/users/auth

#############################
# Portal
#############################
export PORTAL_IMAGE=${DOCKER_PROJECT_REPO}/iot-portal:latest
export PORTAL_NUMBER_OF_REPLICAS=1
export PORTAL_NAME=portal
export PORTAL_PORT=8600
