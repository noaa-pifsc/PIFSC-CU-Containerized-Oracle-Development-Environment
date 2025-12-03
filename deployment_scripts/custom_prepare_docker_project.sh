#! /bin/sh

echo "running custom scripts to prepare the docker project"

# load the project configuration script to set the runtime variable values
source ./sh_script_config/custom_project_config.sh

	echo "clone the DSC project's dependencies"

	git clone $dsc_git_url ../tmp/pifsc-dsc

	echo "copy the docker files from the repository to the docker/src subfolder"

	# copy the docker files from the repository to the docker/src subfolder
	cp -r ../tmp/pifsc-dsc/SQL ../docker/src/DSC/SQL

	echo "The DSC project's dependencies have been added to the docker/src subfolder"

	echo "clone the Centralized Utilities project's dependencies"

	git clone $cu_git_url ../tmp/centralized-utilities

	echo "copy the docker files from the repository to the docker subfolder"

	# copy the docker files from the repository to the docker subfolder
	cp -r ../tmp/centralized-utilities/SQL ../docker/src/CU/SQL
	
	echo "The Centralized Utilities project's dependencies have been added to the $project_directory"

echo "finished executing custom scripts to prepare the docker project"