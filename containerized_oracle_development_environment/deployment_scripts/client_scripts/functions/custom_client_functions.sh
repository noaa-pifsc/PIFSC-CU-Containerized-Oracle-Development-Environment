#!/bin/bash

# function that deploys the containers for a development environment
# the function accepts the following arguments:
# 1: environment name (dev, test)
proj_client_build_deploy_dev_environment ()
{
	# build the list of compose files:
	local $env_name="${1}"

	# change to the defined build_path so the docker commands can be run relative to the build path directory
	cd "${BUILD_PATH}"
	
	# include the docker environment variables
	local compose_files=("--env-file" "./.env")
	
	# include the db and db-ords-deploy services
	compose_files+=("-f" "./CODE-db-deploy.yml")

	# check if this is intended for a dev environment (retain database and ords volumes across container restarts) 
	if [ "${env_name}" == "dev" ]; then
		# add in the named volume for the db service
		compose_files+=("-f" "./CODE-db-named-volume.yml")
	fi

	# include the ORDS service
	compose_files+=("-f" "./CODE-ords.yml")

	# add custom docker compose to integrate additional services and/or map project-specific resources for the db-ords-deploy service to automatically deploy
	compose_files+=("-f" "./custom-docker-compose.yml")

	# build and execute the docker container for the specified deployment environment:
	docker compose "${compose_files[@]}" up -d --build
}