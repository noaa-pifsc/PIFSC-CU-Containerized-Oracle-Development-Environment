#!/bin/sh

##### Container Configuration Variables: #####

	# declare the project name, this must be unique to run more than one instance of CODE on a given container host machine
	declare COMPOSE_PROJECT_NAME=code_base

	#--- Container Port Configuration ---
	declare DB_HOST_PORT=1521
	declare ORDS_HOST_PORT=8181

	#--- Container Image Configuration ---
	declare DB_IMAGE=container-registry.oracle.com/database/free:latest
	declare ORDS_IMAGE=container-registry.oracle.com/database/ords:latest

	#--- APEX Configuration ---
	# Set the target APEX version here, if this variable is not defined apex will not be installed
	declare TARGET_APEX_VERSION=23.2

	# declare if the ORDS service is enabled (required for Apex/ORDS functionality)
	declare ORDS_ENABLED="yes"

	#--- Primary schema created by deployment script, used to check if the database is installed. If the APP_SCHEMA_NAME exists then do not run the database initialization processes ---
	declare APP_SCHEMA_NAME=MY_APP_SCHEMA

##### Project Configuration Variables: #####

	# define the container git project URL
	declare GIT_URL="--branch Branch_CODE_v1.4_CDD_install git@github.com:noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment.git"

##### Container Host Configuration Variables: #####

	# define the privileged container user
	declare PRIV_USER="docker-user"

	# define the container server hostname configuration information
	declare HOSTNAME="pifsc-dev-docker-01-as"
	
##### Container Secret Configuration Variables: #####

	# declare an associative array with the secret name as the array element and the bash variable name as the array value, the array element values should match the variable names in secrets.sh
	declare -A SECRET_MAPPING_ARR=(
		["sys_password"]="ORACLE_PWD"
	)
