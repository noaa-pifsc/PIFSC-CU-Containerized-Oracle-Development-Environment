#!/bin/sh

##### Container Configuration Variables: #####

	# Container Variables That Must Be Unique For A Given Code Implementation To Allow Concurrent Runs
		# declare the project name, this must be unique to run more than one instance of CODE on a given container host machine, this will determine the container name and the folder name for the working copy of the repository on the server
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
	declare GIT_URL="--branch Branch_CODE_v1.4_CDD_install_refactor git@github.com:noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment.git"

##### Container Host Configuration Variables: #####

	# define the privileged container user
	declare PRIV_USER="docker-user"

	# define the container server hostname configuration information
	declare HOSTNAME="pifsc-dev-docker-01-as"

	# define the name of the container stack
	declare STACK_NAME="${COMPOSE_PROJECT_NAME}_stack"

	# define the name of the container network
	declare NETWORK_NAME="${STACK_NAME}_oracle-net"
	