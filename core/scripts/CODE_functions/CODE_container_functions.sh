#!/bin/bash

# Function to compare versions numerically, this function accepts the following parameters:
# 1: first version in the format: [0-9]+(\.[0-9]+)+ 
# 2: second version in the format: [0-9]+(\.[0-9]+)+ 
# 3: Name of the variable to store the result of the comparison: contains 0 if $1 = $2, contains 1 if $1 > $2, contains 2 if $1 < $2
function code_container_version_compare() {
	version1="${1}"
	version2="${2}"
	local -n out_compare_result_ref="${3}"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars	"version1" "version2"; then
		echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
		return 1
	fi
	
	# Split versions into arrays by '.' so the individual major/minor/patch numbers can be compared
	IFS='.' read -ra VER1 <<< "$version1"
	IFS='.' read -ra VER2 <<< "$version2"

	# Iterate through the components of each specified version to compare them
	for ((i=0; i<${#VER1[@]} || i<${#VER2[@]}; i++)); do
		# Use 0 as default if a component is missing (e.g. 24.1 vs 24.1.0)
		# store the current component in the v1 and v2 variablesf for $1 and $2 respectively
		local v1=${VER1[i]:-0}
		local v2=${VER2[i]:-0}
		
		# if the v1 component is greater than the v2 component then $1 is greater
		if (( ${v1} > ${v2} )); then
#			echo "v1 is greater"
			out_compare_result_ref=1
			return 0 # $1 is greater
		elif (( ${v1} < ${v2} )); then	# if the v2 component is greater than the v1 component then $1 is not greater
#			echo "v2 is greater"
			out_compare_result_ref=2
			return 0 # $2 is greater
		fi
	done

#	echo "v1 and v2 are equivalent"
	# If none of the v1 or v2 components were greater/less than the versions are equal
	out_compare_result_ref=0
	return 0 # $1 and $2 are equivalent
}

# function to check if the database is initialized, by checking if the specified APP_SCHEMA_NAME exists in the database
# the function accepts the following parameters:
# 1: the formatted system credentials for the container oracle database instance
# 2: app_schema_name - the schema name that is checked for existence on the database to determine if the database has already been initialized
function code_container_check_database_initialized() {
	local sys_credentials="${1}"
	local app_schema_name="${2}"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars	"sys_credentials" "app_schema_name"; then
		echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
		return 1
	fi

	# Check if your custom schema (e.g., '${app_schema_name}') exists
	echo "SELECT COUNT(*) FROM DBA_USERS WHERE USERNAME = '${app_schema_name}';" | sqlplus -s "${sys_credentials}" | grep -q '1'
}

# function to validate the apex version using a regular expression
# the function accepts the following parameters:
# 1: target_version that is being validated using a regular expression
function code_container_validate_apex_version_format() {
	local target_version="$1"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars	"target_version"; then
		echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
		return 1
	fi

	# validate Apex version format (Strictly X.X, e.g., 23.2, 24.1)
	# the regex ^[0-9]+\.[0-9]+$ ensures exactly one dot separating two integers.
	if [[ ! "$target_version" =~ ^[0-9]+\.[0-9]+$ ]]; then
		echo "Error: ${FUNCNAME[0]}() - Invalid Apex version format: '$target_version'. Expected format: XX.X (e.g., 23.2)"
		exit 1
	fi
}

# function to retrieve the currently installed apex version
# the function accepts the following parameters:
# 1: the formatted system credentials for the container oracle database instance
function code_container_get_installed_apex_version() {
	local sys_credentials="${1}"
	
	# validate the bash variable values
	if ! cds_shared_validate_required_vars "sys_credentials"; then
		echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
		return 1
	fi
	
	# use 'whenever sqlerror exit failure' to catch DB errors
	# direct stderr to /dev/null to avoid capturing error text in the variable
	# query for the current apex version number, if Apex is not installed this query will fail with an ORA- error
	local apex_version
	apex_version=$(sqlplus -s -l "${sys_credentials}" <<EOF 2>/dev/null
		set heading off feedback off pagesize 0 verify off
		whenever sqlerror exit failure
		select version_no from apex_release;
		exit;
EOF
	)

	# trim whitespace from sqlplus query output
	apex_version=$(echo $apex_version | xargs)

	# If the query failed with an ORA- error (e.g. table or view does not exist) or returned an empty result set then default the value of apex_version to 0.0
	if [ -z "$apex_version" ] || [[ "$apex_version" == *"ORA-"* ]]; then
		echo "0.0"	# the query was not successful or returned no value, default to 0.0
	else
		echo ${apex_version}	# return the value of the query result, truncate to remove a trailing zero (e.g. 24.2.0 becomes 24.2)
	fi
}

# function to validate if the apex version actually exists on Oracle's site
# the function accepts the following arguments:
# 1: is the target apex version
# 2: is the apex download URL that will be checked
function code_container_verify_apex_version_exists() {

	local apex_version="${1}"
	local apex_download_url="${2}"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars "apex_version" "apex_download_url"; then
		echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
		return 1
	fi

	# Validate if the apex version actually exists on Oracle's site ---
#	echo "Verifying existence of apex version ${apex_version} on Oracle download site..."

	# Use curl to check headers only, -f causes curl to fail on HTTP errors (like 404), -s is silent mode
	if ! curl --output /dev/null --silent --head --fail "${apex_download_url}"; then
		echo "ERROR: ${FUNCNAME[0]}() - Apex version ${apex_version} does not exist at URL: ${apex_download_url}"
		echo "Please check the apex version number and try again."
		exit 1
	else
		echo "The Apex version ${apex_version} confirmed valid and available for download."
	fi
}

# function to install or upgrade apex based on the current installed version and the target_apex_version environment variable
# this function accepts the following parameters:
# 1: sys_credentials: formatted system database credentials
# 2: sys_password: oracle admin password
# 3: target_apex_version: the specified apex version for the ords container
# 4: dbservicename: the service name for the database container
# 5: deploy_id: the datestamp of the current deployment to uniquely identify it to the code-ords container
function code_container_install_or_upgrade_apex() {

	local sys_credentials="${1}"
	local sys_password="${2}"
	local target_apex_version="${3}"
	local dbservicename="${4}"
	local deploy_id="${5}"
	
	# validate the bash variable values
	if ! cds_shared_validate_required_vars "sys_credentials" "sys_password" "target_apex_version" "dbservicename"; then
		echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
		return 1
	fi

	# Define paths for the dynamic download
	local apex_zip_file_name="apex_${target_apex_version}.zip"
	local apex_zip_path="/tmp/${apex_zip_file_name}"
	local apex_download_url="https://download.oracle.com/otn_software/apex/${apex_zip_file_name}"
	local apex_static_dir="/apex-static" # This is the mount path for the shared apex static files volume

	echo "Target Apex version: ${target_apex_version}"

	# initialize local variables to track if the Apex upgrade should be installed in the database (skip_db_install) and if the static apex files should be updated (skip_file_install)
	local skip_db_install
	local skip_file_install

	# define the function arguments for code_container_process_apex_version()
	local -A process_apex_func_args=(
			["target_apex_version"]="${target_apex_version}"
			["apex_download_url"]="${apex_download_url}"
			["apex_static_dir"]="${apex_static_dir}"
			["skip_db_install_var_name"]="skip_db_install"
			["skip_file_install_var_name"]="skip_file_install"
			["sys_credentials"]="${sys_credentials}"
		)

	# process the apex version to determine which installations (if any) will be executed
	code_container_process_apex_version "process_apex_func_args"
	
	# define the function arguments for code_container_process_apex_install()
	local -A install_upgrade_func_args=(
			["skip_file_install"]="${skip_file_install}"
			["skip_db_install"]="${skip_db_install}"
			["apex_zip_path"]="${apex_zip_path}"
			["apex_download_url"]="${apex_download_url}"
			["apex_static_dir"]="${apex_static_dir}"
			["sys_credentials"]="${sys_credentials}"
			["sys_password"]="${sys_password}"
			["dbservicename"]="${dbservicename}"
			["target_apex_version"]="${target_apex_version}"
			["deploy_id"]="${deploy_id}"
		)

	# process the apex install/upgrade
	code_container_process_apex_install "install_upgrade_func_args"
}

# function to check the apex version to determine if the apex database upgrade 
# This function accepts the following parameters as elements in the specified array name  (arg_array):
# version_status: 0 indicates that the current and target versions are the same, 1 indicates that the target version is higher than the current version and 2 indicates that the target version is lower than the current version
# current_apex_version: the current apex version
# target_apex_version: the target apex version
# apex_static_dir: the file directory for the apex static application files
# out_skip_file_install_var_name: the variable name that will contain a 1 if the apex file upgrade should be skipped and 0 if the apex file upgrade should be installed
# out_skip_db_install_var_name: the variable name that will contain a 1 if the apex DB upgrade should be skipped and 0 if the apex DB upgrade should be installed
function code_container_check_apex_version_status()
{
	# store the function array argument
	local arg_array="${1}"

	# Validation check: ensure the argument is a valid array
	if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
		echo "Error: ${FUNCNAME[0]}() function argument '${arg_array}' is not a valid associative array." >&2
		return 1
	fi

	# validate that the required function argument array elements exist
	if ! cds_shared_validate_required_array_vals "${arg_array}" "version_status" "current_apex_version" "target_apex_version" "apex_static_dir" "out_skip_file_install_var_name" "out_skip_db_install_var_name"; then
		echo "Error: ${FUNCNAME[0]}() function required secure array validation failed" >&2
		return 1
	fi
	
	# create a pointer to the arg_array variable to make it easy to access the argument array values
	local -n arg_ref="${arg_array}"

	# define variable references to the specified variable names
	local -n out_skip_file_install_ref="${arg_ref[out_skip_file_install_var_name]}"
	local -n out_skip_db_install_ref="${arg_ref[out_skip_db_install_var_name]}"

	# set the default values for the file/db installation flag variables
	out_skip_file_install_ref=0
	out_skip_db_install_ref=0

	# check the $version_status to determine if the apex database/files should be upgraded
	if [ "${arg_ref[version_status]}" -eq 2 ]; then
		# downgrade attempt detected, the target_apex_version is less than the current_apex_version
		echo "ERROR: ${FUNCNAME[0]}() - Downgrade detected! Current Apex version is ${arg_ref[current_apex_version]}, but target is ${arg_ref[target_apex_version]}."
		echo "Downgrading Apex via this method is not supported. Exiting."
		exit 1
	elif [ "${arg_ref[version_status]}" -eq 0 ]; then
		# do not upgrade, target_apex_version and current_apex_version are equivalent
		echo "Apex is already at the target version (${arg_ref[current_apex_version]})."

		# update the variable to indicate the apex database upgrade should be skipped
		out_skip_db_install_ref=1
		
		# determine if the apex file installation should be processed and return the flag value (1|0) to out_skip_file_install_ref 
		code_container_check_apex_file_install "out_skip_file_install_ref" "${arg_ref[apex_static_dir]}" "${arg_ref[target_apex_version]}"

#		echo "The value of out_skip_file_install_ref is: ${out_skip_file_install_ref}"
	else
		# upgrade the apex version, target_apex_version is greater than the current_apex_version
		# echo "DEBUG: Apex version mismatch. Found: '${arg_ref[current_apex_version]}'"
		echo "Starting DB Apex upgrade to ${arg_ref[target_apex_version]}..."
		
		# update the variable to indicate the apex database upgrade should be installed
		out_skip_db_install_ref=0

		# determine if the apex file installation should be processed and return the flag value (1|0) to out_skip_file_install_ref 
		code_container_check_apex_file_install "out_skip_file_install_ref" "${arg_ref[apex_static_dir]}" "${arg_ref[target_apex_version]}"
		
#		echo "The value of out_skip_file_install_ref is: ${out_skip_file_install_ref}"
	fi
}

# function that executes the container database deployment scripts
# this includes upgrading apex to the specified version and executing database scripts when the database has not been initialized yet
# This function accepts the following parameters as elements in the specified array name (arg_array): 
# dbhost: database hostname
# dbport: database port
# dbservicename: database service name
# app_schema_name: the schema name that is checked for existence on the database to determine if the database has already been initialized
# target_apex_version: target version of apex that is being used by the ords container
# oracle_pwd_file: the file location for the oracle admin password secret
# ords_enabled: flag to indicate if the ords container is enabled (yes) or not (no)
# deploy_id: the datestamp of the current deployment to uniquely identify it to the code-ords container
# db_scripts_map: the name of an array with each element containing encoded values with the "|" character as the delimiter: sql path (within container)|sql script file|User Secret Name|Password Secret Name
# projects_path: the absolute path to the /projects folder in the root repository directory
# project_inheritance_var: array variable name that stores the inheritance information for the different forked CODE projects related to the current project
function code_container_deploy_database_scripts ()
{
	# store the function array argument
	local arg_array="${1}"

    # Safety check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: ${FUNCNAME[0]}() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi

	# input validation:
	if ! cds_shared_validate_required_array_vals "${arg_array}" "dbhost" "dbport" "dbservicename" "app_schema_name" "oracle_pwd_file" "ords_enabled" "deploy_id" "db_scripts_map" "projects_path" "project_inheritance_var"; then 
        echo "Error: ${FUNCNAME[0]}() function argument validation failed" >&2
        return 1
    fi

	# create a pointer to the arg_array variable to make it easy to access the argument array values
	local -n arg_ref="${arg_array}"

	# store the oracle admin password in a local variable
	local sys_password="$(cat ${arg_ref[oracle_pwd_file]})"
	
	# define the SYS credentials for use in deployment scripts based on environment variables:
	local sys_credentials="SYS/${sys_password}@${arg_ref[dbhost]}:${arg_ref[dbport]}/${arg_ref[dbservicename]} as SYSDBA"

#	echo "Running the custom database/apex deployment process"

	# Wait until the database is available
	echo "Waiting for Oracle Database to be ready..."
	
	# Attempt to connect to the database container with the system credentials and run a select query (SELECT 1 FROM DUAL) that returns "1" if the query is successful. If the connection or query takes 5 or more seconds stop the query and loop again printing out the status notification message
	until echo -e "SET HEADING OFF FEEDBACK OFF\nSELECT 1 FROM DUAL;\nexit;" | timeout 5s sqlplus -s -l "${sys_credentials}" 2>&1 | grep -qw "1"; do
		# log that database query was not successfully processed, wait 5 seconds and try again
		echo "Database not ready, waiting 5 seconds..."
		sleep 5
	done
	
	# log that the database is ready for the automated apex install/upgrade and custom schema/database object deployment
	echo "Database is ready!"
	
	# install or upgrade the apex container installation (if target_apex_version is defined and ords_enabled = yes):
	if [[ "${arg_ref[ords_enabled]}" == "yes" && -n "${arg_ref[target_apex_version]}" ]]; then
		echo "target_apex_version is defined and ORDS is enabled, install/upgrade apex"
		code_container_install_or_upgrade_apex "${sys_credentials}" "${sys_password}" "${arg_ref[target_apex_version]}" "${arg_ref[dbservicename]}" "${arg_ref[deploy_id]}"
	else
		echo "target_apex_version is not defined or ORDS is not enabled, skip apex install/upgrade process"
	fi

#	echo "Checking if the database has been initialized (schema: ${APP_SCHEMA_NAME})..."
	# Check if the database is initialized by querying DBA_USERS
	if ! code_container_check_database_initialized "${sys_credentials}" "${arg_ref[app_schema_name]}"; then
		echo "Database is not initialized, run the custom database and/or application deployment scripts"

		# execute any pre-container hooks
		code_shared_run_project_hooks "post" "container" "${arg_ref[project_inheritance_var]}" "${arg_ref[projects_path]}"

		# run the custom database deployment scripts:
		code_container_deploy_custom_database_scripts "${arg_array}" "${arg_ref[db_scripts_map]}"

		# execute any post-container hooks
		code_shared_run_project_hooks "post" "container" "${arg_ref[project_inheritance_var]}" "${arg_ref[projects_path]}"		
	else
		echo "Database already initialized. Skipping deployment script."
	fi

	echo "All deployment steps complete."
}

# function that processes the current and target versions of apex
# This function accepts the following parameters as elements in the specified array name  (arg_array):
# target_apex_version: the target apex version
# apex_download_url: the download URL for the target apex version
# apex_static_dir: the static apex application directory path
# skip_db_install_var_name: the name of the variable that indicates if the apex database installation will be processed
# skip_file_install_var_name: the name of the variable that indicates if the apex file installation will be processed
# sys_credentials: formatted system database credentials
function code_container_process_apex_version()
{
	# store the function array argument
	local arg_array="${1}"

	# Validation check: ensure the argument is a valid array
	if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
		echo "Error: ${FUNCNAME[0]}() function argument '${arg_array}' is not a valid associative array." >&2
		return 1
	fi

	# validate that the required function argument array elements exist
	if ! cds_shared_validate_required_array_vals "${arg_array}" "target_apex_version" "apex_download_url" "apex_static_dir" "skip_db_install_var_name" "skip_file_install_var_name" "sys_credentials"; then
		echo "Error: ${FUNCNAME[0]}() function required secure array validation failed" >&2
		return 1
	fi

	# create a pointer to the arg_array variable to make it easy to access the argument array values
	local -n arg_ref="${arg_array}"

	# declare local variables for the specified variable names
	local -n skip_db_install_var="${arg_ref[skip_db_install_var_name]}"
	local -n skip_file_install_var="${arg_ref[skip_file_install_var_name]}"

	# Validate Apex version format (e.g., 23.2, 24.1), if it is invalid exit the function
	code_container_validate_apex_version_format "${arg_ref[target_apex_version]}"

	# validate if the specified target_apex_version version actually exists on Oracle's site
	code_container_verify_apex_version_exists "${arg_ref[target_apex_version]}" "${arg_ref[apex_download_url]}"

	# retrieve the current version of Apex by querying the databae
	local current_apex_version="$(code_container_get_installed_apex_version "${arg_ref[sys_credentials]}")"
	
	# echo "DEBUG: Current Apex version: ${current_apex_version}"

	# compare the current and target versions of apex and store the return value in version_status
	local version_status=""
	code_container_version_compare "${arg_ref[target_apex_version]}" "${current_apex_version}" "version_status"
	
	# define the argument array for the code_container_check_apex_version_status() function 
	local -A apex_version_status_func_args=(
			["version_status"]="${version_status}"
			["current_apex_version"]="${current_apex_version}"
			["target_apex_version"]="${arg_ref[target_apex_version]}"
			["apex_static_dir"]="${arg_ref[apex_static_dir]}"
			["out_skip_db_install_var_name"]="${arg_ref[skip_db_install_var_name]}"
			["out_skip_file_install_var_name"]="${arg_ref[skip_file_install_var_name]}"
		)
	
	# check the current/target version to determine if the DB and/or file apex installations should be executed
	code_container_check_apex_version_status "apex_version_status_func_args"
}

# function that processes the apex db and file installation
# This function accepts the following parameters as elements in the specified array name  (arg_array):
# skip_file_install: flag to indicate if the apex file installation should be processed (1) or not (0)
# skip_db_install: flag to indicate if the apex db installation should be processed (1) or not (0)
# apex_zip_path: the path for the dynamic apex zip file local download
# apex_download_url: the dynamic download url for the specified apex version
# apex_static_dir: the designated static apex application files directory
# sys_credentials: formatted system database credentials
# sys_password: oracle admin password
# dbservicename: the database service name for the database container
# target_apex_version: the specified apex version for the ords container
# deploy_id: the datestamp of the current deployment to uniquely identify it to the code-ords container
function code_container_process_apex_install()
{
	# store the function array argument
	local arg_array="${1}"

	# Validation check: ensure the argument is a valid array
	if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
		echo "Error: ${FUNCNAME[0]}() function argument '${arg_array}' is not a valid associative array." >&2
		return 1
	fi

	# validate that the required function argument array elements exist
	if ! cds_shared_validate_required_array_vals "${arg_array}" "skip_file_install" "skip_db_install" "apex_zip_path" "apex_download_url" "apex_static_dir" "sys_credentials" "sys_password" "dbservicename" "target_apex_version" "deploy_id"; then
		echo "Error: ${FUNCNAME[0]}() function required secure array validation failed" >&2
		return 1
	fi
	
	
	# echo "DEBUG: in code_container_process_apex_install() the value of arg_array is: $(cds_shared_dump_array_vals ${arg_array})"
	
	# create a pointer to the arg_array variable to make it easy to access the argument array values
	local -n arg_ref="${arg_array}"

	# check if either Apex installation is required
	if [[ "${arg_ref[skip_file_install]}" -eq 0 || "${arg_ref[skip_db_install]}" -eq 0 ]]; then

		# download and unzip the apex installer
		code_container_download_unzip_apex_installer "${arg_ref[apex_download_url]}" "${arg_ref[apex_zip_path]}"

		# initialize the local variables to support the parallel installation of Apex in the DB and the file system (docker volume)
		local db_install_pid=0
		local db_install_status=0
		local file_install_status=0

		# check if the Apex database installation should proceed
		if [ "${arg_ref[skip_db_install]}" -eq 0 ]; then
			echo "Starting Apex DB installer..."

			# change the current directory so the Apex installation can proceed normally with the relative paths
			cd /tmp/apex

			# Run the DB install in the background by adding '&'
			sqlplus -s -l "${arg_ref[sys_credentials]}" <<EOF &
				WHENEVER SQLERROR EXIT SQL.SQLCODE
				ALTER SESSION SET CONTAINER = ${arg_ref[dbservicename]};
				@apexins.sql SYSAUX SYSAUX TEMP /i/
				exit;
EOF
			db_install_pid=$! # Save the Process ID of the background job
		else
			echo "Skipping Apex database installation since the version is already the same"
		fi

		# check if the apex file installation should proceed
		if [[ "${arg_ref[skip_file_install]}" -eq 0 ]]; then
		
			# install the apex static files
			code_container_install_apex_static_files "${arg_ref[apex_static_dir]}" "file_install_status"
		else
			echo "Skipping Apex file installation since the version is already the same"
		fi

		# wait for background DB install to finish
		if [ "${db_install_pid}" -ne 0 ]; then
			echo "Waiting for Apex DB install (PID: ${db_install_pid}) to finish..."
			wait "${db_install_pid}" # wait for the apex database installation background process to finish
			db_install_status=$?	# store the result of the Apex database installation in a new variable

			# check if the database installation 
			if [ "${db_install_status}" -eq 0 ]; then
				echo "Apex database upgrade was successful"
			else
				echo "Error: ${FUNCNAME[0]}() - Apex database upgrade failed."
				exit 1
			fi
		fi
		
		# Check the results of the apex installation
		if [ "${file_install_status}" -ne 0 ]; then
			echo "Error: ${FUNCNAME[0]}() - Apex file installation failed. Halting."
			exit 1
		fi

		# remove the apex installation files
		echo "Cleaning up installer files..."
		rm -rf /tmp/apex "${arg_ref[apex_zip_path]}"
	fi

	# Ensure database users match ORDS config every time
	# retrieve the current apex version
	local current_apex_version="$(code_container_get_installed_apex_version "${arg_ref[sys_credentials]}")"

	# check if the current version of apex is not 0.0 (indicates it's not installed)
	if [[ "${current_apex_version}" != "0.0" ]]; then

		# configure the apex administrator/service accounts in the database
		code_container_configure_apex_admin "${arg_ref[target_apex_version]}" "${arg_ref[sys_password]}" "${arg_ref[sys_credentials]}" "${arg_ref[dbservicename]}"
	fi

	# apex has finished installing, create the /apex-static/.deploy_read_${arg_ref[deploy_id]} file to indicate that the ords container can start now:
#	echo "Create the new deployment metadata file to indicate that the apex installation has completed: /apex-static/deployments/.deploy_ready_${arg_ref[deploy_id]}"

	mkdir -p "/apex-static/deployments/"	# create the deployments subfolder to not clutter up the apex static folder
	touch "/apex-static/deployments/.deploy_ready_${arg_ref[deploy_id]}"	
}

# function that moves the static application files to the designated folder
# the function accepts the following arguments:
# 1: apex_static_dir: the mount path for the shared apex static files volume
# 2: file_install_status_name: the variable name that stores the file_install_status value (0 when successful, 1 if not)
function code_container_install_apex_static_files ()
{
	local apex_static_dir="${1}"
	local file_install_status_name="${1}"
	local -n file_install_status_ref="${2}"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars	"apex_static_dir" "file_install_status_name"; then
        echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
        return 1
	fi

	# copy the Apex static images to the shared docker volume in the foreground
	echo "Copying Apex static images to shared volume..."
	
	# Clear out any old static Apex files 
	rm -rf "${apex_static_dir}"/*

	# Move the contents of the images folder to the root of the volume
	mv /tmp/apex/images/* "${apex_static_dir}"/

	# store the results of the file move process in file_install_status so the result can be checked
	local file_install_status=$? 
	if [ "${file_install_status}" -eq 0 ]; then
		echo "Static files copied successfully."
		
		# update owner permissions on the docker volume to the oracle account so the static Apex files can be used by the ords container
		chown -R 54321:0 "${apex_static_dir}"/
	else
		echo "Error: ${FUNCNAME[0]}() - Static file copy failed."
	fi
}

# function to download the specified apex installer and unzip it for db/file installations
# the function accepts the following parameters:
# 1: apex_download_url: the dynamic download url for the specified apex version
# 2: apex_zip_path: the path for the dynamic apex zip file local download
function code_container_download_unzip_apex_installer()
{
	local apex_download_url="${1}"
	local apex_zip_path="${2}"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars	"apex_download_url" "apex_zip_path"; then
        echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
        return 1
	fi

	# the apex package does not dynamically download and install the apex installation package
	echo "Downloading ${apex_download_url}..."
	curl -L -o "${apex_zip_path}" "${apex_download_url}"
	if [ $? -ne 0 ]; then
		echo "Error: ${FUNCNAME[0]}() - Download of Apex zip file failed."
		exit 1
	fi

	echo "Apex upgrade package download complete."
	
	echo "Unzipping ${apex_zip_path}..."
	unzip -q "${apex_zip_path}" -d /tmp
	if [ $? -ne 0 ]; then
		echo "Error: ${FUNCNAME[0]}() - Failed to unzip Apex file."
		exit 1
	fi
}

# this function configures the apex administrator/service accounts in the database
# This function accepts the following parameters as elements in the specified array name  (arg_array):
# 1: target_apex_version: the specified apex version for the ords container
# 2: sys_password: oracle admin password
# 3: sys_credentials: formatted system database credentials
# 4: dbservicename: the database service name for the database container
function code_container_configure_apex_admin()
{
	local target_apex_version="${1}"
	local sys_password="${2}"
	local sys_credentials="${3}"
	local dbservicename="${4}"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars	"target_apex_version" "sys_password" "sys_credentials" "dbservicename"; then
        echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
        return 1
	fi

	# declare the variable to store the version status code returned by the code_container_version_compare() function
	local version_status
	
	# check if the target apex version is less than 23.2
	code_container_version_compare "${target_apex_version}" "23.2" "version_status"
	
	if [ "${version_status}" -eq 2 ]; then 
		# apex version is 23.1 or less

		# define a PL/SQL block to unlock the apex admin using the APEX_UTIL.RESET_PASSWORD procedure
		UNLOCK_BLOCK="
			BEGIN
				APEX_UTIL.set_security_group_id(10);
				APEX_UTIL.reset_password(
					p_user_name => 'ADMIN',
					p_old_password => NULL,
					p_new_password => '${sys_password}',
					p_change_password_on_first_use => FALSE
				);
				COMMIT;
			EXCEPTION WHEN OTHERS THEN
				 NULL;
			END;
		"
	
	else
		# apex version is 23.2 or higher
		
		# define a PL/SQL block to unlock the apex admin using the APEX_INSTANCE_ADMIN.UNLOCK_USER procedure
		UNLOCK_BLOCK="
			BEGIN
				APEX_INSTANCE_ADMIN.UNLOCK_USER(
					p_workspace => 'INTERNAL',
					p_username	=> 'ADMIN',
					p_password	=> '${sys_password}'
				);
				COMMIT;
			EXCEPTION WHEN OTHERS THEN
				 -- Fallback or ignore if user doesn't exist yet (should not happen here)
				 NULL;
			END;
		"
	
	fi
	
	# The Apex upgrade completed, unlock the APEX_PUBLIC_USER account and attempt to create the Apex instance admin account or if it already exists then reset the password to sys_password

	# run the sqlplus script using the SYS schema
	echo "Unlocking/Initializing/Configuring Apex accounts..."
	
	sqlplus -s -l "${sys_credentials}" <<EOF
	WHENEVER SQLERROR EXIT SQL.SQLCODE
	ALTER SESSION SET CONTAINER = ${dbservicename};
	-- Update the APEX_PUBLIC_USER and ORDS_PUBLIC_USER schema passwords to the system password, query the database to confirm the schema exists before attempting to set the password 
	BEGIN
		-- query for the APEX_PUBLIC_USER and ORDS_PUBLIC_USER users in the database, if they exist update the password to the user-specified admin password
		for rec in (SELECT USERNAME from DBA_USERS where USERNAME IN ('APEX_PUBLIC_USER', 'ORDS_PUBLIC_USER')) LOOP
			--set the current schema password
			EXECUTE IMMEDIATE 'ALTER USER '||rec.USERNAME||' IDENTIFIED BY "${sys_password}" ACCOUNT UNLOCK';
		END LOOP;
	END;
	/
	SET SERVEROUTPUT ON
	
	-- Switch to the Apex schema to perform admin tasks
	DECLARE
		v_apex_schema VARCHAR2(30);
	BEGIN
		SELECT schema INTO v_apex_schema FROM dba_registry WHERE comp_id = 'APEX';
		EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA = ' || dbms_assert.enquote_name(v_apex_schema);
	END;
	/

	-- Disable Strong Password Requirement (For Dev Environment)
	BEGIN
		APEX_INSTANCE_ADMIN.SET_PARAMETER('STRONG_SITE_ADMIN_PASSWORD', 'N');
		COMMIT;
	END;
	/

	-- Set the ADMIN password for the INTERNAL workspace (based on ORACLE_PWD variable)
	BEGIN
		DBMS_OUTPUT.PUT_LINE('Create the Apex admin user');
	
		APEX_UTIL.set_security_group_id(10);
		APEX_UTIL.create_user(
			p_user_name => 'ADMIN',
			p_email_address => 'admin@localhost',
			p_web_password=> '${sys_password}',
			p_developer_privs => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
			p_change_password_on_first_use => 'N' -- Ensure no forced change password
		);

		DBMS_OUTPUT.PUT_LINE('Apex admin user created successfully');

		COMMIT;
	EXCEPTION WHEN OTHERS THEN
		-- If apex admin user already exists, just reset the password (based on ORACLE_PWD variable defined in .env file)

		-- Run the appropriate unlock/reset block
		${UNLOCK_BLOCK}

		COMMIT;
	END;
	/
	exit;
EOF

	# check the result of the sqlplus commands
	if [ $? -eq 0 ]; then
		echo "Apex setup completed successfully."
	else
		echo "Error: ${FUNCNAME[0]}() - Apex setup failed."
		exit 1
	fi

}


# this function checks if the apex file version is the same as the target_apex_version, if so it will return out_skip_file_install=1 to indicate that the file installation should be skipped, if not it will return out_skip_file_install=0
# the function accepts the following arguments:
# 1: skip_file_install_var_name: the name of the variable to store the 
# 2: 
function code_container_check_apex_file_install ()
{
	local skip_file_install_var_name="${1}"
	local apex_static_dir="${2}"
	local target_apex_version="${3}"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars "skip_file_install_var_name" "apex_static_dir" "target_apex_version"; then
		echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
		return 1
	fi

	# define a pointer to the local variable that indicates if the apex file installation should be skipped or not
	local -n skip_file_install_ref="${1}"

	# Check if static files are also in place
	if [ -f "${apex_static_dir}/apex_version.txt" ]; then
		# static Apex files are in place

#		echo "Apex files are in place, check if the version matches the target_apex_version"

		# parse the apex version number for the static application files from the apex_version.txt static file
		apex_static_files_ver=$(grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' "${apex_static_dir}/apex_version.txt")

#		echo "The value of the apex_static_files_ver is: ${apex_static_files_ver}" 

		# check if the apex files version matches the target apex version
		if [[ "${target_apex_version}" == "${apex_static_files_ver}" ]]; then
			# the apex files version is the same as the target apex version
		
			echo "The version of the Apex files and the target apex version are the same, do not install the apex static files"
		
			# update the variable to indicate the apex file upgrade should be skipped
			out_skip_file_install_ref=1
		else
			echo "The version of the Apex static files is not the same as the target apex version, download and install the static files"
			out_skip_file_install_ref=0
		fi
	fi
}

# this function executes the series of commands defined in the db_scripts_map array argument
# the function accepts the following arguments:
# 1: arg_array
# This function accepts the following parameters as elements in the specified array name (arg_array): 
# dbhost: database hostname
# dbport: database port
# dbservicename: database service name
# 2: db_scripts_map: the name of an array with each element containing encoded values with the "|" character as the delimiter: sql path (within container)|sql script file|User Secret Name|Password Secret Name|Script Password Secret (optional when a password is injected into the script - examples include a CREATE USER command) 
function code_container_deploy_custom_database_scripts()
{
	echo "running code_container_deploy_custom_database_scripts($@)"

	# store the function array argument
	local arg_array="${1}"
	local db_scripts_map="${2}"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars "arg_array" "db_scripts_map"; then
		echo "Error: ${FUNCNAME[0]}() function required bash variable validation failed" >&2
		return 1
	fi

    # Safety check: ensure the argument is a valid array
    if [[ "$(declare -p "${arg_array}" 2>/dev/null)" != "declare -A"* ]]; then
        echo "Error: ${FUNCNAME[0]}() function argument '${arg_array}' is not a valid associative array." >&2
        return 1
    fi

	# input validation:
	if ! cds_shared_validate_required_array_vals "${arg_array}" "dbhost" "dbport" "dbservicename"; then 
        echo "Error: ${FUNCNAME[0]}() function argument validation failed" >&2
        return 1
    fi

	# create a pointer to the arg_array variable to make it easy to access the argument array values
	local -n arg_ref="${arg_array}"

	# define a pointer for the db_scripts_map array:
	local -n db_scripts_map_ref="${db_scripts_map}"

	# loop through each of the database commands
	for entry in "${db_scripts_map_ref[@]}"; do
		echo "process the current database command: ${entry}"

		# parse the pipe-delimited string and store them in separate variables
        IFS='|' read -r script_path script_command user_secret_name pass_secret_name script_password_secret <<< "$entry"
	
		# store the corresponding username secret
		local username=$(cat "/run/secrets/${user_secret_name}")
	
		# store the corresponding password secret
		local password=$(cat "/run/secrets/${pass_secret_name}")

		# check if the script_password_secret variable is not empty and if the corresponding secret exists
		if [[ -n "${script_password_secret}" && -f "/run/secrets/${script_password_secret}" ]]; then
			# the script password secret exists, store the secret in pass_secret so it can be injected into the script
			local pass_secret=$(cat "/run/secrets/${script_password_secret}")
		else
			# the script password secret does not exist, set the variable to the blank string
			local pass_secret=""
		fi

		# construct the connection string:
		local connection_string="${username}/${password}@${arg_ref[dbhost]}:${arg_ref[dbport]}/${arg_ref[dbservicename]}"

		# change to the script_path to run the script_command
		cd "${script_path}"
		
# use sqlplus to run the current script_command		
sqlplus -s /nolog <<EOF
${script_command} "${connection_string}" "${pass_secret}"
EOF
	
		# check return code for sqlplus query
		if [ $? -ne 0 ]; then
			echo "Error: SQL execution failed for ${script_command}"
			return 1
		fi	
	
	done
}