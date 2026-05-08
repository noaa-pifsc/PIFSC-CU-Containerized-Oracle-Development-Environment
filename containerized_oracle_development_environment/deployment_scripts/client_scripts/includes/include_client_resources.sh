#!/bin/bash

#-----------------------------------------------------------------------------
# include_host_resources.sh:
# this file loads all of the reusable bash files that are used in the host
# container deployment scripts (intended for remote container host scenarios)
#-----------------------------------------------------------------------------

# determine current folder path (containerized_oracle_development_environment/deployment_scripts/container_scripts/includes)
CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# include the CDS shared/client functions
source "${CURR_DIR}/../../../../modules/CDS/src/CDS_shared_functions.sh"
source "${CURR_DIR}/../../../../modules/CDS/src/CDS_client_functions.sh"

# include the container configuration variables
source "${CURR_DIR}/../../config/initial_container_config.sh"
source "${CURR_DIR}/../../config/custom_container_config.sh"
source "${CURR_DIR}/../../config/custom_secret_config.sh"
source "${CURR_DIR}/../../config/container_config.sh"

# include the CODE core client functions
source "${CURR_DIR}/../../../CODE_core_scripts/functions/CODE_client_functions.sh"

# include the custom client function definitions
source "${CURR_DIR}/../functions/custom_client_functions.sh"