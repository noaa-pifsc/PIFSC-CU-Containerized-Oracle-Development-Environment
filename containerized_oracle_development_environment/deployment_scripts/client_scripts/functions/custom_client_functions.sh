#!/bin/bash

# function to construct the compose file string for docker compose
function proj_client_construct_compose_file_string ()
{
	local compose_file_var="${1}"
	local env_name="${2}"
	local deploy_dest="${3}"
	local ords_enabled="${4}"

	# save a reference to the $compose_file_var variable
	local -n out_compose_file_ref="${compose_file_var}"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars "env_name" "deploy_dest" "compose_file_var" "ords_enabled"; then
        echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
        return 1
	fi

	# declare compose separator variable
	local compose_sep 

	# store the compose separator character so it can be used to construct the formatted compose file list
	code_client_get_compose_separator "compose_sep" "${deploy_dest}"
	
	# build the list of compose files using $compose_sep as the separator for the target deployment machine:
	# include the code-db and code-db-ords-deploy services, and custom docker compose to integrate additional services
	out_compose_file_ref="./CODE-db-deploy.yml"

	# check if this is intended for a dev environment (retain the database volume across container restarts) 
	if [ "${env_name}" == "dev" ]; then
		# add in the named volume for the code-db service
		out_compose_file_ref="${out_compose_file_ref}${compose_sep}./CODE-db-named-volume.yml"
	fi
	
	# check if the ORDS/Apex service is enabled
	if [ "${ords_enabled}" == "yes" ]; then
		# include the ORDS service
		out_compose_file_ref="${out_compose_file_ref}${compose_sep}./CODE-ords.yml"
	fi
	
	# append the custom docker compose file
	# out_compose_file_ref="${out_compose_file_ref}${compose_sep}./custom-docker-compose.yml"
	
	# Add any additional custom docker compose configuration files:
	
	
	
}

# function that exports custom environment variable definitions
function proj_client_custom_export_env_vars ()
{
	# export custom environment variables
	echo "exporting custom environment variables"
	
	# example:
	# cds_shared_export_env_vars "VAR1" "VAR2"

}

# function that returns a string with environment variable definition  
function proj_client_custom_string_env_vars ()
{
    local output_str=""

	# example:
	#   output_str+="${var_name}=\"${!var_name}\" "
    
    # echo the result without the trailing space
    echo " ${output_str% }"
}

# function that loads custom scripts that define configuration and/or secret values
function proj_client_custom_load_scripts ()
{
	# load any files that contain required configuration and/or secret values 
	
	echo "loading custom configuration/secret values"

	# examples:
	# source "${BUILD_PATH}/custom_config.sh"
	# source "${BUILD_PATH}/secrets/db_secrets.sh"

}