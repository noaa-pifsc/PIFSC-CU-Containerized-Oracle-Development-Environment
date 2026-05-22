#!/bin/bash

# this function loops through each of the project folders and executes any defined hook scripts for the project based on the specified timing and scope
# this function accepts the following parameters:
# 1: hook_timing - "pre" for hooks that run before the main action for the defined scope and "post" for hooks that run after the main action for the defined scope
# 2: hook_scope: this argument specifies one of the following values to determine which scope is being executed
#    -	client_local: For local CODE deployments, the main action is building and deploying the CODE container stack. 
#	 -	client_server: For server deployments, the main action is executing the bash script with a privileged user to deploy the container remotely on the container host  
#	 -	host_prep: For server CODE deployments, the main action is running the host deployment process with the privileged container user
#	 -	host_deploy: For server CODE deployments, the main action is building and deploying the CODE container stack
# 	 -	container: The main action is executing the database scripts to update the database and/or install apex application(s)
# 3: project_linear_dependencies_var: array variable name that stores the dependency information for the different forked CODE projects related to the current project
# 4: projects_path is the absolute path to the /projects folder in the root repository directory
function code_shared_run_project_hooks ()
{
	local hook_timing="${1}"
	local hook_scope="${2}"
	local project_linear_dependencies_var="${3}"
	local projects_path="${4}"
	
	# validate the bash variable values
	if ! cds_shared_validate_required_vars "hook_timing" "hook_scope" "project_linear_dependencies_var" "projects_path"; then
        echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
        return 1
	fi
	
	# define a pointer to the project_linear_dependencies array variable
	local -n project_linear_dependencies="${project_linear_dependencies_var}"
	
	# generate the hook script name
	local hook_script_name="${hook_timing}_${hook_scope}_hook.sh"

	local project_name
	# Iterate over the project_linear_dependencies elements and attempt to execute the hooks for each project in order to respect their dependencies
	for project_name in "${project_linear_dependencies[@]}"; do
		
#		echo "processing the ${hook_script_name} hook for ${project_name}"
		
		# check if the matching hook script file exists in the current project folder
		if [[ -f "${projects_path}/${project_name}/hooks/${hook_script_name}" ]]; then
			# the hook script exists, execute it now:
			# echo "the project-specific hook script exists: ${projects_path}/${project_name}/hooks/${hook_script_name}"

			# execute the specified hook script
			source "${projects_path}/${project_name}/hooks/${hook_script_name}"
		fi
	done
}


# this function uses the .active_project file and the $parent_project variable values for each parent project folder to generate the PROJECT_LINEAR_DEPENDENCIES that can be used to process all of the project-specific in a specific sequence to respect the dependencies
# this function accepts the following arguments:
# 1: project_linear_dependencies array variable name
# 2: project name is the name of a specific project folder within the repository's /projects/ folder
# 3: projects_path is the absolute path to the repository's /projects/ folder
function code_shared_define_project_linear_dependencies()
{
	local project_linear_dependencies_var="${1}"
	local project_name="${2}"
	local projects_path="${3}"
	
#	echo "running code_shared_define_project_linear_dependencies($@)"
	
	# validate the bash variable values
	if ! cds_shared_validate_required_vars "project_linear_dependencies_var" "projects_path"; then
        echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
        return 1
	fi

	# check if the $project_name argument is empty
	if [[ -n "${project_name}" ]]; then
		# the project_name is not empty

		# define a pointer to the project_linear_dependencies array variable
		local -n project_linear_dependencies="${project_linear_dependencies_var}"

		# check if the corresponding configuration file exists
		if  [[ -f "${projects_path}/${project_name}/config/project_parent_config.sh" ]]; then

			# unset the current value of the PROJECT_FOLDER_NAME global variable, so it doesn't interfere with the project-specific configuration file that is being loaded
			unset PROJECT_FOLDER_NAME
			
			# load the parent configuration 
			source "${projects_path}/${project_name}/config/project_parent_config.sh"
			
			# check if the PROJECT_FOLDER_NAME is defined
			if [[ -n "${PROJECT_FOLDER_NAME}" ]]; then
				# there is a defined PROJECT_FOLDER_NAME, process it
				
				# recursively call code_shared_define_project_linear_dependencies()
				code_shared_define_project_linear_dependencies "${project_linear_dependencies_var}" "${PROJECT_FOLDER_NAME}" "${projects_path}"
			fi
		fi

		# add the $project_name to the project dependency array
		project_linear_dependencies+=("${project_name}")
	fi
}

