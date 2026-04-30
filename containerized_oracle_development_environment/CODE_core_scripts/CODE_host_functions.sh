#!/bin/bash

# function that prepares the specified script action (deploy or shutdown) for execution on a given container host with an unprivileged account
# This function accepts the following parameters as elements in the specified array name (arg_array): 
# priv_user: The privileged host server user name that can execute container procedures
# host_source_path: container server CODE source path 
# secret_data_var_name: variable to store the name of the configuration data variable that is passed via STDIN that contains secret values
# script_action: passed script_action value (deploy, shutdown)
# env_block: formatted string of environment variable definitions that are passed to the bash script executed as the privileged user (priv_user)
# secret_mapping_var_name: the name of the configuration data variable that is passed via STDIN that contains secret values
# host_scripts_path: path to the folder where the host bash scripts are contained
function code_host_execute_container_scripts()
{
	# store the function array argument
	local arg_array="${1}"

    # Validation check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: ${FUNCNAME[0]}() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi

	# input validation:
	if ! cds_shared_validate_required_array_vals "${arg_array}" "priv_user" "host_source_path" "secret_data_var_name" "script_action" "env_block" "secret_mapping_var_name" "host_scripts_path"; then
        echo "Error: ${FUNCNAME[0]}() function argument validation failed" >&2
        return 1
    fi

	# create a pointer to the arg_array variable to make it easy to access the argument array values
	local -n arg_ref="${arg_array}"

	# assign the value of the process_secrets variable based on the script action value
	if [[ "${arg_ref[script_action]}" == "deploy" ]]; then
		local process_secrets="yes"
	else
		local process_secrets="no"
	fi

	# generate the formatted environment variable block
	local env_block="${arg_ref[env_block]}"
	
	# add any custom environment variables to the block
	env_block+="$(proj_host_custom_export_env_vars_block)"

	# declare the function arguments as a local variable
	local -A func_args=(
			["target_user"]="${arg_ref[priv_user]}" 
			["source_path"]="${arg_ref[host_source_path]}"
			["secret_var"]="${arg_ref[secret_data_var_name]}"
			["deploy_script_path"]="${arg_ref[host_scripts_path]}/host_execute_CODE_scripts_elev_privs.sh"
			["env_block"]="${env_block}"
			["secret_map"]="${arg_ref[secret_mapping_var_name]}"
			["process_secrets"]="${process_secrets}"
			["persistent_container"]="yes"
		)
		
	# initialize and execute the specified script action on the host machine with the specified function arguments:
	cds_host_deploy_container "func_args"	
}


# function that executes the specified script action (deploy or shutdown) on a given container host with a privileged account
# This function accepts no parameters
function code_host_execute_container_scripts_elev_privs()
{
	# store the function array argument
	local arg_array="${1}"

    # Validation check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: ${FUNCNAME[0]}() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi

	# input validation:
	if ! cds_shared_validate_required_array_vals "${arg_array}" "compose_path" "secret_map" "build_path" "stack_name" "network_name" "rem_vol"; then
        echo "Error: ${FUNCNAME[0]}() function argument validation failed" >&2
        return 1
    fi

	# create a pointer to the arg_array variable to make it easy to access the argument array values
	local -n arg_ref="${arg_array}"

	# export the database connection environment variables used directly in the docker compose files:
	cds_shared_export_array_keys "${arg_array}" "dbport" "dbhost" "dbservicename"

	# check the specified script action
	if [[ "${arg_ref[script_action]}" == "deploy" ]]; then 
		# this is a deployment action
		
		# declare the function arguments
		local -A host_deploy_stack_args=(
				["stack_name"]="${arg_ref[stack_name]}"
				["secret_map"]="${arg_ref[secret_map]}"
				["network_name"]="${arg_ref[network_name]}"
				["deploy_dest"]="server"
				["build_image"]="yes"
				["compose_path"]="${arg_ref[compose_path]}"
				["build_path"]="${arg_ref[build_path]}"
				["secret_name_prefix"]="${arg_ref[secret_name_prefix]}"
				["rem_vol"]="${arg_ref[rem_vol]}"
			)

		# execute the secret definitions and the container build/run process on the target folder using a privileged account
		cds_shared_deploy_container_stack "host_deploy_stack_args"
	else
		# this is a shutdown action
		
		# shutdown the CODE containers to the host server associated with the $STACK_NAME
		cds_shared_remove_container_stack "${arg_ref[stack_name]}" "${arg_ref[network_name]}" "${arg_ref[rem_vol]}"
	fi

	echo "The container script action has been completed"
}