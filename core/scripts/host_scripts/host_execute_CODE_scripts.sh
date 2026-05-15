#!/bin/bash

# Enforce Bash strict mode: exit on errors, unbound variables, and pipeline failures
# set -euo pipefail

#-----------------------------------------------------------------------------
# host_deploy_CODE.sh:
# this host script runs a script as the $PRIV_USER to build the 
# container image and run the container on the container host by executing 
# host_deploy_CODE_elev_privs.sh
#-----------------------------------------------------------------------------

# Include CDS host resources
source "$(dirname "${BASH_SOURCE[0]}")/includes/include_host_resources.sh"

function main()
{
	# define the function arguments from the environment variables passed to this script and the global configuration variables
	local -A host_execute_container_scripts_args=(
		["priv_user"]="${PRIV_USER}"
		["host_source_path"]="${HOST_SOURCE_PATH}"
		["secret_data_var_name"]="${SECRET_DATA_VAR_NAME}"
		["secret_mapping_var_name"]="${SECRET_MAPPING_VAR_NAME}"
		["build_path"]="${BUILD_PATH}"
		["script_action"]="${SCRIPT_ACTION}"
		["env_block"]="$(cds_shared_generate_export_env_vars_block "COMPOSE_PROJECT_NAME" "DB_HOST_PORT" "ORDS_HOST_PORT" "DB_IMAGE" "ORDS_IMAGE" "TARGET_APEX_VERSION" "APP_SCHEMA_NAME" "COMPOSE_FILE" "STACK_NAME" "NETWORK_NAME" "REM_VOL" "SCRIPT_ACTION" "ORDS_ENABLED" "DBPORT" "DBHOST" "DBSERVICENAME")"
		["host_scripts_path"]="${HOST_SCRIPTS_PATH}"
		["projects_path"]="${PROJECTS_PATH}"
		["project_inheritance_var"]="PROJECT_INHERITANCE"
	)

	# initialize and build/run the container on the host machine with the specified function arguments:
	code_host_execute_container_scripts "host_execute_container_scripts_args"
}

# call the main function with all arguments sent to the calling script
main "$@"	