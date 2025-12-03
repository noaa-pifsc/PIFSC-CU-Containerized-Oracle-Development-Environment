# PIFSC Centralized Utilities Containerized Oracle Developer Environment

## Overview
The Centralized Utilities (CU) PIFSC Containerized Oracle Developer Environment (CODE) project was developed to provide a custom containerized Oracle development environment for the CU.  This repository can be forked to extend the existing functionality to any data systems that depend on the CU for both development and testing purposes.  

## Resources
-   ### CU CODE Version Control Information
    -   URL: https://github.com/noaa-pifsc/PIFSC-CU-Containerized-Oracle-Development-Environment
    -   Version: 1.1 (git tag: CU_CODE_v1.0)
    -   Upstream repository:
        -   DSC CODE (DCODE) Version Control Information:
            -   URL: https://github.com/noaa-pifsc/PIFSC-DSC-Containerized-Oracle-Development-Environment
            -   Version: 1.1 (git tag: DSC_CODE_v1.1)
-   ### CU Version Control Information
    -   URL: https://picgitlab.nmfs.local/centralized-data-tools/centralized-utilities
-   ### DSC Version Control Information
    -   URL: https://picgitlab.nmfs.local/centralized-data-tools/pifsc-dsc

## Prerequisites
-   See the CODE [Prerequisites](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment?tab=readme-ov-file#prerequisites) for details

## Repository Fork Diagram
-   See the CODE [Repository Fork Diagram](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment?tab=readme-ov-file#repository-fork-diagram) for details

## Runtime Scenarios
-   See the CODE [Runtime Scenarios](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment?tab=readme-ov-file#runtime-scenarios) for details

## Automated Deployment Process
-   ### Prepare the folder structure
    -   See the CODE [Prepare the folder structure](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment?tab=readme-ov-file#prepare-the-folder-structure) for details
    -   #### DSC Preparation
        -   The [SQL](https://picgitlab.nmfs.local/centralized-data-tools/pifsc-dsc/-/tree/main/SQL?ref_type=heads) folder is copied into a new "DSC" folder within the [docker/src](./docker/src) folder
    -   #### CU Preparation
        -   The [CU/SQL](https://picgitlab.nmfs.local/centralized-data-tools/centralized-utilities/-/tree/master/SQL?ref_type=heads) folder is copied into the [CU folder](./docker/src/CU) folder
-   ### Build and Run the Containers 
    -   See the CODE [Build and Run the Containers](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment?tab=readme-ov-file#build-and-run-the-containers) for details
    -   #### DSC Database Deployment
        -   [create_docker_schemas.sql](https://picgitlab.nmfs.local/centralized-data-tools/pifsc-dsc/-/blob/main/SQL/dev_container_setup/create_docker_schemas.sql?ref_type=heads) is executed by the SYS schema to create the DSC schema and grant the necessary privileges
        -   [deploy_dev_container.sql](https://picgitlab.nmfs.local/centralized-data-tools/pifsc-dsc/-/blob/main/SQL/automated_deployments/deploy_dev_container.sql?ref_type=heads) is executed with the DSC schema to deploy the objects to the DSC schema
    -   #### CAS Database Deployment
        -   [create_docker_schemas.sql](https://picgitlab.nmfs.local/centralized-data-tools/centralized-utilities/-/blob/master/SQL/dev_container_setup/create_docker_schemas.sql?ref_type=heads) is executed to create the CU schemas and roles
        -   [deploy_dev_container.sql](https://picgitlab.nmfs.local/centralized-data-tools/centralized-utilities/-/blob/master/SQL/automated_deployments/deploy_dev_container.sql?ref_type=heads) is executed with the CEN_UTILS schema to deploy the objects to the CEN_UTILS schema

## Customization Process
-   ### Implementation
    -   \*Note: this process will fork the CU CODE parent repository and repurpose it as a project-specific CODE
    -   Fork [this repository](#cu-code-version-control-information)
    -   See the CODE [Implementation](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment?tab=readme-ov-file#implementation) for details
-   ### Upstream Updates
    -   See the CODE [Upstream Updates](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment?tab=readme-ov-file#upstream-updates) for details

## Container Architecture
-   See the CODE [container architecture documentation](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment?tab=readme-ov-file/-/blob/main/README.md?ref_type=heads#container-architecture) for details

## Connection Information
-   See the CODE [connection information documentation](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment?tab=readme-ov-file/-/blob/main/README.md?ref_type=heads#connection-information) for details
-   ### CU Database Connection Information
    -   Connection information can be found in [create_docker_schemas.sql](https://picgitlab.nmfs.local/centralized-data-tools/centralized-utilities/-/blob/master/SQL/dev_container_setup/create_docker_schemas.sql?ref_type=heads)
-   ### DSC Database Connection Information
    -   Connection information can be found in [create_docker_schemas.sql](https://picgitlab.nmfs.local/centralized-data-tools/pifsc-dsc/-/blob/main/SQL/dev_container_setup/create_docker_schemas.sql?ref_type=heads)