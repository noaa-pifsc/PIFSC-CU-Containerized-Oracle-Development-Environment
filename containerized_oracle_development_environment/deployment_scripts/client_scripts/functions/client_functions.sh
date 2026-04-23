#!/bin/bash

# function that deploys the containers for a dev environment
# the function accepts the following arguments:
# 1: passed env_name value (dev, test)
# 2: passed deploy_dest value (local, server)
function proj_client_deploy_container ()
{
	local env_var_name="env_name"
	local dest_var_name="deploy_dest"
	local passed_env_value="${1:-}"
	local passed_deploy_value="${2:-}"
	
# 	echo "running proj_client_deploy_container(${1}, ${2})"
	
	# validate the bash variable values
	if ! cds_shared_validate_required_vars	"env_var_name" "dest_var_name"; then
		echo "Error: proj_client_deploy_container() function required function argument validation failed" >&2
		return 1
	fi

	# save/prompt for environment name into the specified local variable
	cds_client_set_env_name_var "${env_var_name}" "${passed_env_value}" 

	# save/prompt for deployment destination (local, server) for Dual-Target capability
	cds_client_set_deploy_dest_var "${dest_var_name}" "${passed_deploy_value}"

	# notify the user of the user-defined runtime value
	echo "Runtime Argument Values:"
	echo "env_name: ${!env_var_name}"
	echo "deploy_dest: ${!dest_var_name}"

	# build/deploy the CODE container with the environment 
	proj_client_build_deploy_dev_environment "${!env_var_name}" "${!dest_var_name}"

	# notify the user that the container has finished executing
	echo "The ${!env_var_name} docker container has finished building and is running on ${!dest_var_name}"
}


# function that deploys the containers for a development environment
# the function accepts the following arguments:
# 1: environment name (dev, test)
# 2: deploy destination (local, server)
function proj_client_build_deploy_dev_environment ()
{
	# build the list of compose files:
	local env_name="${1}"
	local deploy_dest="${2}"
	
	# validate the bash variable values
	if ! cds_shared_validate_required_vars "env_name" "deploy_dest" "BUILD_PATH" "ORDS_ENABLED"; then
        echo "Error: proj_client_build_deploy_dev_environment() function required bash variable validation failed" >&2
        return 1
	fi

	# declare variable to store the list of included .yml files when docker compose runs
	local compose_file

	# construct the COMPOSE_FILE value of included .yml files
	proj_client_construct_compose_file_string "compose_file" "${env_name}" "${deploy_dest}" "${ORDS_ENABLED}"
	
	# Check if the secret file exists:
	if [ -f "${BUILD_PATH}/secrets/secrets.sh" ]; then
		# load the secrets
		source "${BUILD_PATH}"/secrets/secrets.sh
	else
        echo "Error: proj_client_build_deploy_dev_environment() function could not load the secrets/secrets.sh file" >&2
        return 1
	fi
	
	# check if this is a local or server deployment:
	if [[ "${deploy_dest}" == "local" ]]; then
		echo "This is a local deployment"

		# export the environment variables used directly in the docker compose files:
		cds_shared_export_env_vars "DB_IMAGE" "DB_HOST_PORT" "DBPORT" "ORACLE_PWD" "DBHOST" "DBSERVICENAME" "TARGET_APEX_VERSION" "APP_SCHEMA_NAME" "ORDS_IMAGE" "COMPOSE_PROJECT_NAME" "ORDS_HOST_PORT" "ENV_NAME" 

		# deploy the containers locally:
		proj_deploy_CODE_containers "${BUILD_PATH}" "${compose_file}"
	else
		echo "This is a server deployment"
		
		# validate the bash variable values
		if ! cds_shared_validate_required_vars "CONFIG_DIR" "HOSTNAME" "HOST_SOURCE_PATH" "GIT_URL" "HOST_SCRIPTS_PATH" "SECRET_DATA_VAR_NAME" "SECRET_MAPPING_VAR_NAME"; then
			echo "Error: proj_client_build_deploy_dev_environment() function required bash variable validation for server deployments failed" >&2
			return 1
		fi

		# declare COMPOSE_FILE as an environment variable so it can be used in the container deployment
		COMPOSE_FILE="${compose_file}"

		# declare environment variable string for the environment variables to be passed to the container host via the ssh call
		local env_var_string="$(cds_shared_generate_ssh_env_vars_string "DB_IMAGE" "DB_HOST_PORT" "DBPORT" "ORACLE_PWD" "DBHOST" "DBSERVICENAME" "TARGET_APEX_VERSION" "APP_SCHEMA_NAME" "ORDS_IMAGE" "COMPOSE_FILE")"

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
        echo "Error: proj_client_get_compose_separator() function required bash variable validation failed" >&2
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