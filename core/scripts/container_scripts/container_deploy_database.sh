#!/bin/bash

# Enforce Bash strict mode: exit on errors, unbound variables, and pipeline failures
set -euo pipefail

# include the client functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_container_resources.sh"

# main function definition to create a local array to specify the runtime function arguments:
function main()
{
	# define the function arguments for code_container_process_apex_install()
	local -A deploy_database_scripts_func_args=(
			["dbhost"]="${DBHOST}"
			["dbport"]="${DBPORT}"
			["dbservicename"]="${DBSERVICENAME}"
			["app_schema_name"]="${APP_SCHEMA_NAME}"
			["target_apex_version"]="${TARGET_APEX_VERSION}"
			["oracle_pwd_file"]="${ORACLE_PWD_FILE}"
			["ords_enabled"]="${ORDS_ENABLED}"
			["deploy_id"]="${DEPLOY_ID}"
			["db_scripts_map"]="DB_SCRIPTS_MAP"
			["projects_path"]="${PROJECTS_PATH}"
			["project_linear_dependencies_var"]="PROJECT_LINEAR_DEPENDENCIES"
		)

	# Execute the database orchestration scripts, passing the secure vault by name
	code_container_deploy_database_scripts "deploy_database_scripts_func_args"
}

# call the main function with all arguments sent to the calling script
main "$@"	