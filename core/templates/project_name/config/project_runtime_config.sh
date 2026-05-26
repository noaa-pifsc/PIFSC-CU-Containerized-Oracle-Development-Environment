#!/bin/sh

##### Container Configuration Variables: #####

	# Container Variables That Must Be Unique For A Given Code Implementation To Allow Concurrent Runs
		# the project name, this must be unique to run more than one instance of CODE on a given container host machine, this will determine the container name and the folder name for the working copy of the repository on the server
		# Example: COMPOSE_PROJECT_NAME=code_dsc

		#--- Container Port Configuration ---
		# Example: DB_HOST_PORT=1521
		# Example: ORDS_HOST_PORT=8181

	# define if the ORDS service is enabled (required for Apex/ORDS functionality)
	# Example: ORDS_ENABLED="no"

	#--- APEX Configuration ---
	# Set the target APEX version here, if this variable is not defined apex will not be installed
	# Example: TARGET_APEX_VERSION=23.2

	#--- Primary schema created by deployment script, used to check if the database is installed. If the APP_SCHEMA_NAME exists then do not run the database initialization processes ---
	# Example: APP_SCHEMA_NAME=DSC

##### Project Configuration Variables: #####

	# define the container git project URL
	# Example: GIT_URL="git@github.com:noaa-pifsc/PIFSC-DSC-Containerized-Oracle-Development-Environment.git"