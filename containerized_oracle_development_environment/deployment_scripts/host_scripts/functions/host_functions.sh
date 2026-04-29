#!/bin/bash

# function that prepares the specified script action (deploy or shutdown) for execution on a given container host with an unprivileged account
# This function accepts no parameters
function proj_host_execute_container_scripts()
{
#	echo "running proj_host_execute_container_scripts()"

	if ! cds_shared_validate_required_vars "PRIV_USER" "HOST_SOURCE_PATH" "SECRET_DATA_VAR_NAME" "COMPOSE_FILE" "SECRET_MAPPING_VAR_NAME" "BUILD_PATH"; then 
        echo "Error: ${FUNCNAME[0]}() function argument validation failed" >&2
        return 1
    fi

	# assign the value of the process_secrets variable based on the script action value
	if [[ "${SCRIPT_ACTION}" == "deploy" ]]; then
		local process_secrets="yes"
	else
		local process_secrets="no"
	fi

	# declare the function arguments as a local variable
	local -A func_args=(
			["target_user"]="${PRIV_USER}" 
			["source_path"]="${HOST_SOURCE_PATH}"
			["secret_var"]="${SECRET_DATA_VAR_NAME}"
			["deploy_script_path"]="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../host_execute_CODE_scripts_elev_privs.sh"
			["env_block"]="$(cds_shared_generate_export_env_vars_block "COMPOSE_PROJECT_NAME" "DB_HOST_PORT" "ORDS_HOST_PORT" "DB_IMAGE" "ORDS_IMAGE" "TARGET_APEX_VERSION" "APP_SCHEMA_NAME" "COMPOSE_FILE" "STACK_NAME" "NETWORK_NAME" "REM_VOL" "SCRIPT_ACTION")"
			["secret_map"]="${SECRET_MAPPING_VAR_NAME}"
			["process_secrets"]="${process_secrets}"
			["persistent_container"]="yes"
		)
		
	# initialize and execute the specified script action on the host machine with the specified function arguments:
	cds_host_deploy_container "func_args"	
}

# function that executes the specified script action (deploy or shutdown) on a given container host with a privileged account
# This function accepts no parameters
function proj_host_execute_container_scripts_elev_privs()
{
#	echo "running proj_host_execute_container_scripts_elev_privs()"
	if ! cds_shared_validate_required_vars "COMPOSE_FILE" "SECRET_MAPPING_VAR_NAME" "BUILD_PATH" "STACK_NAME" "NETWORK_NAME" "COMPOSE_PROJECT_NAME"; then 
        echo "Error: ${FUNCNAME[0]}() function argument validation failed" >&2
        return 1
    fi

	# export the database connection environment variables used directly in the docker compose files:
	cds_shared_export_env_vars "DBPORT" "DBHOST" "DBSERVICENAME"

	# check the specified script action
	if [[ "${SCRIPT_ACTION}" == "deploy" ]]; then 
		# this is a deployment action
		
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
				["rem_vol"]="${REM_VOL}"
			)

		echo "The argument array is: $(cds_shared_dump_array_vals "host_deploy_stack_args")"

		# execute the secret definitions and the container build/run process on the target folder using a privileged account
		cds_shared_deploy_container_stack "host_deploy_stack_args"
	else
		# this is a shutdown action
		
		# shutdown the CODE containers to the host server associated with the $STACK_NAME
		cds_shared_remove_container_stack "${STACK_NAME}" "${NETWORK_NAME}" "${REM_VOL}"
	fi

	echo "The container script action has been completed"
}