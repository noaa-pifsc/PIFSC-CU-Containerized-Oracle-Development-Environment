# PIFSC Containerized Oracle Developer Environment

## Overview
The PIFSC Containerized Oracle Developer Environment (CODE) project was developed to provide a containerized Oracle development environment for PIFSC software developers.  The project can be extended to automatically create/deploy database schemas and applications to allow data systems with dependencies to be developed and tested using the CODE.  This repository can be forked to customize CODE for a specific software project.  

## Resources
-   ### CODE Version Control Information
    -   URL: https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment
    -   Version: 1.4 (git tag: CODE_v1.4)
-   [CODE Demonstration Outline](./docs/demonstration_outline.md)
-   [CODE Repository Fork Diagram](./docs/CODE_fork_diagram.drawio.png)
    -   [CODE Repository Fork Diagram source code](./docs/CODE_fork_diagram.drawio)

# Prerequisites
-   Create an account or login to the [Oracle Image Registry](https://container-registry.oracle.com)
    -   Generate an auth token
        -   Click on your username and choose "Auth Token"
        -   Click "Generate Secret Key"
        -   Click "Copy Secret Key"
            -   Save this key somewhere secure, you will need it to login to the container registry via docker
    -   Using the command (cmd) prompt or git bash, log into Oracle Registry with your secret Auth Token
    ```
    docker login container-registry.oracle.com
    ```
    -   To sign in with a different user account, just use logout command:
    ```
    docker logout container-registry.oracle.com
    ```
-   Windows/Linux machine serving as the local client
    -   Git Bash
    -   OpenSSH is setup to work with CAC authentication
    -   OpenSSH is configured to specify the username in the ~/.ssh/config file for each container host (e.g. docker_dev for the dev container host)
        -   The ForwardAgent feature is enabled to allow the git repositories to be cloned on the container host

## Container Host Instances
-   For the development container and database instances the abbreviation used is "dev" 
-   For the test container and database instances the abbreviation used is "test" 

## Dependencies
\* Note: all dependencies are implemented as git submodules in the [modules](./modules) folder
-   ### Container Deployment System (CDS) Module Version Control Information
    -   folder path: [modules/CDS](./modules/CDS)
    -   Version Control Information:
        -   URL: <git@github.com:noaa-pifsc/PIFSC-Container-Deployment-System.git>

## Naming Conventions
-   ### Functions
    -   The function naming convention follows the [namespace]\_[scope]\_[action] format, allowing developers to instantly identify the module a function belongs to and the execution environment where it is designed to run.
    -   Namespace: code_
    -   Execution Scopes: 
        -   client_: Executes on the developer workstation.
        -   host_: Executes on the remote container host server.
        -   container_: Executes within the container.
    -   Resources: 
        -   [CDS function naming conventions](./modules/CDS/README.md#functions)
-   ### Variables
    -   The CODE follows the defined [CDS variable naming conventions](./modules/CDS/README.md#variables)

## Repository Fork Diagram
-   The CODE repository is intended to be forked for specific data systems
-   The [CODE Repository Fork Diagram](./docs/CODE_fork_diagram.drawio.png) shows the different example and actual forked repositories that could be part of the suite of CODE repositories for different data systems
    -   The implemented repositories are shown in blue:
        -   [CODE](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment)
            -   The CODE is the first repository shown at the top of the diagram and serves as the basis for all forked repositories for specific data systems
        -   [DSC CODE](https://github.com/noaa-pifsc/PIFSC-DSC-Containerized-Oracle-Development-Environment)
        -   [Centralized Authorization System (CAS) CODE](https://github.com/noaa-pifsc/PIFSC-CAS-Containerized-Oracle-Development-Environment)
        -   [PIFSC Resource Inventory (PRI) CODE](https://github.com/noaa-pifsc/PIFSC-PRI-Containerized-Oracle-Development-Environment)
        -   [Centralized Utilities (CU) CODE](https://github.com/noaa-pifsc/PIFSC-CU-Containerized-Oracle-Development-Environment)
        -   [Life History Program (LHP) CODE](https://github.com/noaa-pifsc/PIFSC-LHP-Containerized-Oracle-Development-Environment)
    -   The examples or repositories that have not been implemented yet are shown in orange  
![CODE Repository Fork Diagram](./docs/CODE_fork_diagram.drawio.png)

## CODE Folder Structure
-   ### Project-Specific CODE Folder Structure
    -   The [containerized_oracle_development_environment](./containerized_oracle_development_environment) folder is provided to streamline the process of implementing the CODE for a given container application:
        -   The [CODE_core_scripts](./containerized_oracle_development_environment/CODE_core_scripts) folder contains the core CODE scripts that will be upgraded over time and propagated to the individual forked project. These script should not change for project-specific CODE implementations
        -   The [deployment_script_logs](./containerized_oracle_development_environment/deployment_script_logs) folder contains logs from the execution of scripts to prepare and deploy the container
        -   The [deployment_scripts](./containerized_oracle_development_environment/deployment_scripts) folder contains scripts to prepare and deploy the container project
            -   The [client_scripts](./containerized_oracle_development_environment/deployment_scripts/client_scripts) folder contains scripts to execute on the client computer
            -   The [config](./containerized_oracle_development_environment/deployment_scripts/config) folder contains configuration files to define the CDD configuration
            -   The [container_scripts](./containerized_oracle_development_environment/deployment_scripts/container_scripts) folder contains scripts to execute within the container
            -   The [host_scripts](./containerized_oracle_development_environment/deployment_scripts/host_scripts) folder contains scripts to execute on the container host
        -   The [docs](./containerized_oracle_development_environment/docs) folder contains documentation for the project-specific CODE implementation
        -   The [ords-config](./containerized_oracle_development_environment/ords-config) folder contains the default ORDS configuration file necessary for ORDS and Apex to function properly
        -   The [secrets](./containerized_oracle_development_environment/secrets) folder contains files to define the database credentials and other secret values that are used when building the container (these files are not committed to version control)
    -   The [docs](./containerized_oracle_development_environment/docs) folder contains documentation for the CODE project
    -   The [modules](./modules) folder contains a pointer to git submodules implemented for the CODE
        -   The [CDS](./modules/CDS) folder contains a pointer the CDS repository implemented as a git submodule
    -   The [README.md](./README.md) file documents the CODE module
-   ### CODE Folder Diagram:
    ```
    .
    |--- containerized_oracle_development_environment
    |    |--- CODE_core_scripts
    |    |--- deployment_script_logs
    |    |--- deployment_scripts
    |    |    |--- client_scripts
    |    |    |--- config
    |    |    |--- container_scripts
    |    |    |--- host_scripts
    |    |--- docs
    |    |--- ords-config
    |    |--- secrets 
    |--- docs
    |--- modules
    |    |--- CDS
    |--- README.md
    ```

## CODE Implementation Procedure
-   ### Implementation
    -   \*Note: this process will fork a given CODE repository and repurpose it as a project-specific CODE
    -   Fork the desired CODE repository (e.g. [CODE](#code-version-control-information)
        -   Update the name/description of the project to specify the data system that is implemented in CODE
    -   Clone the forked project recursively to a working directory
    -   Update the forked project in the working directory
        -   Update the [README.md](./README.md) to reference all of the repositories that are used to build the image and deploy the container
    -   Update the [custom_container_config.sh](./containerized_oracle_development_environment/src/deployment_scripts/config/custom_container_config.sh) to specify the appropriate variables for the new project-specific CODE implementation
        -   APP_SCHEMA_NAME is the database schema that will be used to check if the database schemas have been installed, this only applies to the [development runtime scenario](#development)
        -   DB_IMAGE is the path to the database image used to build the database contianer (db container)
        -   ORDS_IMAGE is the path to the ORDS image used to build the ORDS/Apex container (ords container)
    -   Update [custom_secret_config.sh](./containerized_oracle_development_environment/deployment_scripts/config/custom_secret_config.sh) to add additional secret values that are used when deploying the database schemas/objects and/or apex applications
        -   The array element values should correspond to the secret variables specified in secrets.sh. The array element names should correspond to the actual secret names used in the given container.
    -   Update the [secrets template](./containerized_oracle_development_environment/secrets/secrets.template.sh) file to include placeholder variables for any secret values used inside of the CODE project.
    -   Add git submodules in a designated folder (e.g. modules) for any git repository dependencies that the given project has
    -   Update [custom-docker-compose.yml](./containerized_oracle_development_environment/custom-docker-compose.yml) to define volumes to mount the corresponding submodule repository folders necessary to deploy the database(s)/apex application(s) 
    -   Update the [custom_client_functions.sh](./containerized_oracle_development_environment/deployment_scripts/client_functions/custom_client_functions.sh) file to update the following functions with the appropriate code for the corresponding project-specific CODE implementation:
        -   proj_client_construct_compose_file_string(): update to include any additional container compose .yml files for the project-specific CODE implementation
        -   proj_client_custom_export_env_vars(): update to export the environment variable values required for the project-specific CODE implementation
        -   proj_client_custom_string_env_vars(): update to generate the string that defines the environment variable value assignment statements required for the project-specific CODE implementation
        -   proj_client_custom_load_scripts(): load each of the secret/configuration files required for the project-specific CODE implementation
    -   Update the [custom_container_functions.sh](./containerized_oracle_development_environment/deployment_scripts/container_functions/custom_container_functions.sh) file to update the following functions with the appropriate code for the corresponding project-specific CODE implementation:
        -   proj_container_database_deploy_custom_scripts(): define the database connection strings and execute the necessary sqlplus commands to deploy the database schema(s) and objects
    -   Update the [custom_host_functions.sh](./containerized_oracle_development_environment/deployment_scripts/host_functions/custom_host_functions.sh) script to update the following functions with the appropriate code for the corresponding project-specific CODE implementation:
        -   proj_host_custom_export_env_vars_block(): define the string necessary to export the defined required environment variables
-   ### Implementation Examples
    -   Standalone database with no dependencies: [DSC CODE](https://github.com/noaa-pifsc/PIFSC-DSC-Containerized-Oracle-Development-Environment)
    -   Oracle database and PHP web container application: [Staff Information Application (SIA) CODE](https://github.com/noaa-pifsc/PIFSC-SIA-Containerized-Oracle-Development-Environment)
    -   Oracle database and Apex application: [Centralized Authorization System (CAS) CODE](https://github.com/noaa-pifsc/PIFSC-CAS-Containerized-Oracle-Development-Environment)
-   ### Upstream Updates
    -   Most upstream file updates can be accepted without changes, except for the following files that should be merged (to integrate any appropriate upstream updates) or rejected (Keep HEAD revision) based on their function:
        -   Merge:
            -   [README.md](./README.md) to reference any changes in the upstream README.md that are relevant
        -   Reject (unless there are additional variables defined):
            -   [custom_container_config.sh](./containerized_oracle_development_environment/src/deployment_scripts/config/custom_container_config.sh)
        -   Reject (unless there are additional functions defined):
            -   [custom_client_functions.sh](./containerized_oracle_development_environment/deployment_scripts/client_functions/custom_client_functions.sh)
            -   [custom_container_functions.sh](./containerized_oracle_development_environment/deployment_scripts/container_functions/custom_container_functions.sh)
            -   [custom_host_functions.sh](./containerized_oracle_development_environment/deployment_scripts/host_functions/custom_host_functions.sh)

## Setup
-   ### Container Application Setup
    -   Recursively clone the given git project to a directory on the local client computer
    -   Within the project repository create the necessary bash file with the secret values for each database instance: secrets.sh in the [secrets folder](./containerized_oracle_development_environment/secrets/)
	    -   \*Note: There is a [secrets template](./containerized_oracle_development_environment/secrets/secrets.template.sh) file that can be used to create the secrets.sh file for each database instance 
        -   \*Note: the actual secret files should not be committed to the repository for security purposes, a [.gitignore](./containerized_oracle_development_environment/.gitignore) file has been added to the repository to prevent these sensitive files from being included in git.  
        -   \*Note: the secrets.sh will only set the oracle passwords on the initial database container run, on subsequent runs it is only used to connect to the database schemas
    -   Update the [custom_container_config.sh](./containerized_oracle_development_environment/deployment_scripts/config/custom_container_config.sh) to define the bash variables with the appropriate values, there are comments defined for each variable to indicate how they affect the deployed CODE containers.
        -   To allow multiple developers to use CODE concurrently on the same container host, update the three variables identified in the top section: COMPOSE_PROJECT_NAME, DB_HOST_PORT, and ORDS_HOST_PORT to have unique values
        -   \*Note: When server deployments are executed the custom_container_config.sh values on the client machine are used instead of the custom_container_config.sh value that are saved in the server's cloned CODE repository, the values are transmitted to the server using environment variables
    -   Setup docker swarm (one-time setup): `docker swarm init`

## Executing the CODE Project
-   \*Note: The variables listed below are global bash variables that are defined in the configuration files of the given project-specific CODE implementation.
-   Following the [Setup](#setup) process, execute the [client_execute_CODE_scripts.sh](./containerized_oracle_development_environment/deployment_scripts/client_scripts/client_execute_CODE_scripts.sh) script using bash and specify the appropriate script parameters:
    -   script_action: the type of script that is executed - "deploy" for CODE containers deployments and "shutdown" for shutting down the CODE containers
    -   env_name: environment name - "dev" for development, "test" for testing purposes)
        -   \*Note: when the env_name is "dev" it will retain the database across CODE container restarts
    -   deploy_dest: deployment destination - "local" for docker desktop CODE deployments and "server" for linux host deployments
    -   rem_vol: remove volume flag - "yes" to remove the volumes associated with the CODE container stack name or "no" to retain the volumes
        -   \*Note: if a volume is removed the data contained within it is lost, caution is advised to ensure that work is not lost or it's saved before the volume(s) are removed.
    -   Examples:
        -   Executing a deployment for a development environment locally without removing the volumes first: 
            -   `bash client_execute_CODE_scripts.sh deploy dev local no`
        -   Executing a shutdown for a development environment on the server and remove the associated volumes: 
            -   `bash client_execute_CODE_scripts.sh shutdown dev server yes`
-   ### Runtime Scenarios:
    -   There are two different runtime scenarios implemented in this project
    -   Both scenarios implement a docker volume for the Apex static files (apex-static-vol) that are used in the Apex upgrade process
    -   The $ORDS_ENABLED global bash variable (defined in [custom_container_config.sh](./containerized_oracle_development_environment/deployment_scripts/config/custom_container_config.sh)) determines if the ORDS/Apex container is enabled
        -   If $ORDS_ENABLED is "yes" then the [CODE-ords.yml](./containerized_oracle_development_environment/CODE-ords.yml) file is loaded during the building/running of the CODE containers to make the ORDS/Apex container available. 
            -   If the $ORDS_ENABLED is "yes" and the $TARGET_APEX_VERSION variable is defined in the [custom_container_config.sh](./containerized_oracle_development_environment/deployment_scripts/config/custom_container_config.sh) and valid, then it will install the matching version of Apex version in the code-ords container.
        -   If $ORDS_ENABLED is "no" then the ORDS/Apex container is omitted from the CODE containers.
    -   #### Development:
        -   (env_name = "dev") This scenario retains the database across container restarts, this is intended for database and application development purposes
        -   This scenario implements a docker volume for the database files (code-db-vol) to retain the database data across container restarts
        -   The $TARGET_APEX_VERSION variable defined in the [custom_container_config.sh](./containerized_oracle_development_environment/deployment_scripts/config/custom_container_config.sh) can only be increased once an apex container is upgraded, it can't be used to downgrade an existing Apex version.  If a downgrade is required the database volume (code-db-vol) needs to be deleted and then the container must be run again.  
        -   \*Note: the initial container run can take up to approximately 30 minutes depending on the resources allocated to the container platform software since the database is initialized and when $ORDS_ENABLED is "yes" it also installs Apex on the ORDS container
    -   #### Test:
        -   (env_name = "test") This scenario does not retain the database across container restarts, this is intended to test the deployment process of schemas and applications
        -   \*Note: the container run process can take up to approximately 30 minutes depending on the resources allocated to the container platform software since the database is initialized and when $ORDS_ENABLED is "yes" it also installs Apex on the ORDS container
-   A log file for each client script execution is saved in [deployment_script_logs](./container_application_deployment_template/deployment_script_logs) and is named client_deploy_application.sh.$(date +%Y%m%d_%H%M%S).log based on the date/time the script is executed.  This file will include the output from the remote host and container scripts

## Container Architecture
-   The code-db container is built from an official Oracle database image (defined by DB_IMAGE in [custom_container_config.sh](./containerized_oracle_development_environment/deployment_scripts/config/custom_container_config.sh)) maintained in the Oracle container registry
-   The code-db-ords-deploy container is built from a custom dockerfile ([Dockerfile.deploy](./containerized_oracle_development_environment/Dockerfile.deploy)) that uses an official Oracle InstantClient image with some custom libraries installed.  
    -   This container waits until the db container is running and the service is healthy and Apex has been installed on the database container
    -   This container runs the [container_deploy_database.sh](./containerized_oracle_development_environment/deployment_scripts/container_scripts/container_deploy_database.sh) bash script to deploy all database schemas, database objects, and when applicable the Apex workspaces, and Apex apps
    -   Once the db_ords_deploy container finishes deploying the database schemas/apps the container will shut down.  
-   The code-ords container is built from an official Oracle ORDS image (defined by ORDS_IMAGE in [custom_container_config.sh](./containerized_oracle_development_environment/deployment_scripts/config/custom_container_config.sh)) maintained in the Oracle container registry and contains both ORDS and Apex capabilities
    -   This container is built from a custom dockerfile ([Dockerfile.ords](./containerized_oracle_development_environment/Dockerfile.ords)) that utilizes a standard ORDS configuration file ([settings.xml](./containerized_oracle_development_environment/settings.xml))
    -   This container waits until the code-db-ords-deploy container is running and is accessible via SQL\*Plus

## Connection Information
For the following connections refer to the [custom_container_config.sh](./containerized_oracle_development_environment/deployment_scripts/config/custom_container_config.sh) configuration file and the secrets.sh for the corresponding values
-   \*Note: For server deployments the following command can create an SSH tunnel between the server and the developer workstation to allow the following URLs to connect to the corresponding server endpoints (where the variable references match the runtime values when the CODE containers were deployed):
    -   `ssh -N -L ${ORDS_HOST_PORT}:localhost:${ORDS_HOST_PORT} -L ${DB_HOST_PORT}:localhost:${DB_HOST_PORT} dev_docker`
-   Database connections:
    -   hostname: localhost:${DB_HOST_PORT}/${DBSERVICENAME}
    -   username: SYSTEM or SYS AS SYSDBA
    -   password: ${ORACLE_PWD}
-   Apex server:
    -   hostname: http://localhost:${ORDS_HOST_PORT}/ords/apex
    -   workspace: internal
    -   username: ADMIN
    -   password: ${ORACLE_PWD}
-   ORDS server:
    -   hostname: http://localhost:${ORDS_HOST_PORT}/ords

## Security Features
-   The CODE project inherits security features from the [CDS module](./modules/CDS/README.md#security-features).
-   Strict Local Variable Scoping (No Global Leakage): Within the container runtime, secret values are parsed directly into strictly scoped local associative arrays. Secret values are never stored in floating global variables or the container's exported environment, effectively shielding them from potential exposure via container introspection tools or error dumps.
-   Decoupled Configuration Adapter Pattern: The core CODE engine enforces a strict Separation of Concerns. It remains completely independent of project-specific global variables. It only operates on strictly validated associative arrays passed from the client adapter, ensuring that the engine itself cannot inadvertently expose or mishandle project-specific configurations.
-   Secure Connection String Generation: When dynamically generating database connection strings, the CODE framework retrieves values safely from the locally scoped secrets array and strictly quotes the passwords. This prevents special characters inside the database credentials from corrupting the connection string or breaking the SQL execution pipeline.
-   Immutable Shell Executions: When elevating privileges to run container commands, CODE utilizes rigid Heredocs (<<EOF) to pipe commands into the new shell. This creates an immutable execution block that safely separates the runtime variables from the raw secret payload.

## License
See the [LICENSE.md](./LICENSE.md) for details

## Disclaimer
This repository is a scientific product and is not official communication of the National Oceanic and Atmospheric Administration, or the United States Department of Commerce. All NOAA GitHub project code is provided on an ‘as is’ basis and the user assumes responsibility for its use. Any claims against the Department of Commerce or Department of Commerce bureaus stemming from the use of this GitHub project will be governed by all applicable Federal law. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by the Department of Commerce. The Department of Commerce seal and logo, or the seal and logo of a DOC bureau, shall not be used in any manner to imply endorsement of any commercial product or activity by DOC or the United States Government.