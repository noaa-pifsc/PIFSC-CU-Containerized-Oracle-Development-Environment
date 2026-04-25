#!/bin/bash

# function that begins the container deployment process on a given container host with an unprivileged account
# This function accepts no parameters
function proj_host_deploy_container()
{
#	echo "running proj_host_deploy_container()"

	if ! cds_shared_validate_required_vars "PRIV_USER" "HOST_SOURCE_PATH" "SECRET_DATA_VAR_NAME" "COMPOSE_FILE" "SECRET_MAPPING_VAR_NAME" "BUILD_PATH"; then 
        echo "Error: ${FUNCNAME[0]}() function argument validation failed" >&2
        return 1
    fi

	# declare the function arguments as a local variable
	local -A func_args=(
			["target_user"]="${PRIV_USER}" 
			["source_path"]="${HOST_SOURCE_PATH}"
			["secret_var"]="${SECRET_DATA_VAR_NAME}"
			["deploy_script_path"]="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../host_deploy_CODE_elev_privs.sh"
			["env_block"]="$(cds_shared_generate_export_env_vars_block "COMPOSE_PROJECT_NAME" "DB_HOST_PORT" "ORDS_HOST_PORT" "DB_IMAGE" "ORDS_IMAGE" "TARGET_APEX_VERSION" "APP_SCHEMA_NAME" "COMPOSE_FILE" "STACK_NAME" "NETWORK_NAME")"
			["secret_map"]="${SECRET_MAPPING_VAR_NAME}"
			["process_secrets"]="yes"
			["persistent_container"]="yes"
		)
		
#	echo "the value of the arguments for ${FUNCNAME[0]}() are: $(cds_shared_dump_array_vals "func_args")"

	# initialize and build/run the container on the host machine with the specified function arguments:
	cds_host_deploy_container "func_args"	
}

# function that executes the container deployment process on a given container host with a privileged account
# This function accepts no parameters
function proj_host_deploy_container_elev_privs()
{
#	echo "running proj_host_deploy_container_elev_privs()"
	if ! cds_shared_validate_required_vars "COMPOSE_FILE" "SECRET_MAPPING_VAR_NAME" "BUILD_PATH" "STACK_NAME" "NETWORK_NAME" "COMPOSE_PROJECT_NAME"; then 
        echo "Error: ${FUNCNAME[0]}() function argument validation failed" >&2
        return 1
    fi

	# declare the function arguments
	local -A host_deploy_stack_args=(
			["stack_name"]="${STACK_NAME}"
			["secret_map"]="${SECRET_MAPPING_VAR_NAME}"
			["network_name"]="${NETWORK_NAME}"
			["deploy_dest"]="server"
			["build_image"]="yes"
			["compose_path"]="${COMPOSE_FILE}"
			["build_path"]="${BUILD_PATH}"
			["secret_name_prefix"]="${COMPOSE_PROJECT_NAME}_"
		)

	echo "The argument array is: $(cds_shared_dump_array_vals "host_deploy_stack_args")"

	# export the database connection environment variables used directly in the docker compose files:
	cds_shared_export_env_vars "DBPORT" "DBHOST" "DBSERVICENAME"

	# execute the secret definitions and the container build/run process on the target folder using a privileged account
	cds_shared_deploy_container_stack "host_deploy_stack_args"

	echo "The containers have been started"
}


# function that shuts down the CODE containers on a given container host with an unprivileged account
# This function accepts no parameters
function proj_host_shutdown_container()
{
#	echo "running ${FUNCNAME[0]}()"

	if ! cds_shared_validate_required_vars "PRIV_USER" "HOST_SOURCE_PATH" "SECRET_DATA_VAR_NAME" "COMPOSE_FILE" "SECRET_MAPPING_VAR_NAME" "BUILD_PATH"; then 
        echo "Error: ${FUNCNAME[0]}() function argument validation failed" >&2
        return 1
    fi

	# declare the function arguments as a local variable
	local -A func_args=(
			["target_user"]="${PRIV_USER}" 
			["source_path"]="${HOST_SOURCE_PATH}"
			["secret_var"]="${SECRET_DATA_VAR_NAME}"
			["deploy_script_path"]="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../host_shutdown_CODE_elev_privs.sh"
			["env_block"]="$(cds_shared_generate_export_env_vars_block "COMPOSE_PROJECT_NAME" "DB_HOST_PORT" "ORDS_HOST_PORT" "DB_IMAGE" "ORDS_IMAGE" "TARGET_APEX_VERSION" "APP_SCHEMA_NAME" "COMPOSE_FILE" "REM_VOL" "STACK_NAME" "NETWORK_NAME")"
			["secret_map"]="${SECRET_MAPPING_VAR_NAME}"
			["process_secrets"]="no"
			["persistent_container"]="yes"
		)

#	echo "the value of the arguments for ${FUNCNAME[0]}() are: $(cds_shared_dump_array_vals "func_args")"

	# initialize and build/run the container on the host machine with the specified function arguments:
	cds_host_deploy_container "func_args"	
}

# function that executes the container shutdown process on a given container host with a privileged account
# This function accepts no parameters
function proj_host_shutdown_container_elev_privs()
{
#	echo "running proj_host_shutdown_container_elev_privs()"
	if ! cds_shared_validate_required_vars "COMPOSE_FILE" "BUILD_PATH" "REM_VOL"; then 
        echo "Error: ${FUNCNAME[0]}() function argument validation failed" >&2
        return 1
    fi

	# export the environment variables used directly in the docker compose files:
	cds_shared_export_env_vars "DBPORT" "DBHOST" "DBSERVICENAME"

	# shutdown the CODE containers to the host server
	proj_shared_shutdown_CODE_containers "${BUILD_PATH}" "${COMPOSE_FILE}" "${REM_VOL}"

	echo "The containers have been shutdown"
}