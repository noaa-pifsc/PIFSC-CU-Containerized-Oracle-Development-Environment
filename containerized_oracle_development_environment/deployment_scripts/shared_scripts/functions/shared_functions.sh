
# function to deploy the CODE containers
function proj_deploy_CODE_containers ()
{
	local build_path="${1}"
	local compose_file="${2}"

	if ! cds_shared_validate_required_vars "build_path" "compose_file"; then 
        echo "Error: proj_deploy_CODE_containers() function argument validation failed" >&2
        return 1
    fi

	# change to the designated build path so the containers can be stopped (if running) and started
	cd "${build_path}"

	# declare COMPOSE_FILE as an environment variable
	export COMPOSE_FILE="${compose_file}"

	echo "the value of COMPOSE_FILE is: ${COMPOSE_FILE}"

	# remove the containers if they are already running
	docker compose --env-file ./.env down

	# Execute natively for local Desktop Deployments using the injected COMPOSE_FILE
	docker compose --env-file ./.env up -d --build
}