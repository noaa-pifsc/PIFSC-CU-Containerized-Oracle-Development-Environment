#! /bin/bash

# define a list of configuration variables that drive the behavior of the container deployment scripts, this is intended to run first before other .sh configuration files

# define a list of configuration variables that drive the behavior of the container deployment scripts 

##### Container Configuration Variables: #####

	# determine current folder path (containerized_oracle_development_environment/deployment_scripts/config)
	declare CONFIG_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

	# determine where the designated container subfolder in the local filesystem is (/containerized_oracle_development_environment):
	declare BUILD_PATH="${CONFIG_DIR}/../../"

##### Container Project Configuration Variables: #####

	#declare a variable to store the name of the configuration data variable that is passed via STDIN that contains secret values
	declare SECRET_DATA_VAR_NAME="SECRET_DATA"

	#declare a variable to store the name of the associative array containing the secret names and corresponding bash variables
	declare SECRET_MAPPING_VAR_NAME="SECRET_MAPPING_ARR"

##### Database Configuration: #####

	# container database host
	declare DBHOST=code-db

	# container database port
	declare DBPORT=1521

	# container database service name
	declare DBSERVICENAME=FREEPDB1
