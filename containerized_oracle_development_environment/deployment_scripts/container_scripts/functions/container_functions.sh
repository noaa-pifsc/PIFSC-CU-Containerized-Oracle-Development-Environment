#!/bin/bash

# Function to compare versions numerically, this function accepts the following parameters:
# 1: first version in the format: [0-9]+(\.[0-9]+)+ 
# 2: second version in the format: [0-9]+(\.[0-9]+)+ 
# 3: Name of the variable to store the result of the comparison: contains 0 if $1 = $2, contains 1 if $1 > $2, contains 2 if $1 < $2
function proj_container_version_compare() {
	echo "running proj_container_version_compare(${1}, ${2}, ${3})"

	version1="${1}"
	version2="${2}"
	local -n out_compare_result_ref="${3}"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars	"version1" "version2"; then
        echo "Error: proj_container_version_compare() function required bash variable validation failed" >&2
        return 1
	fi
	
	# Split versions into arrays by '.' so the individual major/minor/patch numbers can be compared
	IFS='.' read -ra VER1 <<< "$1"
	IFS='.' read -ra VER2 <<< "$2"

	# Iterate through the components of each specified version to compare them
	for ((i=0; i<${#VER1[@]} || i<${#VER2[@]}; i++)); do
		# Use 0 as default if a component is missing (e.g. 24.1 vs 24.1.0)
		# store the current component in the v1 and v2 variablesf for $1 and $2 respectively
		local v1=${VER1[i]:-0}
		local v2=${VER2[i]:-0}
		
		echo "The value of v1 is: ${v1}"
		echo "The value of v2 is: ${v2}"
		
		# if the v1 component is greater than the v2 component then $1 is greater
		if (( ${v1} > ${v2} )); then
			echo "v1 is greater"
			out_compare_result_ref=1
			return 0 # $1 is greater
		elif (( ${v1} < ${v2} )); then	# if the v2 component is greater than the v1 component then $1 is not greater
			echo "v2 is greater"
			out_compare_result_ref=2
			return 0 # $2 is greater
		fi
	done

	echo "v1 and v2 are equivalent"
	# If none of the v1 or v2 components were greater/less than the versions are equal
	out_compare_result_ref=0
	return 0 # $1 and $2 are equivalent
}

# function to check if the database is initialized, by checking if the specified APP_SCHEMA_NAME exists in the database
# the function accepts the following parameters:
# 1: the formatted system credentials for the container oracle database instance
function proj_container_check_database_initialized() {
	local sys_credentials="${1}"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars	"sys_credentials" "APP_SCHEMA_NAME"; then
        echo "Error: proj_container_check_database_initialized() function required bash variable validation failed" >&2
        return 1
	fi

	# Check if your custom schema (e.g., '${APP_SCHEMA_NAME}') exists
	echo "SELECT COUNT(*) FROM DBA_USERS WHERE USERNAME = '${APP_SCHEMA_NAME}';" | sqlplus -s "${sys_credentials}" | grep -q '1'
}

# function to validate the apex version using a regular expression
function proj_container_validate_apex_version_format() {
	local target_version="$1"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars	"target_version"; then
        echo "Error: proj_container_validate_apex_version_format() function required bash variable validation failed" >&2
        return 1
	fi

	# validate APEX version format (Strictly X.X, e.g., 23.2, 24.1)
	# the regex ^[0-9]+\.[0-9]+$ ensures exactly one dot separating two integers.
	if [[ ! "$target_version" =~ ^[0-9]+\.[0-9]+$ ]]; then
		echo "ERROR: Invalid APEX version format: '$target_version'. Expected format: XX.X (e.g., 23.2)"
		exit 1
	fi
}

# function to retrieve the currently installed apex version
function proj_container_get_installed_apex_version() {

	local sys_credentials="${1}"
	
	# validate the bash variable values
	if ! cds_shared_validate_required_vars "sys_credentials"; then
        echo "Error: proj_container_get_installed_apex_version() function required bash variable validation failed" >&2
        return 1
	fi
	

	# use 'whenever sqlerror exit failure' to catch DB errors
	# direct stderr to /dev/null to avoid capturing error text in the variable
	# query for the current apex version number, if APEX is not installed this query will fail with an ORA- error
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
# $1 is the target apex version
# $2 is the apex download URL that will be checked
function proj_container_verify_apex_version_exists() {

	# Validate if the apex version actually exists on Oracle's site ---
	echo "Verifying existence of apex version ${1} on Oracle download site..."

	# Use curl -I (head request) to check headers only, -f causes curl to fail on HTTP errors (like 404), -s is silent mode
	if ! curl --output /dev/null --silent --head --fail "${2}"; then
		echo "ERROR: APEX version ${1} does not exist at URL: ${2}"
		echo "Please check the apex version number and try again."
		exit 1
	else
		echo "The APEX version ${1} confirmed valid and available for download."
	fi
}


# function to install or upgrade apex based on the current installed version and the TARGET_APEX_VERSION environment variable
# this function accepts the following parameters:
# 1: sys_credentials: formatted system database credentials
# 2: oracle admin password
function proj_container_install_or_upgrade_apex() {

	local sys_credentials="${1}"
	local sys_pwd="${2}"
	
	# validate the bash variable values
	if ! cds_shared_validate_required_vars "sys_credentials" "sys_pwd"; then
        echo "Error: proj_container_install_or_upgrade_apex() function required bash variable validation failed" >&2
        return 1
	fi

	# Define paths for the dynamic download
	local apex_zip_file_name="apex_${TARGET_APEX_VERSION}.zip"
	local apex_zip_path="/tmp/${apex_zip_file_name}"
	local apex_download_url="https://download.oracle.com/otn_software/apex/${apex_zip_file_name}"
	local apex_static_dir="/apex-static" # This is the mount path for the shared apex static files volume

	echo "Target Apex version: ${TARGET_APEX_VERSION}"

	# initialize local variables to track if the Apex upgrade should be installed in the database (skip_db_install) and if the static apex files should be updated (skip_file_install)
	local skip_db_install=0
	local skip_file_install=0

	# process the apex version to determine which installations (if any) will be executed
	proj_process_apex_version "${TARGET_APEX_VERSION}" "${apex_download_url}" "${apex_static_dir}" "skip_db_install" "skip_file_install" "${sys_credentials}"

	echo "The value of skip_db_install is: ${skip_db_install}"
	echo "The value of skip_file_install is: ${skip_file_install}"

	proj_container_process_apex_install "${skip_file_install}" "${skip_db_install}" "${apex_zip_path}" "${apex_download_url}" "${apex_static_dir}" "${sys_credentials}" "${sys_pwd}"
}

# function to check the apex version to determine if the apex database upgrade (stored in the variable named ${out_skip_db_install_var_name}) and/or the apex file upgrade (stored in the variable named ${out_skip_file_install_var_name}) should occur
function proj_container_check_apex_version_status()
{
	echo "running proj_container_check_apex_version_status()"

	local version_status="${1}"
	local current_apex_version="${2}"
	local target_apex_version="${3}"
	local apex_static_dir="${4}"
	local out_skip_file_install_var_name="${5}"
	local out_skip_db_install_var_name="${6}"
	
	
	# validate the bash variable values
	if ! cds_shared_validate_required_vars	"version_status" "current_apex_version" "target_apex_version" "apex_static_dir" "out_skip_file_install_var_name" "out_skip_db_install_var_name"; then
        echo "Error: proj_container_check_apex_version_status() function required bash variable validation failed" >&2
        return 1
	fi

	# define variable references to the specified variable names
	local -n out_skip_file_install_ref="${out_skip_file_install_var_name}"
	local -n out_skip_db_install_ref="${out_skip_db_install_var_name}"

	# check the $version_status to determine if the apex database/files should be upgraded
	if [ ${version_status} -eq 2 ]; then
		# downgrade attempt detected, the target_apex_version is less than the current_apex_version
		echo "ERROR: Downgrade detected! Current APEX version is ${current_apex_version}, but target is ${target_apex_version}."
		echo "Downgrading APEX via this method is not supported. Exiting."
		exit 1
	elif [ ${version_status} -eq 0 ]; then
		# do not upgrade, target_apex_version and current_apex_version are equivalent
		echo "APEX is already at the target version (${current_apex_version})."
		
		# Check if static files are also in place
		if [ -f "${apex_static_dir}/apex_version.js" ]; then
			echo "Static files are in place. No upgrade needed."
			# update the variable to indicate the apex file upgrade should be skipped
			out_skip_file_install_ref=1
		else
			echo "APEX DB is upgraded, but static files are missing."
			echo "Will attempt to download/unzip/copy static files..."
			# update the variable to indicate the apex database upgrade should be skipped
			out_skip_db_install_ref=1
		fi
	else
		# upgrade the apex version, target_apex_version is greater than the current_apex_version
		echo "APEX version mismatch. Found: '${current_apex_version}'"
		echo "Starting APEX upgrade to ${target_apex_version}..."
		
		# update the variable to indicate the apex database upgrade should be installed
		out_skip_db_install_ref=0
	fi
}

# function that executes the container database deployment scripts
# this includes upgrading apex to the specified version and executing database scripts when the database has not been initialized yet
# the function accepts the following arguments:
# 1: parsed_secrets_var_name: the variable name of the parsed secrets local associative array
function proj_container_deploy_database_scripts ()
{
	local parsed_secrets_var_name="${1}"
	# declare a pointer to the parsed secrets associative array
	local -n parsed_secrets_ref="${parsed_secrets_var_name}"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars "parsed_secrets_var_name" "DBHOST" "DBPORT" "DBSERVICENAME" "APP_SCHEMA_NAME"; then
        echo "Error: proj_container_deploy_database_scripts() function required bash variable validation failed" >&2
        return 1
	fi

	# store the oracle admin password in a local variable
	local sys_pwd="${parsed_secrets_ref[sys_password]:-}"
	
	echo "The value of sys_pwd is: ${sys_pwd}"
	
	# define the SYS credentials for use in deployment scripts based on environment variables:
	local sys_credentials="SYS/${sys_pwd}@${DBHOST}:${DBPORT}/${DBSERVICENAME} as SYSDBA"

	echo "The value of sys_credentials is: ${sys_credentials}"

	echo "Running the custom database/apex deployment process"

	# define a query to check if APEX is installed
	APEX_QUERY="SELECT COUNT(*) FROM DBA_REGISTRY WHERE COMP_ID = 'APEX' AND STATUS = 'VALID';"

	# Wait until the database is available
	echo "Waiting for Oracle Database to be ready..."
	until echo "exit" | sqlplus -s "${sys_credentials}" > /dev/null; do
		echo "Database not ready, waiting 5 seconds..."
		sleep 5
	done
	echo "Database is ready!"

	# install or upgrade the apex container installation (if TARGET_APEX_VERSION is defined):
	if [ -n "${TARGET_APEX_VERSION}" ]; then
		echo "TARGET_APEX_VERSION is defined, install/upgrade apex"
		proj_container_install_or_upgrade_apex "${sys_credentials}" "${sys_pwd}"
	else
		echo "TARGET_APEX_VERSION is not defined, skip apex install/upgrade process"

	fi

	echo "Checking if the database has been initialized (schema: ${APP_SCHEMA_NAME})..."
	# Check if the database is initialized by querying DBA_USERS
	if ! proj_container_check_database_initialized "${sys_credentials}"; then
		echo "Database is not initialized, run the custom database and/or application deployment scripts"

		# run the custom database deployment scripts:
		# function that executes database scripts within the container
		proj_container_database_deploy_custom_scripts

	else
		echo "Database already initialized. Skipping deployment script."
	fi

	echo "All deployment steps complete."
}

# function that processes the current and target versions of apex
# the function accepts the following arguments:
# 1: target_apex_version: the target apex version
# 2: apex_download_url: the download URL for the target apex version
# 3: apex_static_dir: the static apex application directory path
# 4: skip_db_install_var_name: the name of the variable that indicates if the apex database installation will be processed
# 5: skip_file_install_var_name: the name of the variable that indicates if the apex file installation will be processed
# 6: sys_credentials: formatted system database credentials
function proj_process_apex_version()
{
	local target_apex_version="${1}"
	local apex_download_url="${2}"
	local apex_static_dir="${3}"

	local skip_db_install_var_name="${4}"
	local skip_file_install_var_name="${5}"

	local -n skip_db_install_var="${4}"
	local -n skip_file_install_var="${5}"
	
	local sys_credentials="${6}"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars	"target_apex_version" "apex_download_url" "apex_static_dir" "skip_db_install_var_name" "skip_file_install_var_name" "sys_credentials"; then
        echo "Error: proj_process_apex_version() function required bash variable validation failed" >&2
        return 1
	fi

	# Validate APEX version format (e.g., 23.2, 24.1), if it is invalid exit the function
	proj_container_validate_apex_version_format "${target_apex_version}"

	# validate if the specified target_apex_version version actually exists on Oracle's site
	proj_container_verify_apex_version_exists "${target_apex_version}" "${apex_download_url}"

	# retrieve the current version of Apex by querying the databae
	local current_apex_version="$(proj_container_get_installed_apex_version "${sys_credentials}")"
	echo "Current Apex version: ${current_apex_version}"

	# compare the current and target versions of apex and store the return value in version_status
	local version_status=""
	proj_container_version_compare "${target_apex_version}" "${current_apex_version}" "version_status"
	
	echo "The value of version_status is: ${version_status}"

	# check the current/target version to determine if the DB and/or file apex installations should be executed
	proj_container_check_apex_version_status "${version_status}" "${current_apex_version}" "${target_apex_version}" "${apex_static_dir}" "${skip_db_install_var_name}" "${skip_file_install_var_name}"

}

# function that processes the apex db and file installation
# the function accepts the following parameters:
# 1: skip_file_install: flag to indicate if the apex file installation should be processed (1) or not (0)
# 2: skip_db_install: flag to indicate if the apex db installation should be processed (1) or not (0)
# 3: apex_zip_path: the path for the dynamic apex zip file local download
# 4: apex_download_url: the dynamic download url for the specified apex version
# 5: apex_static_dir: the designated static apex application files directory
# 6: sys_credentials: formatted system database credentials
# 7: oracle admin password
function proj_container_process_apex_install()
{
	local skip_file_install="${1}"
	local skip_db_install="${2}"
	local apex_zip_path="${3}"
	local apex_download_url="${4}"
	local apex_static_dir="${5}"
	local sys_credentials="${6}"
	local sys_pwd="${7}"

	# validate the bash variable values
	if ! cds_shared_validate_required_vars	"skip_file_install" "skip_db_install" "apex_zip_path" "apex_download_url" "apex_static_dir" "sys_credentials" "sys_pwd"; then
        echo "Error: proj_container_process_apex_install() function required bash variable validation failed" >&2
        return 1
	fi

	# check if the static Apex files should be installed
	if [[ "${skip_file_install}" -ne 1 ]]; then

		# the apex package does not dynamically download and install the apex installation package
		echo "Downloading ${apex_download_url}..."
		curl -L -o "${apex_zip_path}" "${apex_download_url}"
		if [ $? -ne 0 ]; then
			echo "ERROR: Download of APEX zip file failed."
			exit 1
		fi

		echo "Apex upgrade package download complete."
		
		echo "Unzipping ${apex_zip_path}..."
		unzip -q "${apex_zip_path}" -d /tmp
		if [ $? -ne 0 ]; then
			echo "ERROR: Failed to unzip APEX file."
			exit 1
		fi
		
		# change the current directory so the Apex installation can proceed normally with the relative paths
		cd /tmp/apex

		# initialize the local variables to support the parallel installation of Apex in the DB and the file system (docker volume)
		local db_install_pid=0
		local db_install_status=0
		local file_copy_status=0

		# check if the Apex database installation should proceed
		if [ $skip_db_install -eq 0 ]; then
			echo "Starting APEX DB installer (in background)..."

			# Run the DB install in the background by adding '&'
			sqlplus -s -l "${sys_credentials}" <<EOF &
				WHENEVER SQLERROR EXIT SQL.SQLCODE
				ALTER SESSION SET CONTAINER = ${DBSERVICENAME};
				@apexins.sql SYSAUX SYSAUX TEMP /i/
				exit;
EOF
			db_install_pid=$! # Save the Process ID of the background job
		else
			echo "Skipping Apex database installation since the version is already the same"
		fi

		# copy the Apex static images to the shared docker volume in the foreground
		echo "Copying APEX static images to shared volume (in foreground)..."
		
		# Clear out any old static Apex files 
		rm -rf "${apex_static_dir}"/*

		# Move the contents of the images folder to the root of the volume
		mv /tmp/apex/images/* "${apex_static_dir}"/

		# store the results of the file move process in file_copy_status so the result can be checked
		local file_copy_status=$? 
		if [ "${file_copy_status}" -eq 0 ]; then
			echo "Static files copied successfully."
			
			# update owner permissions on the docker volume to the oracle account so the static Apex files can be used by the ords container
			chown -R 54321:0 "${apex_static_dir}"/
		else
			echo "ERROR: Static file copy failed."
		fi

		# wait for background DB install to finish
		if [ "${db_install_pid}" -ne 0 ]; then
			echo "Waiting for APEX DB install (PID: ${db_install_pid}) to finish..."
			wait "${db_install_pid}"
				local db_install_status=$?	# store the result of the Apex database installation in a new variable

			# check if the database installation 
			if [ "${db_install_status}" -eq 0 ]; then
				echo "APEX database upgrade successful."
				
				# declare the variable to store the version status code returned by the proj_container_version_compare() function
				local version_status
				
				# check if the target apex version is less than 23.2
				proj_container_version_compare "${TARGET_APEX_VERSION}" "23.2" "version_status"
				
				if [ "${version_status}" -eq 2 ]; then 
					# apex version is 23.1 or older

					# define a PL/SQL block to unlock the apex admin using the APEX_UTIL.RESET_PASSWORD procedure
					UNLOCK_BLOCK="
						BEGIN
							APEX_UTIL.set_security_group_id(10);
							APEX_UTIL.reset_password(
								p_user_name => 'ADMIN',
								p_old_password => NULL,
								p_new_password => '${sys_pwd}',
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
								p_password	=> '${sys_pwd}'
							);
							COMMIT;
						EXCEPTION WHEN OTHERS THEN
							 -- Fallback or ignore if user doesn't exist yet (should not happen here)
							 NULL;
						END;
					"
				
				fi
				
				# The APEX upgrade completed, unlock the APEX_PUBLIC_USER account and attempt to create the APEX instance admin account or if it already exists then reset the password to ${ORACLE_PWD}

				# run the sqlplus script using the SYS schema
				echo "Unlocking/Initializing/Configuring APEX accounts..."
				
				sqlplus -s -l "${sys_credentials}" <<EOF
				WHENEVER SQLERROR EXIT SQL.SQLCODE
				ALTER SESSION SET CONTAINER = ${DBSERVICENAME};
				-- Use the same password for all internal accounts for simplicity
				ALTER USER APEX_PUBLIC_USER IDENTIFIED BY "${sys_pwd}" ACCOUNT UNLOCK;
				SET SERVEROUTPUT ON
				
				-- Switch to the APEX schema to perform admin tasks
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

				-- Set the ADMIN password for the INTERNAL workspace (based on ORACLE_PWD variable defined in .env file)
				BEGIN
					DBMS_OUTPUT.PUT_LINE('Create the APEX admin user');
				
					APEX_UTIL.set_security_group_id(10);
					APEX_UTIL.create_user(
						p_user_name => 'ADMIN',
						p_email_address => 'admin@localhost',
						p_web_password=> '${sys_pwd}',
						p_developer_privs => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
						p_change_password_on_first_use => 'N' -- Ensure no forced change password
					);

					DBMS_OUTPUT.PUT_LINE('APEX admin user created successfully');

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
					echo "APEX setup completed successfully."
				else
					echo "ERROR: APEX setup failed."
					exit 1
				fi
				
			else
				echo "ERROR: Background APEX database upgrade failed."
			fi
		fi
		
		# Check the results of the background and foreground jobs 
		if [ "${db_install_status}" -ne 0 ] || [ "${file_copy_status}" -ne 0 ]; then
			echo "ERROR: One or more upgrade tasks failed. Halting."
			exit 1
		fi

		# remove the apex installation files
		echo "Cleaning up installer files..."
		rm -rf /tmp/apex "${apex_zip_path}"
	fi



}
