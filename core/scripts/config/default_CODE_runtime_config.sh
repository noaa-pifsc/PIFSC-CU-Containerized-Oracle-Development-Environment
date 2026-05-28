#!/bin/bash

##### Container Configuration Variables: #####

	# Container Variables That Must Be Unique For A Given Code Implementation To Allow Concurrent Runs
		# define the project name, this must be unique to run more than one instance of CODE on a given container host machine, this will determine the container name and the folder name for the working copy of the repository on the server
		COMPOSE_PROJECT_NAME=code_base

		#--- Container Port Configuration ---
		DB_HOST_PORT=1521
		ORDS_HOST_PORT=8181

	#--- Container Image Configuration ---
	DB_IMAGE=container-registry.oracle.com/database/free:latest
	ORDS_IMAGE=container-registry.oracle.com/database/ords:latest

	# define if the ORDS service is enabled (required for Apex/ORDS functionality)
	ORDS_ENABLED="yes"

	#--- APEX Configuration ---
	# Set the target APEX version here, if this variable is not defined apex will not be installed
	TARGET_APEX_VERSION=23.2

	#--- Primary schema created by deployment script, used to check if the database is installed. If the APP_SCHEMA_NAME exists then do not run the database initialization processes ---
	APP_SCHEMA_NAME=MY_APP_SCHEMA

##### Project Configuration Variables: #####

	# define the container git project URL
	GIT_URL="--branch Branch_CODE_v1.4 git@github.com:noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment.git"

##### Container Host Configuration Variables: #####

	# define the privileged container user
	PRIV_USER="docker-user"

	# define the container server hostname configuration information
	HOSTNAME="pifsc-dev-docker-01-as"
	