#!/bin/bash

# function that deploys the containers for a dev environment
# the function accepts the following arguments:
# 1: passed env_name value (dev, test)
# 2: passed deploy_dest: deployment destination value (local, server)
# 3: rem_vol flag: (optional) remove the volumes associated with the docker stack name (yes) or retain them (no). This defaults to "no"
function proj_client_deploy_container ()
{
	local env_var_name="env_name"
	local dest_var_name="deploy_dest"
	local rem_vol_var_name="rem_vol"
	local passed_env_value="${1:-}"
	local passed_deploy_value="${2:-}"
	local passed_rem_vol_value="${3:-no}"
	
 	echo "running proj_client_deploy_container(${1}, ${2}, ${3})"
	
	# validate the bash variable values
	if ! cds_shared_validate_required_vars	"env_var_name" "dest_var_name"; then
		echo "Error: ${FUNCNAME[0]}() function required function argument validation failed" >&2
		return 1
	fi

	# save/prompt for environment name into the specified local variable
	cds_client_set_env_name_var "${env_var_name}" "${passed_env_value}" 

	# save/prompt for deployment destination (local, server) for Dual-Target capability
	cds_client_set_deploy_dest_var "${dest_var_name}" "${passed_deploy_value}"

	# save/prompt for remove volume flag (yes, no)
	cds_client_set_rem_vol_var "${rem_vol_var_name}" "${passed_rem_vol_value}"

	# notify the user of the user-defined runtime value
	echo "Runtime Argument Values:"
	echo "env_name: ${!env_var_name}"
	echo "deploy_dest: ${!dest_var_name}"
	echo "rem_vol: ${!rem_vol_var_name}"


	# build/deploy the CODE container with the environment 
	proj_client_build_deploy_dev_environment "${!env_var_name}" "${!dest_var_name}" "${!rem_vol_var_name}"

	# notify the user that the container has finished executing
	echo "The docker container has been deployed - environment name: ${!env_var_name}, deployment destination: ${!dest_var_name}"
}


# function that deploys the containers for a development environment
# the function accepts the following arguments:
# 1: environment name (dev, test)
# 2: deploy destination (local, server)
# 3: rem_vol flag: (optional) remove the volumes associated with the docker stack name (yes) or retain them (no). This defaults to "no"
function proj_client_build_deploy_dev_environment ()
{
	# build the list of compose files:
	local env_name="${1}"
	local deploy_dest="${2}"
	local rem_vol="${3:-no}"
	
	# validate the bash variable values
	if ! cds_shared_validate_required_vars "env_name" "deploy_dest" "BUILD_PATH" "ORDS_ENABLED"; then
        echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
        return 1
	fi

	# declare variable to store the list of included .yml files when docker compose runs
	local compose_file

	# construct the COMPOSE_FILE value of included .yml files
	proj_client_construct_compose_file_string "compose_file" "${env_name}" "${deploy_dest}" "${ORDS_ENABLED}"
	
	# declare COMPOSE_FILE as an environment variable so it can be used in the container deployment
	COMPOSE_FILE="${compose_file}"

	# Check if the secret file exists:
	if [ -f "${BUILD_PATH}/secrets/secrets.sh" ]; then
		# load the secrets
		source "${BUILD_PATH}"/secrets/secrets.sh
	else
        echo "Error: ${FUNCNAME[0]}() function could not load the secrets/secrets.sh file" >&2
        return 1
	fi
	
	# check if this is a local or server deployment:
	if [[ "${deploy_dest}" == "local" ]]; then
		echo "This is a local deployment"

		# export the environment variables used directly in the docker compose files:
		cds_shared_export_env_vars "COMPOSE_PROJECT_NAME" "DB_HOST_PORT" "ORDS_HOST_PORT" "DB_IMAGE" "ORDS_IMAGE" "TARGET_APEX_VERSION" "APP_SCHEMA_NAME" "ORACLE_PWD" "DBPORT" "DBHOST" "DBSERVICENAME" "STACK_NAME" "NETWORK_NAME"

		# declare the function arguments
		local -A deploy_args=(
			["stack_name"]="${STACK_NAME}"
			["secret_map"]="${SECRET_MAPPING_VAR_NAME}"
			["network_name"]="${NETWORK_NAME}"
			["deploy_dest"]="${deploy_dest}"
			["build_image"]="yes"
			["compose_path"]="${compose_file}"
			["build_path"]="${BUILD_PATH}" 
			["secret_name_prefix"]="${COMPOSE_PROJECT_NAME}_"
			["rem_vol"]="${rem_vol}"
		)

		echo "The argument array is: $(cds_shared_dump_array_vals "deploy_args")"

		# deploy the containers locally:
		cds_shared_deploy_container_stack "deploy_args"
	else
		echo "This is a server deployment"
		
		# validate the bash variable values
		if ! cds_shared_validate_required_vars "CONFIG_DIR" "HOSTNAME" "HOST_SOURCE_PATH" "GIT_URL" "HOST_SCRIPTS_PATH" "SECRET_DATA_VAR_NAME" "SECRET_MAPPING_VAR_NAME"; then
			echo "Error: ${FUNCNAME[0]}() function required bash variable validation for server deployments failed" >&2
			return 1
		fi

		# declare a variable for the rem_vol value so it can be passed to the server script as an environment variable
		REM_VOL="${rem_vol}"

		# declare environment variable string for the environment variables to be passed to the container host via the ssh call
		local env_var_string="$(cds_shared_generate_ssh_env_vars_string "COMPOSE_PROJECT_NAME" "DB_HOST_PORT" "ORDS_HOST_PORT" "DB_IMAGE" "ORDS_IMAGE" "TARGET_APEX_VERSION" "APP_SCHEMA_NAME" "PRIV_USER" "COMPOSE_FILE" "STACK_NAME" "NETWORK_NAME" "REM_VOL")"

#		echo "The value of the env_var_string is: ${env_var_string}"

		# declare the function arguments
		local -A remote_deploy_args=(
				["target_host"]="${HOSTNAME}"
				["source_path"]="${HOST_SOURCE_PATH}"
				["git_url"]="${GIT_URL}"
				["ssh_cmd"]="${env_var_string} bash ${HOST_SCRIPTS_PATH}/host_deploy_CODE.sh"
				["secret_var"]="${SECRET_DATA_VAR_NAME}"
				["secret_map"]="${SECRET_MAPPING_VAR_NAME}"
				["process_secrets"]="yes"
			)
			
		echo "deploy the containers to the host server"
		
		# deploy the containers to the remote server
		cds_client_execute_remote_deployment "remote_deploy_args"
	fi
}

