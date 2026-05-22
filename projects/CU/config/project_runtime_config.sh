#!/bin/sh

##### Container Configuration Variables: #####

	# define the project name, this must be unique to run more than one instance of CODE on a given container host machine, this will determine the container name and the folder name for the working copy of the repository on the server
	COMPOSE_PROJECT_NAME=code_cen_utils

	#--- Primary schema created by deployment script, used to check if the database is installed. If the APP_SCHEMA_NAME exists then do not run the database initialization processes ---
	APP_SCHEMA_NAME=CEN_UTILS

##### Project Configuration Variables: #####

	# define the container git project URL
	GIT_URL="--branch Branch_CODE_v1.4_install git@github.com:noaa-pifsc/PIFSC-CU-Containerized-Oracle-Development-Environment.git"