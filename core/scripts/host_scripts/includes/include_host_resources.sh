#!/bin/bash

#-----------------------------------------------------------------------------
# include_host_resources.sh:
# this file loads all of the reusable bash files that are used in the 
# host deployment scripts
#-----------------------------------------------------------------------------

# determine current folder path (containerized_oracle_development_environment/deployment_scripts/container_scripts/includes)
CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# include the CDS shared/host functions
source "${CURR_DIR}/../../../modules/CDS/src/CDS_shared_functions.sh"
source "${CURR_DIR}/../../../modules/CDS/src/CDS_host_functions.sh"

# include the core CODE shared and host functions
source "${CURR_DIR}/../../CODE_functions/CODE_shared_functions.sh"
source "${CURR_DIR}/../../CODE_functions/CODE_host_functions.sh"

# include the container configuration variables
source "${CURR_DIR}/../../config/pre_CODE_config.sh"

# load the CODE and active project configurations
code_shared_load_CODE_config "${CURR_DIR}" "host" "PROJECT_LINEAR_DEPENDENCIES"