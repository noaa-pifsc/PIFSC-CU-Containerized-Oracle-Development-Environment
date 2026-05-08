#!/bin/bash

#-----------------------------------------------------------------------------
# include_host_resources.sh:
# this file loads all of the reusable bash files that are used in the 
# host deployment scripts
#-----------------------------------------------------------------------------

# determine current folder path (containerized_oracle_development_environment/deployment_scripts/container_scripts/includes)
CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# include the CDS shared/host functions
source "${CURR_DIR}/../../../../modules/CDS/src/CDS_shared_functions.sh"
source "${CURR_DIR}/../../../../modules/CDS/src/CDS_host_functions.sh"

# include the container configuration variables (don't include the custom_container_config.sh file because those values are passed to the host scripts via environment variables)
source "${CURR_DIR}/../../config/initial_container_config.sh"
source "${CURR_DIR}/../../config/custom_secret_config.sh"
source "${CURR_DIR}/../../config/container_config.sh"

# include the CODE core host functions
source "${CURR_DIR}/../../../CODE_core_scripts/functions/CODE_host_functions.sh"

# include the host functions
source "${CURR_DIR}/../functions/custom_host_functions.sh"