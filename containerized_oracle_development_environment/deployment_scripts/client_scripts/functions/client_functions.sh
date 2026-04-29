#!/bin/bash

# function that processes user runtime arguments and executes the specified script action (deploy or shutdown)
# the function accepts the following arguments:
# 1: passed script_action value (deploy, shutdown)
# 2: passed env_name value (dev, test)
# 3: passed deploy_dest: deployment destination value (local, server)
# 4: rem_vol flag: (optional) remove the volumes associated with the docker stack name (yes) or retain them (no). This defaults to "no"
function proj_client_process_arguments_execute_container_scripts ()
{
	local script_action_name="script_action"
	local env_var_name="env_name"
	local dest_var_name="deploy_dest"
	local rem_vol_var_name="rem_vol"
	local passed_script_action="${1:-}"
	local passed_env_value="${2:-}"
	local passed_deploy_value="${3:-}"
	local passed_rem_vol_value="${4:-no}"
	
	# validate the bash variable values
	if ! cds_shared_validate_required_vars	"script_action_name" "env_var_name" "dest_var_name"; then
		echo "Error: ${FUNCNAME[0]}() function required function argument validation failed" >&2
		return 1
	fi

	# save/prompt for script action type into the specified local variable
	cds_client_set_script_action_var "${script_action_name}" "${passed_script_action}"

	# save/prompt for environment name into the specified local variable
	cds_client_set_env_name_var "${env_var_name}" "${passed_env_value}" 

	# save/prompt for deployment destination (local, server) for Dual-Target capability
	cds_client_set_deploy_dest_var "${dest_var_name}" "${passed_deploy_value}"

	# save/prompt for remove volume flag (yes, no)
	cds_client_set_rem_vol_var "${rem_vol_var_name}" "${passed_rem_vol_value}"

	# notify the user of the user-defined runtime value
	echo "Runtime Argument Values:"
	echo "script_action: ${!script_action_name}"
	echo "env_name: ${!env_var_name}"
	echo "deploy_dest: ${!dest_var_name}"
	echo "rem_vol: ${!rem_vol_var_name}"

	# execute the specified script action on the CODE containers 
	proj_client_execute_container_scripts "${!script_action_name}" "${!env_var_name}" "${!dest_var_name}" "${!rem_vol_var_name}"

	# notify the user that the script action has finished executing
	echo "The ${!script_action_name} action was successfully executed on the docker container(s) - environment name: ${!env_var_name}, deployment destination: ${!dest_var_name}, remove volume: ${!rem_vol_var_name}"
}

# function that executes the specified script action on the CODE containers
# the function accepts the following arguments:
# 1: passed script_action value (deploy, shutdown)
# 2: environment name (dev, test)
# 3: deploy destination (local, server)
# 4: rem_vol flag: (optional) remove the volumes associated with the docker stack name (yes) or retain them (no). This defaults to "no"
function proj_client_execute_container_scripts ()
{
	# build the list of compose files:
	local script_action="${1}"
	local env_name="${2}"
	local deploy_dest="${3}"
	local rem_vol="${4:-no}"
	
	# validate the bash variable values
	if ! cds_shared_validate_required_vars "script_action" "env_name" "deploy_dest" "BUILD_PATH" "ORDS_ENABLED"; then
        echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
        return 1
	fi

	# declare variable to store the list of included .yml files when docker compose runs
	local compose_file

	# construct the COMPOSE_FILE value of included .yml files
	proj_client_construct_compose_file_string "compose_file" "${env_name}" "${deploy_dest}" "${ORDS_ENABLED}"
	
	# check if this is a deployment, if so load the local secret file so the container secret(s) can be created
	if [[ "${script_action}" == "deploy" ]]; then
		# Check if the secret file exists:
		if [ -f "${BUILD_PATH}/secrets/secrets.sh" ]; then
			# load the secrets
			source "${BUILD_PATH}"/secrets/secrets.sh
		else
			echo "Error: ${FUNCNAME[0]}() function could not load the secrets/secrets.sh file" >&2
			return 1
		fi
	fi
	
	# check if this is a local or server deployment:
	if [[ "${deploy_dest}" == "local" ]]; then
		echo "This is a local deployment"

		# export the environment variables used directly in the docker compose files:
		cds_shared_export_env_vars "COMPOSE_PROJECT_NAME" "DB_HOST_PORT" "ORDS_HOST_PORT" "DB_IMAGE" "ORDS_IMAGE" "TARGET_APEX_VERSION" "APP_SCHEMA_NAME" "DBPORT" "DBHOST" "DBSERVICENAME" "STACK_NAME" "NETWORK_NAME"

		# check the script_action value to determine if this is a deployment or shutdown script
		if [[ "${script_action}" == "deploy" ]]; then
			# this is a deployment

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

			# deploy the containers locally:
			cds_shared_deploy_container_stack "deploy_args"
		else
			# this is a shutdown script

			# shutdown the CODE containers to the host server associated with the $STACK_NAME
			cds_shared_remove_container_stack "${STACK_NAME}" "${NETWORK_NAME}" "${rem_vol}"
		fi
	else
		echo "This is a server deployment"
		
		# validate the bash variable values
		if ! cds_shared_validate_required_vars "CONFIG_DIR" "HOSTNAME" "HOST_SOURCE_PATH" "GIT_URL" "HOST_SCRIPTS_PATH" "SECRET_DATA_VAR_NAME" "SECRET_MAPPING_VAR_NAME"; then
			echo "Error: ${FUNCNAME[0]}() function required bash variable validation for server deployments failed" >&2
			return 1
		fi

		# declare global variables for the rem_vol, compose_file, and script_action values so they can be passed to the server script as environment variables
		REM_VOL="${rem_vol}"
		COMPOSE_FILE="${compose_file}"
		SCRIPT_ACTION="${script_action}"

		# declare environment variable string for the environment variables to be passed to the container host via the ssh call
		local env_var_string="$(cds_shared_generate_ssh_env_vars_string "COMPOSE_PROJECT_NAME" "DB_HOST_PORT" "ORDS_HOST_PORT" "DB_IMAGE" "ORDS_IMAGE" "TARGET_APEX_VERSION" "APP_SCHEMA_NAME" "PRIV_USER" "COMPOSE_FILE" "STACK_NAME" "NETWORK_NAME" "REM_VOL" "SCRIPT_ACTION")"

#		echo "The value of the env_var_string is: ${env_var_string}"

		# assign the value of the process_secrets variable based on the script action value
		if [[ "${script_action}" == "deploy" ]]; then
			local process_secrets="yes"
		else
			local process_secrets="no"
		fi

		# declare the function arguments
		local -A remote_deploy_args=(
				["target_host"]="${HOSTNAME}"
				["source_path"]="${HOST_SOURCE_PATH}"
				["git_url"]="${GIT_URL}"
				["ssh_cmd"]="${env_var_string} bash ${HOST_SCRIPTS_PATH}/host_execute_CODE_scripts.sh"
				["secret_var"]="${SECRET_DATA_VAR_NAME}"
				["secret_map"]="${SECRET_MAPPING_VAR_NAME}"
				["process_secrets"]="${process_secrets}"
			)
			
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