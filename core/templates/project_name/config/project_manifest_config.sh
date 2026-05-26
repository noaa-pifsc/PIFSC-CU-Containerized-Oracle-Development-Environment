#!/bin/bash

	# define the database scripts mapping using the pipe character as a delimiter
	# The elements should contain encoded values with the "|" character as the delimiter: sql path (within container)|sql script file|User Secret Name|Password Secret Name|Script Password Secrets (this can be one or more optional pipe-delimited secret names when a password is injected into the script - examples include a CREATE USER command) 
	# Example 1:	DB_SCRIPTS_MAP+=("${BUILD_PATH}/../../projects/DSC/modules/DSC/SQL|@dev_container_setup/create_docker_schemas.sql|oracle_admin_user|oracle_pwd|dsc_pwd")
	# Example 2: DB_SCRIPTS_MAP+=("${BUILD_PATH}/../../projects/DSC/modules/DSC/SQL|@automated_deployments/deploy_dev_container.sql|dsc_user|dsc_pwd")

	# define the array of non-sensitive environment variable names that are exported for use in the container
	# Example: CUSTOM_ENV_VARS+=("CRON_SCHEDULE")

	# define the array of compose files that are used by the individual projects (specify the path relative to the core/build directory
	# Example: COMPOSE_FILES+=("../../projects/DSC/build/dsc_secrets.yml")
	
	# add the secrets
	# Example:
	#	SECRET_MAPPING_ARR+=(
	#		["dsc_pwd"]="DSC_PWD"
	#		["dsc_user"]="DSC_USER"
	#	)
	
	