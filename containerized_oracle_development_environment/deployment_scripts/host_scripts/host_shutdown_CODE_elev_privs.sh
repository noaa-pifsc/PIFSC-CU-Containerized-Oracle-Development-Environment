#!/bin/bash

# Enforce Bash strict mode: exit on errors, unbound variables, and pipeline failures
set -euo pipefail

#-----------------------------------------------------------------------------
# host_shutdown_CODE_elev_privs.sh:
# this host script runs as the $PRIV_USER to shutdown the container 
#-----------------------------------------------------------------------------

# include the host functions
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/includes/include_host_resources.sh"

# shutdown the container on the container host using a privileged account
proj_host_shutdown_container_elev_privs
