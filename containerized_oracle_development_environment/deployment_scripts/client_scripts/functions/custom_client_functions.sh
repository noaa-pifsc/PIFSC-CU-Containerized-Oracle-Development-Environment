#!/bin/bash

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
	proj_construct_compose_file_string "compose_file" "${env_name}" "${deploy_dest}" "${ORDS_ENABLED}"
	
	echo "the value of COMPOSE_FILE is: ${COMPOSE_FILE}"

	# check if this is a local or server deployment:
	if [[ "${deploy_dest}" == "local" ]]; then
		echo "This is a local deployment"

		# deploy the containers locally:
		proj_deploy_CODE_containers "${BUILD_PATH}" "${compose_file}"
	else
		echo "This is a server deployment"
		
		# load the server deploy configuration file (defines the HOSTNAME variable)
		source "${CONFIG_DIR}/server_deploy_config.sh"

		# declare COMPOSE_FILE as an environment variable
		export COMPOSE_FILE="${compose_file}"

		# validate the bash variable values
		if ! cds_shared_validate_required_vars "CONFIG_DIR" "HOSTNAME" "HOST_SOURCE_PATH" "GIT_URL" "HOST_SCRIPTS_PATH" "SECRET_DATA_VAR_NAME" "SECRET_MAPPING_VAR_NAME"; then
			echo "Error: proj_client_build_deploy_dev_environment() function required bash variable validation for server deployments failed" >&2
			return 1
		fi

		# declare the function arguments
		local -A remote_deploy_args=(
				["target_host"]="${HOSTNAME}"
				["source_path"]="${HOST_SOURCE_PATH}"
				["git_url"]="${GIT_URL}"
				["ssh_cmd"]="$(proj_client_generate_ssh_env_vars "${env_name}") bash ${HOST_SCRIPTS_PATH}/host_deploy_CODE.sh"
				["secret_var"]="${SECRET_DATA_VAR_NAME}"
				["secret_map"]="${SECRET_MAPPING_VAR_NAME}"
				["process_secrets"]="yes"
			)
		
		# deploy the database to the remote server
		cds_client_execute_remote_deployment "remote_deploy_args"
	fi
}

# function to define the ssh environment variables for the database deployment server bash script
# Accepts the following parameters: 
# 1: the environment name
function proj_client_generate_ssh_env_vars ()
{
	local env_name="${1}"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars	"env_name"; then
        echo "Error: proj_client_generate_ssh_env_vars() function required bash variable validation failed" >&2
        return 1
	fi
	
	# echo the local values natively and use the dynamic generatr for the global configuration constants (ENV_NAME, COMPOSE_FILE)
	echo "ENV_NAME=\"${env_name}\" $(cds_shared_generate_ssh_env_vars_string "COMPOSE_FILE")"
}

# function to construct the compose file string for docker compose
function proj_construct_compose_file_string ()
{
	local compose_file_var="${1}"
	local env_name="${2}"
	local deploy_dest="${3}"
	local ords_enabled="${4}"

	# save a reference to the $compose_file_var variable
	local -n out_compose_file_ref="${compose_file_var}"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars "env_name" "deploy_dest" "compose_file_var" "ords_enabled"; then
        echo "Error: proj_construct_compose_file_string() function required bash variable validation failed" >&2
        return 1
	fi

	# Determine the correct OS path separator for the COMPOSE_FILE environment variable for linux server deployments and for local Mac/Linux deployments
	local compose_sep=":"

	# check if the deployment destination is local
	if [[ "${deploy_dest}" == "local" ]]; then	
		# this is a local deployment, check if this is a windows machine
		case "$(uname -s)" in
			MINGW*|CYGWIN*|MSYS*)
				# this is a windows machine for a local deployment, use the semicolon separator
				compose_sep=";"
				;;
		esac
	fi
	
	# build the list of compose files using $compose_sep as the separator for the target deployment machine:
	# include the code-db and code-db-ords-deploy services, and custom docker compose to integrate additional services
	out_compose_file_ref="./CODE-db-deploy.yml${compose_sep}./custom-docker-compose.yml"

	# check if this is intended for a dev environment (retain database and ords volumes across container restarts) 
	if [ "${env_name}" == "dev" ]; then
		# add in the named volume for the db service
		out_compose_file_ref="${out_compose_file_ref}${compose_sep}./CODE-db-named-volume.yml"
	fi
	
	# check if the ORDS/Apex service is enabled
	if [ "${ords_enabled}" == "yes" ]; then
		# include the ORDS service
		out_compose_file_ref="${out_compose_file_ref}${compose_sep}./CODE-ords.yml"
	fi

}