#!/bin/bash

#-----------------------------------------------------------------------------
# include_host_resources.sh:
# this file loads all of the reusable bash files that are used in the 
# host deployment scripts
#-----------------------------------------------------------------------------

# determine current folder path (containerized_oracle_development_environment/deployment_scripts/container_scripts/includes)
CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# include the CDD/CDS shared/host functions
source "${CURR_DIR}/../../../../modules/CDD/src/includes/load_CDD_host_resources.sh"

# include the container configuration variables
source "${CURR_DIR}/../../config/container_config.sh"
source "${CURR_DIR}/../../config/custom_container_config.sh"
source "${CURR_DIR}/../../config/server_deploy_config.sh"

# include the host functions
source "${CURR_DIR}/../../shared_scripts/functions/shared_functions.sh"
source "${CURR_DIR}/../functions/host_functions.sh"