# this function will loop through all of the project-specific configuration files and load them in the order they are defined in, based on the project_linear_dependencies array variable
# this function accepts the following arguments:
# 1: project_linear_dependencies array variable name that contains all of the project folder names, ordered from the highest parent to the deepest fork
# 2: projects_path is the absolute path to the /projects folder in the root repository directory
# 3: configuration file name of the type of configuration file that is being loaded (project_manifest_config.sh, project_runtime_config.sh)
function code_shared_load_project_config_files ()
{
	local project_linear_dependencies_var="${1}"
	local projects_path="${2}"
	local configuration_file_name="${3}"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars "project_linear_dependencies_var" "projects_path" "configuration_file_name"; then
        echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
        return 1
	fi
	
	# define a pointer to the project_linear_dependencies array variable
	local -n project_linear_dependencies="${project_linear_dependencies_var}"

	local project_name
	# Iterate over the project_linear_dependencies elements and attempt to execute the hooks for each project in order to respect their dependencies
	for project_name in "${project_linear_dependencies[@]}"; do
		
		# check if the matching configuration file exists in the current project folder
		if [[ -f "${projects_path}/${project_name}/config/${configuration_file_name}" ]]; then

			# the configuration file exists, execute it now:
			echo "the project-specific configuration file exists"

			# load the specified configuration file
			source "${projects_path}/${project_name}/config/${configuration_file_name}"
		fi
	done
}

# this function loads the standard and default CODE configuration files and if the .active_project file is defined it will load the active project configuration
# the function accepts the following arguments:
# 1: include_directory path, this will be used to load the resources based on their relative paths
# 2: execution_type: (client, host, container) to indicate if the function is being executed on a client which loads the bash variables defined in default_CODE_config.sh and the project-specific runtime configuration files, or on the host which loads only the project linear dependency configuration and pre/post CODE configuration files, or on the container that loads only the project linear dependency configuration and pre CODE configuration files
# 3: project_linear_dependencies array variable name
function code_shared_load_CODE_config()
{
	local include_dir_path="${1}"
	local execution_type="${2}"
	local project_linear_dependencies_var="${3}"
	
#	echo "running code_shared_load_CODE_config($@)"
	
	# validate the bash variable values
	if ! cds_shared_validate_required_vars "include_dir_path" "execution_type" "project_linear_dependencies_var"; then
        echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
        return 1
	fi

	# define a pointer to the project_linear_dependencies array variable
	local -n project_linear_dependencies="${project_linear_dependencies_var}"

	local projects_path="${include_dir_path}/../../../../projects"
	local core_config_path="${include_dir_path}/../../../scripts/config"

	# check if the .active_project is defined
	if [[ -f "${projects_path}/.active_project" ]]; then
		# the .active_project is defined, load the corresponding project-specific configuration files

		# include the projects/.active_project to define which project folder is the active project (defines ACTIVE_PROJECT_NAME variable)
		source "${projects_path}/.active_project"

		# define the linear dependency relationship between projects from the $ACTIVE_PROJECT_NAME and the project_parent_config.sh configuration files
		code_shared_define_project_linear_dependencies "${project_linear_dependencies_var}" "${ACTIVE_PROJECT_NAME}" "${projects_path}"

		# notify the user of the linear dependencies
		echo ""
		echo "*****************************************"
		echo "Project Linear Dependencies:"
		echo "(*Note: Projects are listed in parent->child order, where each project is a direct linear dependency of the one immediately to its left)"
		echo "${project_linear_dependencies[@]}"
		echo "*****************************************"
		echo ""
	fi

	# check if this function is running on the client, if so load the runtime configuration
	if [[ "${execution_type}" == "client" ]]; then
		# load the default CODE runtime configuration
		source "${core_config_path}/default_CODE_runtime_config.sh"

		# load the runtime configuration files for all of the projects in the project_linear_dependencies_var array
		code_shared_load_project_config_files "${project_linear_dependencies_var}" "${projects_path}" "project_runtime_config.sh"
	fi

	# load the project manifest files for all of the projects in the project_linear_dependencies_var array
	code_shared_load_project_config_files "${project_linear_dependencies_var}" "${projects_path}" "project_manifest_config.sh"

	# check if this function is running on the host or client, if so load the runtime configuration
	if [[ "${execution_type}" != "container" ]]; then

		# include the CODE configuration that requires the project-specific configurations to be declared first
		source "${core_config_path}/post_CODE_config.sh"
	fi
}