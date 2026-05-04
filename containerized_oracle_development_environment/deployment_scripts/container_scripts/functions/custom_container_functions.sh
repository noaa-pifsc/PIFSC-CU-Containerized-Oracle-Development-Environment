#!/bin/bash

# function that executes database scripts within the container
function proj_container_database_deploy_custom_scripts ()
{
	echo "running the custom database and/or application deployment scripts"

	# run each of the sqlplus scripts to deploy the schemas, objects for each schema, applications, etc.
	# ... YOUR SCRIPT LOGIC HERE ...

	echo "custom deployment scripts have completed successfully"
}