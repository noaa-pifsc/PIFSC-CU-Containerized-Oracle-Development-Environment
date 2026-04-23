#!/bin/bash

# Enforce Bash strict mode: exit on errors, unbound variables, and pipeline failures
set -euo pipefail

#-----------------------------------------------------------------------------
# host_shutdown_CODE.sh:
# this host script runs a script as the $PRIV_USER to shutdown the 
# containers on the container host by executing host_shutdown_CODE_elev_privs.sh
#-----------------------------------------------------------------------------

# Include host resources
source "$(dirname "${BASH_SOURCE[0]}")/includes/include_host_resources.sh"

# shutdown the container on the host machine with the specified function arguments:
proj_host_shutdown_container