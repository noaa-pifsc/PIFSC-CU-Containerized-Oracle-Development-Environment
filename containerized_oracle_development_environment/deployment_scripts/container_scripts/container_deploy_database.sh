#!/bin/bash

# Enforce Bash strict mode: exit on errors, unbound variables, and pipeline failures
set -euo pipefail

# include the client functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_container_resources.sh"

function main ()
{
	local -A parsed_secrets=()
	
	echo "Initializing hybrid security vault..."

	# Process STDIN Pipelining (For Run-time / Remote Server Deployments)

	# capture the STDIN data (if any)
	local raw_stdin=""
	if [[ ! -t 0 ]]; then raw_stdin=$(cat); fi

	# if the STDIN data exists, parse it and store it in the parsed_secrets associative array variable
	if [[ -n "${raw_stdin}" ]]; then
		cds_shared_parse_secret_data "${SECRET_MAPPING_VAR_NAME}" "parsed_secrets" <<< "${raw_stdin}"
	fi

	# Process Environment Variable Processing (For Boot-time / Docker Desktop Deployments)

	# Use a nameref to correctly expand the array keys from the variable name
	local -n secret_map_ref="${SECRET_MAPPING_VAR_NAME}"
	local secret_name bash_var_name

	# loop through the secret mapping array elements
	for secret_name in "${!secret_map_ref[@]}"; do
		# set a temporary bash variable so it can be used to retrieve the corresponding bash variable name (from the associative array element value)
		bash_var_name="${secret_map_ref[${secret_name}]}"
		
		# check if the bash variable name is defined
		if [[ -v "${bash_var_name}" ]]; then
			# Copy the value into the parsed_secrets array (if it was not already set by STDIN)
			if [[ -z "${parsed_secrets[${secret_name}]:-}" ]]; then
				# declare the parsed_secrets array element for the current secret name to the corresponding bash variable name
				parsed_secrets["${secret_name}"]="${!bash_var_name}"
			fi
			
			# Sanitize the shell: unset the global environment variable immediately
			unset "${bash_var_name}"
		fi
	done

	# Ensure the parsed_secrets array is wiped from memory when the script exits
	trap "unset parsed_secrets" EXIT

	# Execute the database orchestration scripts, passing the secure vault by name
	proj_container_deploy_database_scripts "parsed_secrets"
}

# Execute the main function
main "$@"