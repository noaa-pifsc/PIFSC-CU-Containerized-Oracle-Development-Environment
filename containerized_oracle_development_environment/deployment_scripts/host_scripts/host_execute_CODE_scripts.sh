#!/bin/bash

# Enforce Bash strict mode: exit on errors, unbound variables, and pipeline failures
set -euo pipefail

#-----------------------------------------------------------------------------
# host_deploy_CODE.sh:
# this host script runs a script as the $PRIV_USER to build the 
# container image and run the container on the container host by executing 
# host_deploy_CODE_elev_privs.sh
#-----------------------------------------------------------------------------

# Include CDS host resources
source "$(dirname "${BASH_SOURCE[0]}")/includes/include_host_resources.sh"

# initialize and build/run the container on the host machine with the specified function arguments:
proj_host_execute_container_scripts