# the function returns the compose separator character based on the container deployment environment
function proj_client_get_compose_separator()
{
	local compose_sep_name="${1}"
	local deploy_dest="${2}"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars "compose_sep_name" "deploy_dest"; then
        echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
        return 1
	fi

	# define the reference to the local variable
	local -n compose_sep_ref="${compose_sep_name}"

	# Determine the correct OS path separator for the COMPOSE_FILE environment variable for linux server deployments and for local Mac/Linux deployments
	compose_sep_ref=":"

	# check if the deployment destination is local
	if [[ "${deploy_dest}" == "local" ]]; then	
		# this is a local deployment, check if this is a windows machine
		case "$(uname -s)" in
			MINGW*|CYGWIN*|MSYS*)
				# this is a windows machine for a local deployment, use the semicolon separator
				compose_sep_ref=";"
				;;
		esac
	fi
}


# function that shuts down the containers for a CODE environment
# the function accepts the following arguments:
# 1: passed env_name value (dev, test)
# 2: passed deploy_dest: deployment destination value (local, server)
# 3: passed rem_vol: flag to indicate if the associated volumes should be removed (yes) or not (no). This defaults to "no"
function proj_client_shutdown_container ()
{
	local env_var_name="env_name"
	local dest_var_name="deploy_dest"
	local rem_vol_var_name="rem_vol"
	local passed_env_value="${1:-}"
	local passed_deploy_value="${2:-}"
	local passed_rem_vol_value="${3:-no}"
	
# 	echo "running proj_client_shutdown_container(${1}, ${2})"
	
	# validate the bash variable values
	if ! cds_shared_validate_required_vars "env_var_name" "dest_var_name" "rem_vol_var_name"; then
		echo "Error: ${FUNCNAME[0]}() function required function argument validation failed" >&2
		return 1
	fi

	# save/prompt for environment name into the specified local variable
	cds_client_set_env_name_var "${env_var_name}" "${passed_env_value}" 

	# save/prompt for deployment destination (local, server) for Dual-Target capability
	cds_client_set_deploy_dest_var "${dest_var_name}" "${passed_deploy_value}"

	# save/prompt for remove volume flag (yes, no)
	cds_client_set_rem_vol_var "${rem_vol_var_name}" "${passed_rem_vol_value}"

	# notify the user of the user-defined runtime value
	echo "Runtime Argument Values:"
	echo "env_name: ${!env_var_name}"
	echo "deploy_dest: ${!dest_var_name}"
	echo "rem_vol: ${!rem_vol_var_name}"

	# shutdown the CODE containers based on the deployment destination and custom configuration 
	proj_client_shutdown_dev_environment "${!env_var_name}" "${!dest_var_name}" "${!rem_vol_var_name}"

	# notify the user that the container has finished executing
	echo "The docker container has been shutdown - environment name: ${!env_var_name}, deployment destination: ${!dest_var_name}, remove volume: ${!rem_vol_var_name}"
}

