#!/bin/bash

#-----------------------------------------------------------------------------
# include_container_resources.sh:
# this file loads all of the reusable bash files that are used in the container
# container deployment scripts
#-----------------------------------------------------------------------------

# determine current folder path (containerized_oracle_development_environment/deployment_scripts/container_scripts/includes)
CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# include the CDS shared functions
source "${CURR_DIR}/../../../../modules/CDS/src/CDS_shared_functions.sh"

# include the container configuration variables
source "${CURR_DIR}/../../config/initial_container_config.sh"
source "${CURR_DIR}/../../config/custom_container_config.sh"
source "${CURR_DIR}/../../config/custom_secret_config.sh"
source "${CURR_DIR}/../../config/container_config.sh"

# include the CODE core container functions
source "${CURR_DIR}/../../../CODE_core_scripts/CODE_container_functions.sh"

# include the container functions
source "${CURR_DIR}/../functions/custom_container_functions.sh"