#!/bin/bash

# Enforce Bash strict mode: exit on errors, unbound variables, and pipeline failures
# set -euo pipefail

# include the client functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_client_resources.sh"

# shutdown the containers for the specified environment and destination, and optionally remove the associated volumes
proj_client_shutdown_container "${1}" "${2}" "${3}"