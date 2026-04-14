#!/bin/bash

# function that deploys the containers for a dev environment
function proj_client_deploy_container ()
{
	local env_var_name="env_name"
	local passed_env_value="${1:-}"

	# save/prompt for environment name into the specified local variable
	cds_client_set_env_name_var "${env_var_name}" "${passed_env_value}" 

	echo "Deploy the containerized oracle development environment (${!env_var_name})"

	# build/deploy the CODE container with the environment 
	proj_client_build_deploy_dev_environment "${!env_var_name}"

	# notify the user that the container has finished executing
	echo "The ${!env_var_name} docker container has finished building and is running"
}