#! /bin/bash

# define a list of configuration variables that drive the behavior of the container deployment scripts, this is intended to run last after all other .sh configuration files

##### Container Host Configuration Variables: #####

	# define the host's source root path
	declare HOST_SOURCE_PATH="/tmp/${COMPOSE_PROJECT_NAME}"

	# define the path to the folder where the host bash scripts are contained
	declare HOST_SCRIPTS_PATH="${HOST_SOURCE_PATH}/containerized_oracle_development_environment/deployment_scripts/host_scripts"
