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
	
	echo "running proj_client_deploy_container(${1}, ${2})"
	
	# validate the bash variable values
	if ! cds_shared_validate_required_vars	"env_var_name" "dest_var_name"; then
		echo "Error: proj_client_deploy_container() function required function argument validation failed" >&2
		return 1
	fi

	# save/prompt for environment name into the specified local variable
	cds_client_set_env_name_var "${env_var_name}" "${passed_env_value}" 

	echo "Deploy the containerized oracle development environment (${!env_var_name})"

	# save/prompt for deployment destination (local, server) for Dual-Target capability
	cds_client_set_deploy_dest_var "${dest_var_name}" "${passed_deploy_value}"

	# build/deploy the CODE container with the environment 
	proj_client_build_deploy_dev_environment "${!env_var_name}" "${!dest_var_name}"

	# notify the user that the container has finished executing
	echo "The ${!env_var_name} docker container has finished building and is running on ${!dest_var_name}"
}