# function that shuts down the containers for a environment
# the function accepts the following arguments:
# 1: environment name (dev, test)
# 2: deploy destination (local, server)
# 3: remove volume (yes, no)
function proj_client_shutdown_dev_environment ()
{
	# build the list of compose files:
	local env_name="${1}"
	local deploy_dest="${2}"
	local rem_vol="${3}"
	
	# validate the bash variable values
	if ! cds_shared_validate_required_vars "env_name" "deploy_dest" "rem_vol" "BUILD_PATH" "ORDS_ENABLED"; then
        echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
        return 1
	fi

	# declare variable to store the list of included .yml files when docker compose runs
	local compose_file

	# construct the COMPOSE_FILE value of included .yml files
	proj_client_construct_compose_file_string "compose_file" "${env_name}" "${deploy_dest}" "${ORDS_ENABLED}"
	
	# declare COMPOSE_FILE as an environment variable so it can be used in the container deployment
	COMPOSE_FILE="${compose_file}"

	# check if this is a local or server deployment:
	if [[ "${deploy_dest}" == "local" ]]; then
		echo "Shutdown the local deployment (${COMPOSE_PROJECT_NAME})"

		# export the environment variables used directly in the docker compose files:
		cds_shared_export_env_vars "COMPOSE_PROJECT_NAME" "DB_HOST_PORT" "ORDS_HOST_PORT" "DB_IMAGE" "ORDS_IMAGE" "TARGET_APEX_VERSION" "APP_SCHEMA_NAME" "COMPOSE_FILE" "DBPORT" "DBHOST" "DBSERVICENAME" "STACK_NAME" "NETWORK_NAME"

		# shutdown the CODE containers to the host server associated with the $STACK_NAME
		cds_shared_remove_container_stack "${STACK_NAME}" "${NETWORK_NAME}" "${rem_vol}"
	else
		echo "Shutdown the server deployment (${COMPOSE_PROJECT_NAME})"
		
		# validate the bash variable values
		if ! cds_shared_validate_required_vars "CONFIG_DIR" "HOSTNAME" "HOST_SOURCE_PATH" "GIT_URL" "HOST_SCRIPTS_PATH" "SECRET_DATA_VAR_NAME" "SECRET_MAPPING_VAR_NAME"; then
			echo "Error: proj_client_shutdown_dev_environment() function required bash variable validation for server deployments failed" >&2
			return 1
		fi

		# declare REM_VOL as an environment variable so it can be used in the container deployment
		REM_VOL="${rem_vol}"

		# declare environment variable string for the environment variables to be passed to the container host via the ssh call
		local env_var_string="$(cds_shared_generate_ssh_env_vars_string "COMPOSE_PROJECT_NAME" "DB_HOST_PORT" "ORDS_HOST_PORT" "DB_IMAGE" "ORDS_IMAGE" "TARGET_APEX_VERSION" "APP_SCHEMA_NAME" "PRIV_USER" "COMPOSE_FILE" "REM_VOL" "STACK_NAME" "NETWORK_NAME")"

#		echo "The value of the env_var_string is: ${env_var_string}"

		# declare the function arguments
		local -A remote_deploy_args=(
				["target_host"]="${HOSTNAME}"
				["source_path"]="${HOST_SOURCE_PATH}"
				["git_url"]="${GIT_URL}"
				["ssh_cmd"]="${env_var_string} bash ${HOST_SCRIPTS_PATH}/host_shutdown_CODE.sh"
				["secret_var"]="${SECRET_DATA_VAR_NAME}"
				["secret_map"]="${SECRET_MAPPING_VAR_NAME}"
				["process_secrets"]="no"
			)
			
		echo "shutdown the containers on the host server"
		
		# deploy the containers to the remote server
		cds_client_execute_remote_deployment "remote_deploy_args"
	fi
}
