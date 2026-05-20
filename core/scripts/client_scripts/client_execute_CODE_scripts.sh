#!/bin/bash

# Enforce Bash strict mode: exit on errors, unbound variables, and pipeline failures
# set -euo pipefail

# include the client functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_client_resources.sh"

function main()
{
	local -A client_deploy_container_args=(
		["script_action"]="${1}"
		["env_name"]="${2}"
		["deploy_dest"]="${3}"
		["rem_vol"]="${4:-no}"
		["build_path"]="${BUILD_PATH}"
		["ords_enabled"]="${ORDS_ENABLED}"
		["compose_project_name"]="${COMPOSE_PROJECT_NAME}"
		["db_host_port"]="${DB_HOST_PORT}"
		["ords_host_port"]="${ORDS_HOST_PORT}"
		["db_image"]="${DB_IMAGE}"
		["ords_image"]="${ORDS_IMAGE}"
		["target_apex_version"]="${TARGET_APEX_VERSION}"
		["app_schema_name"]="${APP_SCHEMA_NAME}"
		["dbport"]="${DBPORT}"
		["dbhost"]="${DBHOST}"
		["dbservicename"]="${DBSERVICENAME}"
		["stack_name"]="${STACK_NAME}"
		["network_name"]="${NETWORK_NAME}"
		["secret_mapping_var_name"]="${SECRET_MAPPING_VAR_NAME}"
		["priv_user"]="${PRIV_USER}"
		["hostname"]="${HOSTNAME}" 
		["host_source_path"]="${HOST_SOURCE_PATH}" 
		["git_url"]="${GIT_URL}"
		["host_scripts_path"]="${HOST_SCRIPTS_PATH}"
		["secret_data_var_name"]="${SECRET_DATA_VAR_NAME}"
		["config_dir"]="${CONFIG_DIR}"
		["compose_file_array"]="COMPOSE_FILES"
		["project_linear_dependencies_var"]="PROJECT_LINEAR_DEPENDENCIES"
		["projects_path"]="${PROJECTS_PATH}"
	)

	# echo "DEBUG: the code_client_process_arguments_execute_container_scripts() function arguments are: $(cds_shared_dump_array_vals "client_deploy_container_args")"

	# deploy the containers for the development environment
	code_client_process_arguments_execute_container_scripts "client_deploy_container_args"
}

# call the main function with the runtime arguments specified for the calling script
main "$@"