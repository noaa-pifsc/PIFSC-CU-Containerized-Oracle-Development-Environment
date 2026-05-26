#! /bin/bash

# define a list of configuration variables that drive the behavior of the container deployment scripts, this is intended to run last after all other .sh configuration files

##### Container Host Configuration Variables: #####

	# define the host's source root path
	HOST_SOURCE_PATH="/tmp/${COMPOSE_PROJECT_NAME}"

	# define the path to the folder where the host bash scripts are contained
	HOST_SCRIPTS_PATH="${HOST_SOURCE_PATH}/core/scripts/host_scripts"

	# define the name of the container stack
	STACK_NAME="${COMPOSE_PROJECT_NAME}_stack"

	# define the name of the container network
	NETWORK_NAME="${STACK_NAME}_oracle-net"