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
			["env_block"]="$(cds_shared_generate_export_env_vars_block "DB_IMAGE" "DB_HOST_PORT" "DBPORT" "ORACLE_PWD" "DBHOST" "DBSERVICENAME" "TARGET_APEX_VERSION" "APP_SCHEMA_NAME" "ORDS_IMAGE" "COMPOSE_FILE" "COMPOSE_PROJECT_NAME" "ORDS_HOST_PORT")"
			["secret_map"]="${SECRET_MAPPING_VAR_NAME}"
			["process_secrets"]="yes"
			["persistent_container"]="yes"
		)

	# initialize and build/run the container on the host machine with the specified function arguments:
	cds_host_deploy_container "func_args"	
}

# function that executes the container deployment process on a given container host with a privileged account
# This function accepts no parameters
function proj_host_deploy_container_elev_privs()
{
#	echo "running proj_host_deploy_container_elev_privs()"
	if ! cds_shared_validate_required_vars "COMPOSE_FILE" "SECRET_DATA_VAR_NAME" "SECRET_MAPPING_VAR_NAME" "BUILD_PATH"; then 
        echo "Error: ${FUNCNAME[0]}() function argument validation failed" >&2
        return 1
    fi

	# process the stdin configuration data: parse and store in variables, construct the formatted variable identified by $SECRET_DATA_VAR_NAME
	cds_host_process_stdin_secret_data "${SECRET_MAPPING_VAR_NAME}" "${SECRET_DATA_VAR_NAME}"

	# deploy the CODE containers to the host server
	proj_deploy_CODE_containers "${BUILD_PATH}" "${COMPOSE_FILE}"

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
			["env_block"]="$(cds_shared_generate_export_env_vars_block "DB_IMAGE" "DB_HOST_PORT" "DBPORT" "ORACLE_PWD" "DBHOST" "DBSERVICENAME" "TARGET_APEX_VERSION" "APP_SCHEMA_NAME" "ORDS_IMAGE" "COMPOSE_FILE" "COMPOSE_PROJECT_NAME" "ORDS_HOST_PORT" "REM_VOL")"
			["secret_map"]="${SECRET_MAPPING_VAR_NAME}"
			["process_secrets"]="no"
			["persistent_container"]="yes"
		)

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

	# shutdown the CODE containers to the host server
	proj_host_shutdown_CODE_containers "${BUILD_PATH}" "${COMPOSE_FILE}" "${REM_VOL}"

	echo "The containers have been started"
}