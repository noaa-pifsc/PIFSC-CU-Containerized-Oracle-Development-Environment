#!/bin/bash

# function that returns a custom string for project-specific environment variable definitions in the following format: export VAR1="val1"\n export VAR2="val2"
function proj_host_custom_export_env_vars_block()
{
    local output_str=""

	# generate and output the custom environment variable definitions
	# Example: 
	# output_str+="export ${var_name}='${!var_name}'"

    # echo the result without the trailing space
    echo "${output_str% }"
}