#!/bin/bash

# function that executes database scripts within the container
function proj_container_database_deploy_custom_scripts ()
{
	local secrets_var_name="${1}"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars "secrets_var_name"; then
        echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
        return 1
	fi
	
	# define the pointer to the secrets object to access the secret values
	local -n secrets_ref="${1}"

	echo "running the custom database and/or application deployment scripts"

	# run each of the sqlplus scripts to deploy the schemas, objects for each schema, applications, etc.
	# ... YOUR SCRIPT LOGIC HERE ...

	echo "custom deployment scripts have completed successfully"
}