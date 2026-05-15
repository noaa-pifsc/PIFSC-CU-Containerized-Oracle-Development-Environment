#! /bin/bash

# define a list of configuration variables that drive the behavior of the container deployment scripts, this is intended to run first before other .sh configuration files

# define a list of configuration variables that drive the behavior of the container deployment scripts 

##### Container Configuration Variables: #####

	# determine current folder path (core/scripts/config)
	CONFIG_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

	# determine where the designated container subfolder in the local filesystem is (/core/scripts/build):
	BUILD_PATH="${CONFIG_DIR}/../../build"
	
	# define the path to the /core repository subfolder
	CORE_PATH="${CONFIG_DIR}/../.."

	# define the path to the /core/config repository subfolder
	CORE_CONFIG_PATH="${CONFIG_DIR}/../../config"

	# define the path to the root repository folder
	ROOT_PATH="${CONFIG_DIR}/../../.."

	# define the path to the /projects folder
	PROJECTS_PATH="${CONFIG_DIR}/../../../projects"

##### Container Project Configuration Variables: #####

	# define a variable to store the name of the configuration data variable that is passed via STDIN that contains secret values
	SECRET_DATA_VAR_NAME="SECRET_DATA"

	# define a variable to store the name of the associative array containing the secret names and corresponding bash variables
	SECRET_MAPPING_VAR_NAME="SECRET_MAPPING_ARR"

##### Database Configuration: #####

	# container database host
	DBHOST=code-db

	# container database port
	DBPORT=1521

	# container database service name
	DBSERVICENAME=FREEPDB1


##### Project Hierarchy Configuration: #####

# These variables define array that are used to specify custom information about each of the projects in the hierarchy so dependencies can be applied in the corresponding element order

	# define the array to track the fork hierarchy, the first element is the direct CODE fork and every subsequent element is the fork of the previous element. This corresponds to the folder name of the project in the /projects folder
	PROJECT_INHERITANCE=()

	# define the database scripts mapping using the pipe character as a delimiter
	# The elements should contain encoded values with the "|" character as the delimiter: sql path (within container)|sql script file|User Secret Name|Password Secret Name|Script Password Secret (optional when a password is injected into the script - examples include a CREATE USER command) 
	DB_SCRIPTS_MAP=()

	# define the array of non-sensitive environment variable names that are exported for use in the container
	CUSTOM_ENV_VARS=()

	# define the array of compose files that are used by the individual projects
	COMPOSE_FILES=()

##### Container Secret Configuration Variables: #####

	# define an associative array with the secret name as the array element and the bash variable name as the array value, the array element values should match the variable names in secrets.sh
	declare -gA SECRET_MAPPING_ARR=(
		["oracle_pwd"]="ORACLE_PWD"
		["oracle_admin_user"]="ORACLE_ADMIN_USER"
	)
	