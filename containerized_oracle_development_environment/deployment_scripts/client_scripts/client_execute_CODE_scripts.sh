#!/bin/bash

# Enforce Bash strict mode: exit on errors, unbound variables, and pipeline failures
# set -euo pipefail

# include the client functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_client_resources.sh"

# deploy the containers for the development environment
proj_client_process_arguments_execute_container_scripts "${1}" "${2}" "${3}" "${4:-no}"