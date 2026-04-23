#!/bin/bash

#-----------------------------------------------------------------------------
# shared_functions.sh:
# this file defines shared functions that are used for this specific 
# container application for container deployments
#-----------------------------------------------------------------------------

# function to deploy the CODE containers
# the function accepts the following parameters:
# 1: the build path for the container
# 2: the formatted list of container compose files 
function proj_deploy_CODE_containers ()
{
	local build_path="${1}"
	local compose_file="${2}"

	if ! cds_shared_validate_required_vars "build_path" "compose_file"; then 
        echo "Error: ${FUNCNAME[0]}() function argument validation failed" >&2
        return 1
    fi

	# change to the designated build path so the containers can be stopped (if running) and started
	cd "${build_path}"

	# declare COMPOSE_FILE as an environment variable
	export COMPOSE_FILE="${compose_file}"

	# export ORACLE_PWD and COMPOSE_PROJECT_NAME so they can be used for the code-db and code-ords containers
	export ORACLE_PWD
	export COMPOSE_PROJECT_NAME

	# remove the containers if they are already running using the injected COMPOSE_FILE
	docker compose down

	# Execute natively for local Desktop Deployments using the injected COMPOSE_FILE
	docker compose up -d --build

	# unset the ORACLE_PWD secret value
	unset ORACLE_PWD
}



# function to shutdown the CODE containers
# 1: the build path for the container
# 2: the formatted list of container compose files 
# 3: remove volume flag (yes, no)
function proj_host_shutdown_CODE_containers ()
{
	local build_path="${1}"
	local compose_file="${2}"
	local rem_vol="${3}"

	if ! cds_shared_validate_required_vars "build_path" "compose_file" "rem_vol"; then 
        echo "Error: ${FUNCNAME[0]}() function argument validation failed" >&2
        return 1
    fi

	# change to the designated build path so the containers can be stopped (if running) and started
	cd "${build_path}"

	if [ "${rem_vol}" == "yes" ]; then
		echo "The rem_vol flag was yes, delete the volumes"
	
		local vol_flag_arg="-v"
	else
		echo "The rem_vol flag was no, do not delete the volumes"
		local vol_flag_arg=""
	fi

	# declare COMPOSE_FILE as an environment variable
	export COMPOSE_FILE="${compose_file}"
	export COMPOSE_PROJECT_NAME

	# remove the containers if they are already running using the injected COMPOSE_FILE
	docker compose down "${vol_flag_arg}"
}
