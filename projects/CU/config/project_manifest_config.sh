#!/bin/bash

	# define the database scripts mapping using the pipe character as a delimiter
	# The elements should contain encoded values with the "|" character as the delimiter: sql path (within container)|sql script file|User Secret Name|Password Secret Name|Script Password Secrets (this can be one or more optional pipe-delimited secret names when a password is injected into the script - examples include a CREATE USER command) 
	
	# create the CU schema
	DB_SCRIPTS_MAP+=("${BUILD_PATH}/../../projects/CU/modules/CU/SQL|@dev_container_setup/create_docker_schemas.sql|oracle_admin_user|oracle_pwd|cen_utils_db_password_secret")

	# populate the CU schema
	DB_SCRIPTS_MAP+=("${BUILD_PATH}/../../projects/CU/modules/CU/SQL|@automated_deployments/deploy_dev_container.sql|cen_utils_db_username_secret|cen_utils_db_password_secret")


	# define the array of compose files that are used by the individual projects (specify the path relative to the core/build directory
	COMPOSE_FILES+=("../../projects/CU/build/cu_secrets.yml")
	
	# add the secrets
		SECRET_MAPPING_ARR+=(
			["cen_utils_db_username_secret"]="DB_CU_USER"
			["cen_utils_db_password_secret"]="DB_CU_PASSWORD"
		)
	
	