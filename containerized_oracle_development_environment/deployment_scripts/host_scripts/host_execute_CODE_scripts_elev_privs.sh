#!/bin/bash

# Enforce Bash strict mode: exit on errors, unbound variables, and pipeline failures
set -euo pipefail

#-----------------------------------------------------------------------------
# host_deploy_CODE_elev_privs.sh:
# this host script runs as the $PRIV_USER to build and run 
# the container and execute a specified script from within the container
#-----------------------------------------------------------------------------

# include the host functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_host_resources.sh"

# deploy the container on the container host using a privileged account
proj_host_execute_container_scripts_elev_privs
