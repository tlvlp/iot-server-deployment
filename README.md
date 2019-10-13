# IoT Server Deployment

## Project
Part of the [tlvlp IoT project](https://github.com/tlvlp/iot-project-summary)'s server side microservices.

## Scope of this repository
- Provides a selection of scripts to install, initialize and (re)deploy services as well as removing them.
- Single source for most of the configuration values for all the microservices in the project.

## Configuration and Deployment steps:
1. Obtain TLS certificates. 
    - The project is currently configured to use the free certificates provided by 
    [Let's Encrypt](https://letsencrypt.org/)'s Certbot.
    
    - Configure the root folder of the certificates at the [config.sh](config.sh) under the TLS_LETSENCRYPT_PARENT_LOCATION 
    variable. If it will be pointing to an externally created docker volume, then the volume should also be added to the 
    [docker-compose-services-TEMPLATE.yml](config/docker-compose-services-TEMPLATE.yml) both under the volumes and at every 
    service that uses the above variable.
    
    - Generate a pk12 keystore from the pem output (eg. with openssl). Store it with the other certificates and create a Docker Secret
    with the keystore password. Store the secret's name at the [config.sh](config.sh) under the 
    TLS_KEYSTORE_PASSWORD_SECRET_FILE variable.
    
3. Optionally configure ports at the [config.sh](config.sh) to avoid collisions on your server. 
Most ports are only used internally and these are the exposed ones:

    | Port (variable name) | Security | Description|
    | :--- | :--- | :--- |
    | MQTT_BROKER_PORT_TLS | TLS | MQTT communication for all MCUs |
    | API_GATEWAY_PORT | None | API gateway access for the internal services |
    | API_GATEWAY_PORT_TLS | TLS | API gateway access for external users |
    | PORTAL_PORT | In progress | Portal access |

3. Select and run a deployment script from the Deployment scripts section.

## Deployment scripts
>**Notes:**
>
> - Almost all scripts require(will request) sudo privileges.
>
> - The scripts assumes(assures in case of clean install) that the current user is in the docker group. This might be a 
> security risk in some cases.
>
> - Currently some parts of the setup assume a single-node Docker Swarm "cluster", using simple volume drivers, a singe 
>database instance etc.

[redeploy_services_docker_stack.sh](redeploy_services_docker_stack.sh): 
- Redeploys the Docker Swarm Stack from the docker compose template. 
- Ideal for rolling out changes to the services, modifying the number of instances for each service 
changing, ports, secrets, etc.

[install_to_clean_environment.sh](install_to_clean_environment.sh):
- Installs all project dependencies including Docker, opens ports, initializes and deploys the services.
- Generates and shares separate database access for all services.
- Generates and shares MCU and MQTT Client access to the MQTT broker
- Requires a clean environment without Docker or any of the project artifacts installed.

[install_to_existing_docker_swarm_cluster_SAFE.sh](install_to_existing_docker_swarm_cluster_SAFE.sh):
- Opens ports, initializes and deploys the services.
- Generates and shares separate database access for all services.
- Generates and shares MCU and MQTT Client access to the MQTT broker
- Requires a Docker Swarm cluster to be set up.
- Any resources left over from a previous installation (secrets, volumes) might cause problems.

[uninstall_complete_project_and_dependencies_UNSAFE.sh](uninstall_complete_project_and_dependencies_UNSAFE.sh):
- Might have severe side-effects if other Docker services are running on the same host.
- Will result in a complete data loss!
- Removes the Docker Swarm cluster with all related resources including **volumes** and secrets.
- Closes ports, uninstalls all project dependencies **including Docker!**.

[uninstall_project_SAFE.sh](uninstall_project_SAFE.sh):
- Will result in a complete data loss!
- Removes the Docker Swarm cluster with all related resources and closes the ports opened for the services.

[main.sh](main.sh):
- Contains all the logic for the other scripts.
- The operations are organized into clearly named groups (at the end of the script) to make custom.
- Used via bash import, not directly runnable.


## Configuration files
> **Templates**: Since the yml format only supports the use of environment variables for values but not for keys
some of the files have "-TEMPLATE" in their names and contain variable references even at odd places.
The actual deployment files are generated from these templates during deployment.

[config.sh](config.sh):
- Contains most of the configuration parameters for the services.
- Exposes all parameters as environment variables that are picked up by the containers during every (re)deployment
- Used via bash import, not directly runnable.

[docker-compose-services-TEMPLATE.yml](config/docker-compose-services-TEMPLATE.yml):
- Contains the complete structure of the Docker Swarm Stack.

[mongo-database-access-rights-TEMPLATE.js](config/mongo-database-access-rights-TEMPLATE.js):
- JS script to initialize database access rights for each service. 
- Only runs during the installation.
- Outside of the installation access rights will have to be modified manually if need be.

[mosquitto.conf-TEMPLATE](config/mosquitto.conf-TEMPLATE]):
- Configuration file for the MQTT Broker

[mosquitto_passwd](config/mosquitto_passwd):
- Used to generate
- Copied over from the [Mosquitto repository](https://github.com/eclipse/mosquitto) to make password generation easier.

[passwords-DELETE_AFTER_SAVING](passwords-DELETE_AFTER_SAVING):
- Created during installation
- Holds all the generated login credentials for the database, MQTT broker, API gateway
- Should not be left on the server :)


