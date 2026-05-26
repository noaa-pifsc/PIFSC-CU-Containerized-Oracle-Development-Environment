#!/bin/bash

# Enforce Bash strict mode: exit on errors, unbound variables, and pipeline failures
# set -euo pipefail

#-----------------------------------------------------------------------------
# host_deploy_CODE_elev_privs.sh:
# this host script runs as the $PRIV_USER to build and run 
# the container and execute a specified script from within the container
#-----------------------------------------------------------------------------

# include the host functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_host_resources.sh"

function main()
{
	# define the function arguments from the environment variables passed to this script and the global configuration variables
	local -A host_execute_container_elev_privs_scripts_args=(
		["stack_name"]="${STACK_NAME}"
		["secret_map"]="${SECRET_MAPPING_VAR_NAME}"
		["network_name"]="${NETWORK_NAME}"
		["compose_path"]="${COMPOSE_FILE}"
		["build_path"]="${BUILD_PATH}"
		["secret_name_prefix"]="${COMPOSE_PROJECT_NAME}_"
		["rem_vol"]="${REM_VOL}"
		["dbport"]="${DBPORT}"
		["dbhost"]="${DBHOST}"
		["dbservicename"]="${DBSERVICENAME}"
		["script_action"]="${SCRIPT_ACTION}"
		["projects_path"]="${PROJECTS_PATH}"
		["project_linear_dependencies_var"]="PROJECT_LINEAR_DEPENDENCIES"
	)

	# deploy the container on the container host using a privileged account
	code_host_execute_container_scripts_elev_privs "host_execute_container_elev_privs_scripts_args"
}

# call the main function with all arguments sent to the calling script
main "$@"