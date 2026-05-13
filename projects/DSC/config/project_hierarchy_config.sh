#!/bin/bash

	echo "loading project_hierarchy_config.sh"

	# define the array to track the fork hierarchy, the first element is the direct CODE fork and every subsequent element is the fork of the previous element. This corresponds to the folder name of the project in the /projects folder
	PROJECT_INHERITANCE+=("DSC")

	# define the database credentials mapping using the pipe character as a delimiter
	# the elements should be in the following form: sql path (within container)|sql script file|User Secret Name|Password Secret Name
	DB_SCRIPTS_MAP+=("projects/DSC/modules/DSC/SQL|@dev_container_setup/create_docker_schemas.sql|oracle_admin_user|oracle_admin_pwd")

	DB_SCRIPTS_MAP+=("projects/DSC/modules/DSC/SQL|@automated_deployments/deploy_dev_container.sql|dsc_user|dsc_pwd")

	# define the array of non-sensitive environment variable names that are exported for use in the container
	# CUSTOM_ENV_VARS+=()

	# define the array of compose files that are used by the individual projects
	# COMPOSE_FILES+=()