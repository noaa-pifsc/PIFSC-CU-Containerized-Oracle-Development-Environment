# PIFSC Containerized Oracle Developer Environment

## Overview
The PIFSC Containerized Oracle Developer Environment (CODE) framework was developed to provide a containerized Oracle development environment for PIFSC software developers.  The framework can be extended to automatically create/deploy database schemas and applications to allow data systems with dependencies to be developed and tested using the CODE.  This repository or any other forked CODE repository can be forked to customize CODE for a specific software project and integrate its dependencies.  

## Resources
-   ### CODE Version Control Information
    -   URL: https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment
    -   Version: 1.4 (git tag: CODE_v1.4)
-   [CODE Demonstration Outline](./docs/demonstration_outline.md)
-   [CODE Repository Fork Diagram](./diagrams/CODE_fork_diagram.drawio.png)
    -   [CODE Repository Fork Diagram source code](./diagrams/CODE_fork_diagram.drawio)

## Appropriate Use
-   The CODE project is NOT intended for production use, it was developed to provide a containerized development and testing environment. There has been no rigorous security hardening process that complies with federal security requirements. 
-   The CODE project can be used to develop and test features and applications without requiring System Administrator support. The user specifies the administrator passwords when the container is run so they can make system-level configuration changes directly in the database or ORDS containers and then provide the working configuration settings to the System Administrator for implementation in the enterprise test and production environments.

## Prerequisites
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
-   Automated Database Deployments:
    -   The individual project repositories that are implemented as git submodules for a given CODE fork must define automated database deployment scripts that can be executed via SQL*Plus
-   The git merge strategy requires the merge.ours.drive to be enabled, the following command can be used to enable it:
    -   `git config merge.ours.driver true`

## Container Host Instances
-   For the development container and database instances the abbreviation used is "dev" 
-   For the test container and database instances the abbreviation used is "test" 

## Dependencies
\* Note: all dependencies are implemented as git submodules in the [/core/modules](../modules) folder
-   ### Container Deployment System (CDS) Module Version Control Information
    -   folder path: [/core/modules/CDS](../modules/CDS)
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
        -   [CDS function naming conventions](../modules/CDS/README.md#functions)
-   ### Variables
    -   The CODE follows the defined [CDS variable naming conventions](../modules/CDS/README.md#variables)

## Repository Fork Diagram
-   The CODE repository is intended to be forked for specific data systems
-   The [CODE Repository Fork Diagram](./diagrams/CODE_fork_diagram.drawio.png) shows the different example and actual forked repositories that could be part of the suite of CODE repositories for different data systems
    -   The implemented repositories are shown in blue:
        -   [CODE](https://github.com/noaa-pifsc/PIFSC-Containerized-Oracle-Development-Environment)
            -   The CODE is the first repository shown at the top of the diagram and serves as the basis for all forked repositories for specific data systems
        -   [DSC CODE](https://github.com/noaa-pifsc/PIFSC-DSC-Containerized-Oracle-Development-Environment)
        -   [Centralized Authorization System (CAS) CODE](https://github.com/noaa-pifsc/PIFSC-CAS-Containerized-Oracle-Development-Environment)
        -   [PIFSC Resource Inventory (PRI) CODE](https://github.com/noaa-pifsc/PIFSC-PRI-Containerized-Oracle-Development-Environment)
        -   [Centralized Utilities (CU) CODE](https://github.com/noaa-pifsc/PIFSC-CU-Containerized-Oracle-Development-Environment)
        -   [Life History Program (LHP) CODE](https://github.com/noaa-pifsc/PIFSC-LHP-Containerized-Oracle-Development-Environment)
    -   The examples or repositories that have not been implemented yet are shown in orange  
![CODE Repository Fork Diagram](./diagrams/CODE_fork_diagram.drawio.png)

## CODE Folder Structure
-   ### Project-Specific CODE Folder Structure
    -   The [core](../) folder contains the core CODE framework source code
        -   \*Note: no files in this folder should be modified in any forks, this is meant to be upgraded over time by pulling upstream changes from the CODE repository
        -   The [build](../build) folder contains the container build configuration files (.yml, Dockerfile, etc.) for the CODE framework
        -   The [docs](../docs) folder contains the documentation for the CODE framework
        -   The [modules](../modules) folder contains the git submodules implemented for the CODE framework
        -   The [scripts](../scripts) folder contains all of the CODE framework's scripts defined for the different scopes  
            -   The [client_scripts](../scripts/client_scripts) folder contains scripts to execute on the client computer
            -   The [CODE_functions](../scripts/CODE_functions) folder contains CODE framework function definitions that are used in the different CODE scopes (client, host, container) 
            -   The [config](../scripts/config) folder contains configuration files to define the CODE configuration
            -   The [container_scripts](../scripts/container_scripts) folder contains scripts to execute within the container
            -   The [host_scripts](../scripts/host_scripts) folder contains scripts to execute on the container host
            -   The [ords_scripts](../scripts/ords_scripts) folder contains scripts to run during the startup process of the ORDS container to configure the service
        -   The [templates](../templates) folder contains a template for implementing the CODE framework from a forked repository, either directly from the CODE project or one of its forked repositories (at any depth) 
            -   \*Note: this folder was created so it can be copied into the /projects folder of the forked repository and renamed based on the project the CODE fork implements
    -   The [logs](../../logs) folder contains the log files from each CODE framework deployment process
    -   The [projects](../../projects) folder contains separate folders for each forked CODE repository to support the dependencies of the given CODE fork's project
        -   \*Note the dependencies can be database schemas/objects, apex applications, or container applications 
        -   Each "project name" subfolder represents a fork of the CODE project or one of the CODE project's forks 
            -   The "build" subfolder contains the container build configuration files (.yml, Dockerfile, etc.) for the CODE framework
            -   The "config" subfolder contains the configuration files for the specific CODE framework implementation
            -   The "docs" subfolder contains the documentation for the specific CODE framework implementation
            -   The "hooks" folder contains any pre- or post-processing scripts that follow the standard naming convention that can automatically run in the specified scope (client, host, container) 
            -   The "modules" subfolder contains the git submodules implemented for the specific CODE framework implementation
    -   The [secrets](../../secrets) folder must be populated with a secrets.sh file that contains the definition for all secret variables used in the given CODE framework implementation 
    -   The [README.md](../../README.md) file documents the CODE module
-   ### CODE Folder Diagram:
    ```
    .
    |--- core
    |    |--- build
    |    |--- docs
    |    |--- modules
    |    |    |--- CDS
    |    |--- scripts
    |    |    |--- client_scripts
    |    |    |--- CODE_functions
    |    |    |--- config
    |    |    |--- container_scripts
    |    |    |--- host_scripts
    |    |    |--- ords_scripts
    |    |--- templates
    |--- logs
    |--- projects
    |    |--- project_name
    |--- secrets 
    |--- README.md
    ```

## CODE Business Rules
-   ### Project Linear Dependency Configuration
    -   Each time a forked CODE repository is forked to create a new project, the new project references the project folder of its direct parent to establish the linear dependency relationship. 
    -   If Project B forks Project A, then Project A is a direct linear dependency of Project B. If Project C forks Project B, then Project A is an indirect linear dependency of Project C.  
    -   The top-level parent is defined by the [.active_project](../../projects/.active_project) file, the $ACTIVE_PROJECT_NAME corresponds to the folder name of the corresponding top-level parent project folder in the [/projects/](../../projects) folder
    -   The parent/fork relationship is established by the [project_parent_config.sh](../templates/project_name/config/project_parent_config.sh) file in each project folder's configuration files. The $PROJECT_FOLDER_NAME variable defines the folder name of the corresponding parent project folder in the [/projects/](../../projects) folder
    -   #### Configuration Arrays:
        -   Each time the CODE framework runs it will iterate through the defined configuration arrays and perform the defined actions
        -   The configuration arrays are defined in the corresponding project's config/project_manifest_config.sh file:
            -   PROJECT_LINEAR_DEPENDENCIES defines the order of the cascading linear dependencies starting with the foundational project-specific forked CODE repository and ending with the current forked CODE repository
            -   CUSTOM_ENV_VARS defines custom environment variables that will be declared based on the corresponding bash variables so they are available to the containers and client/host scripts, these will be declared in the order they were added to the array variable
			-   DB_SCRIPTS_MAP defines specific database scripts and their corresponding credentials so they can be executed within the code-db-ords-deploy container, the corresponding scripts will be executed in the order they were added to the array variable
                -   This is a pipe (|) delimited string of 4 or more values in the following order:
                    -   #1: sql path: the absolute path the sqlplus script should execute from
                        -   **Note: the $BUILD_PATH folder path value (/core/build/) can be used when defining the path to simplify the process
                    -   #2: sql script file: the relative path and sql script name that is executed within the container (e.g. @dev_container/create_schemas.sql) 
                    -   #3: Username Secret Name: defines the secret name for the database username used when authenicating to the database
                    -   #4: Password Secret Name: defines the secret name for the database password used when authenicating to the database 
                    -   #5-n: Script Password Secret: (optional) defines the secret name for the script password parameter specified to the script (examples include CREATE USER scripts so the passwords can be specified at runtime)
            -   SECRET_MAPPING_ARR is an associative array that defines the relationship between secret names (element name) and secret bash variable names (element value). The secret bash variable names must match variables declared in the secrets.sh file
                \*Note: when the automated deployment scripts in the CODE framework execute it will automatically define the corresponding container secrets (with a prefix of $COMPOSE_PROJECT_NAME to help ensure they are unique) so they are available in the corresponding containers 
                -   Any new secret names that are implemented in code-db-ords-deploy by scripts that are defined in DB_SCRIPTS_MAP will require a new project-specific custom container .yml file to be created in the project's build folder and then added to the COMPOSE_FILES array                    
	            -   The array element values must correspond to the secret variables specified in secrets.sh. The array element names must correspond to the actual secret names used in the given container.
            -   COMPOSE_FILES defines the custom container .yml files that will be included when the CODE framework runs, these will be included in the order they were added to the array variable
            	-   \*Note: When specifying a new .yml file, the path must be relative to the /core/build folder  
                -   \*Note: For project-specific container applications, additional .yml files can be added tio the COMPOSE_FILES array to reference the corresponding [modules](../templates/project_name/modules) directory to include the containers in the CODE container deployment
                    -   \*Note: Additional .yml files that were added to the corresponding project-specific [build](../templates/project_name/build/) folder can be added to the COMPOSE_FILES array to override the associated container configuration for the CODE implementation  
-   ### Script and Configuration Order
    -   For all of the project-specific functionality (hooks, compose files, database deployment scripts, configuration variables) the order of execution will start with the foundational linear dependency (highest parent repository) and down throughout the chain of forked repositories until the deepest fork to respect the order of dependencies.
    -   Example Scenario: Project A is forked from the CODE repository, Project B is forked from Project A, and Project C is forked from Project B
        -   For configuration files:  then when the compose files are included, project A's configuration variables are defined first and then project B's are defined which can overwrite any duplicate variables defined by project A and so on with Project C. 
        -   For project hierarchy array variables: Project A's configuration array elements are added before Project B's configuration array elements, and so on with Project C.
        -   For hooks and database deployment scripts: Project A's scripts are run before Project B, and so on with Project C to respect the linear dependencies.
-   ### Secret Definitions
    -   The /secrets/secrets.sh file's global bash variable definitions must match SECRET_MAPPING_ARR array element values to be implemented successfully
    -   The .yml configuration files must have matching secret declarations to use the corresponding container secrets that are defined in the SECRET_MAPPING_ARR 
-   ### Runtime Configuration
    -   #### User-Defined
        -    script_action: the type of script that is executed - "deploy" for CODE containers deployments and "shutdown" for shutting down the CODE containers
        -   env_name: environment name is "dev" for development scenarios, "test" for testing scenarios
            -   dev scenarios are intended for developing incremental changes to the database and test scenarios are intended to test the entire set of combined database changes starting from a known database state before they are deployed on the test and production enterprise databases   
            -   \*Note: when the env_name is "dev" it will retain the database across CODE container restarts
        -   deploy_dest: deployment destination - "local" for docker desktop CODE deployments and "server" for linux host deployments
        -   rem_vol: remove volume flag is "yes" to remove the volumes associated with the CODE container stack name or "no" to retain the volumes
            -   \*Note: if a volume is removed the data contained within it is lost, caution is advised to ensure that work is not lost or it's saved before the volume(s) are removed.
    -   #### File-Based    
        -   APP_SCHEMA_NAME is the database schema that will be used to check if the database schemas have been installed, this only applies to the [development runtime scenario](#development)
        -   DB_IMAGE is the path to the database image used to build the database contianer (code-db container)
            -   This can be updated if a specific version of the database is required
        -   ORDS_IMAGE is the path to the ORDS image used to build the ORDS/Apex container (code-ords container)
            -   This can be updated if a specific version of ORDS is required
        -   TARGET_APEX_VERSION is the version of apex that will be installed/upgraded to when the CODE framework instance is deployed
            -   For development scenarios the $TARGET_APEX_VERSION variable defined cannot be decreased once a given version of apex has been insalled on the code-db database container. If a downgrade is required the database volume (code-db-vol) needs to be deleted and then the container must be run again to install the desired version of Apex.  
        -   ORDS_ENABLED (yes/no) defines if the ORDS service is enabled (yes) or not enabled (no). This must be "yes" for Apex/ORDS functionality to be available
        -   Concurrent CODE deployments:
            -   In order for multiple CODE deployments to run concurrently on the same container host the following configuration variables must be unique:
            -   COMPOSE_PROJECT_NAME is a text string used to prefix container object names (secrets, stack, network, etc.) to help prevent naming collisions so the same CODE/fork project can run concurrently on the same host server 
                -   for server deployments this will determine the container name and the folder name for the working copy of the repository on the server
            -   DB_HOST_PORT is the port that the Oracle database will be available from on the container host
            -   ORDS_HOST_PORT is the port that ORDS will be available from on the container host
        -   Host deployment configuration:
            -   GIT_URL is the git project that will be used to build and deploy the CODE containers
            -   PRIV_USER is the privileged user on the docker host that will be used to build and deploy the CODE containers
            -   HOSTNAME is the hostname of the docker host where the CODE containers will be deployed
-   ### Automated Hooks
    -   Project-specific hooks are defined for specific timing (pre- or post-) and scope (client, host, container)
        -   The hooks will execute right before and right after the main action for the given scope.
        -   Timing:
            -   Pre: The pre action hook will execute immediately before the main action executes
            -   Post: The pre action hook will execute immediately after the main action completes
        -   Scope:
            -   client_local: For local CODE deployments, the main action is building and deploying the CODE container stack. For server deployments, the main action is executing the bash script to deploy the container remotely on the container host  
            -   client_server: For server CODE deployments, the main action is sending the ssh command to the server to execute the CODE deployment            
            -   host_prepare: For server CODE Deployments, the main action is executing the host deployment script using the designated account with elevated container privileges  
            -   host_deploy: For server CODE Deployments, the main action is building and deploying the CODE container stack
            -   container: The main action is executing the database scripts to update the database and/or install apex application(s)
    -   The naming convention for these files is: [timing]_[scope]_hook.sh. For example, pre_container_hook.sh will run immediately before the database scripts are executed within the container
    -   These hook script files are saved in the corresponding project fork's /projects/project_name/hook folder
-   ### Container Deployments
    -   When the 

## Container Architecture
-   The code-db container is built from an official Oracle database image, this is defined by DB_IMAGE in the [file-based configuration](#file-based)
-   The code-db-ords-deploy container is built from a custom dockerfile ([Dockerfile.deploy](../build/Dockerfile.deploy)) that uses an official Oracle InstantClient image with some custom libraries installed.  
    -   This container waits until the code-db container is running and the service is healthy before running the [container_deploy_database.sh](../scripts/container_scripts/container_deploy_database.sh) bash script
        -   If ORDS_ENABLED="yes" and TARGET_APEX_VERSION is a valid version of Apex the script will install/upgrade Apex in the code-db and code-ords containers
        -   The script will then deploy all database schemas, database objects, and when applicable the Apex workspaces, and Apex apps
    -   Once the code-db_ords_deploy container finishes deploying the database schemas/apps the container will shut down.  
-   The code-ords container is built from an official Oracle ORDS image, this is defined by ORDS_IMAGE in the [file-based configuration](#file-based)  
    -   This container runs [ords_startup.sh](../scripts/ords_scripts/ords_startup.sh) in the container before the ORDS container's official docker entrypoint executes. This script specifies the required Apex and ORDS configuration
        -   \*Note: the apex configuration files are generated instead of using the CLI ORDS commands to specify the configuration because each CLI command took several seconds to execute.

## CODE Implementation Procedure
-   \*Note: this process will fork a given CODE repository and repurpose it as a project-specific CODE
-   ### Forking the Repository
    -   Fork the desired CODE repository (e.g. [CODE](#code-version-control-information)
        -   In the git web interface update the name/description of the forked project to specify the data system that is implemented in CODE
    -   Clone the forked project recursively to a working directory
-   ### CODE Template 
    -   Copy the [project template](../templates/project_name) folder into the [/projects](../../projects) folder
        -   \*Note: Do not modify any of the other folders within the [/projects](../../projects) folder since those are managed in upstream forked CODE repositories.
        -   Rename the copied "project_name" template folder to a descriptive name for the project (e.g. staff-info-app, longline-cost-earnings)
        -   Update the [.active_project](../../projects/.active_project) file to set the value of $ACTIVE_PROJECT_NAME variable value to the name of the renamed project folder
            -   This indicates to the CODE framework which project is the active project which determines the order in which the dependencies (when applicable) are deployed  
        -   #### Forked Project Customization
            -   Update the [projects/$ACTIVE_PROJECT_NAME/config/project_parent_config.sh](../templates/project_name/config/project_parent_config.sh) configuration file to set $PROJECT_FOLDER_NAME to the name of the folder in the [/projects](../../projects) folder that contains the current project's direct linear dependency
                -   \*Note: The parent project's $ACTIVE_PROJECT_NAME value can be copied into the $PROJECT_FOLDER_NAME variable for the current project to define the direct dependency
            -   Rename and update the [projects/$ACTIVE_PROJECT_NAME/build/secrets.template.yml](../templates/project_name/build/secrets.template.yml) template file to define any additional secrets for the code-db-ords-deploy container and any configuration overrides for containers that are being added for the forked repository
                -   (When applicable) If there are container application(s) associated with the given project, additional .yml files can be added in the corresponding project-specific [build](../templates/project_name/build/) folder to override the associated container configuration values  
            -   Add any project-specific repository dependencies as git submodules in the [modules](../templates/project_name/modules/) subfolder
            -   Update the [projects/$ACTIVE_PROJECT_NAME/config/project_manifest_config.sh](../templates/project_name/config/project_manifest_config.sh) configuration file with the basic information about the forked CODE implementation:
                -   PROJECT_LINEAR_DEPENDENCIES should add an array element with the $ACTIVE_PROJECT_NAME 
                -   DB_SCRIPTS_MAP: add an array element for each automated database deployment script that will be run on deployments with the corresponding secret names
                -   CUSTOM_ENV_VARS array values for any custom environment names that need to be transmitted to any of the containers on startup
                -   COMPOSE_FILES to add any .yml files from the project's repository and/or any configuration overrides
                -   SECRET_MAPPING_ARR array elements/values that correspond to the secret name (element name) and the corresponding bash variable defined in the secrets.sh as the value
            -   Update the [projects/ACTIVE_PROJECT_NAME/config/project_runtime_config.sh](../templates/project_name/config/project_runtime_config.sh) configuration file with any global configuration variable values that are specific to this project (e.g. COMPOSE_PROJECT_NAME, APP_SCHEMA_NAME, GIT_URL, ORDS_ENABLED, TARGET_APEX_VERSION, etc.)
                -   For more information refer to the [Runtime Configuration Business Rules](#runtime-configuration) section
            -   Create any special hooks in the [projects/$ACTIVE_PROJECT_NAME/hooks](../templates/project_name/hooks) folder with the defined naming convention based on the timing and scope of the hook
            -   Rename and update the [projects/$ACTIVE_PROJECT_NAME/docs/CODE Fork Documentation.template.md](../templates/project_name/docs/CODE%20Fork%20Documentation.template.md) documentation template
                -   Update the documentation to specify any relevant information about the forked repository   
            -   Update the [secrets.template.sh](../../secrets/secrets.template.sh) template file to include placeholder variables for any secret values used inside of the forked repository.
-   ### Implementation Examples
    -   Standalone database with no dependencies: [DSC CODE](https://github.com/noaa-pifsc/PIFSC-DSC-Containerized-Oracle-Development-Environment)
    -   Oracle database and PHP web container application: [Staff Information Application (SIA) CODE](https://github.com/noaa-pifsc/PIFSC-SIA-Containerized-Oracle-Development-Environment)
    -   Oracle database and Apex application: [Centralized Authorization System (CAS) CODE](https://github.com/noaa-pifsc/PIFSC-CAS-Containerized-Oracle-Development-Environment)
-   ### Upstream Updates
    -   This project has been structured specifically to minimize the need to merge upstream changes as the CODE project continues to evolve and accommodates chains of forked projects that have complex dependencies. 
        -   Each forked repository has its own dedicated project folder so pulling upstream changes will not trigger any merge conflicts
        -   The [core](../) folder contains all of the CODE framework's source code so when changes are made to the [CODE repository](#code-version-control-information) those upstream changes can be pulled by the individual forked repositories without triggering merge conflicts
            -   \*Note: the core folder should only be modified in the CODE repository
        -   The other project-specific folders for the current project's dependencies within the [/projects](../../projects) folder should never be modified since those are managed in upstream forked CODE repositories.  Instead, when upstream changes are made they should be pulled by the corresponding forked projects.
        -   Global bash array configuration variables are defined by the CODE framework and then the individual projects add elements to these arrays which determine the behavior of the CODE framework.
    -   The [projects/.active_project](../../projects/.active_project) file has been configured specifically to ignore upstream changes since it is expected to change every time a fork is created since it designates the active project folder.
    
## Setup
-   Recursively clone the given CODE project to a directory on the local client computer
-   Within the project repository create the necessary bash file with the secret values for each database schema and apex workspace: secrets.sh in the [/secrets](../../secrets) folder
    -   \*Note: There is a [secrets template](../../secrets/secrets.template.sh) file that can be used to create the secrets.sh file for each database instance 
    -   \*Note: the actual secret files should never be committed to the repository for security purposes, a [.gitignore](../../.gitignore) file has been added to the repository to prevent these sensitive files from being included in git.  
    -   \*Note: The secrets.sh will only set the oracle database administrator password to $ORACLE_PWD on the initial database container run. On the initial run and subsequent runs it will set the APEX and ORDS administrator passwords to $ORACLE_PWD and use the defined $ORACLE_PWD to authenticate to the database
        -   \*Note: this approach allows the Apex installation to be stateless, so even if the apex volume is dropped it will be rebuilt with the corresponding $TARGET_APEX_VERSION next time the container runs.  
-   #### CODE Repository
    -   \*Note: the CODE framework can be run directly from the CODE repository to provide a standard Oracle development environment with minimal setup. 
    -   \*Note: the CODE repository can also be forked to customize the standard Oracle development environment   
    -   Update the [default_CODE_runtime_config.sh](../scripts/config/default_CODE_runtime_config.sh) configuration file to specify the appropriate runtime configuration
-   #### Forked Repositories
    -   \*Note: the CODE repository forks can customized for specific data systems and then those forks can be forked to build on those specific data system dependencies.
    -   Update the [/projects/$ACTIVE_PROJECT_NAME/config/project_runtime_config.sh](../templates/project_name/config/project_runtime_config.sh) configuration file to specify the appropriate runtime configuration 
-   To allow multiple developers to use CODE concurrently on the same container host, update the three variables identified in the top section: COMPOSE_PROJECT_NAME, DB_HOST_PORT, and ORDS_HOST_PORT to have unique values
    -   \*Note: refer to the the [file-based configuration](#file-based) for more information
-   Setup docker swarm (one-time setup): `docker swarm init`

## Executing the CODE Project
-   \*Note: The variables listed below are global bash variables that are defined in the configuration files of the given project-specific CODE implementation.
-   Following the [Setup](#setup) process, execute the [client_execute_CODE_scripts.sh](../scripts/client_scripts/client_execute_CODE_scripts.sh) script using bash and specify the appropriate script parameters:
    -   \*Note: refer to the the user-defined configuration [business rules](#user-defined) for more information
    -   script_action: the type of script that is executed - "deploy" for CODE containers deployments and "shutdown" for shutting down the CODE containers
    -   env_name: environment name - "dev" for development, "test" for testing purposes)
        -   \*Note: when the env_name is "dev" it will retain the database across CODE container restarts
    -   deploy_dest: deployment destination - "local" for docker desktop CODE deployments and "server" for linux host deployments
    -   rem_vol: remove volume flag - "yes" to remove the volumes associated with the CODE container stack name or "no" to retain the volumes
        -   \*Note: if a volume is removed the data contained within it is lost, caution is advised to ensure that work is not lost or it's saved before the volume(s) are removed.
        -   \*Note: scenarios where a volume should be removed include: a lower version of Apex is required for a given Apex application, or the database data needs to be replaced or re-seeded.
    -   Examples:
        -   Executing a deployment for a development environment locally without removing the volumes first: 
            -   `bash client_execute_CODE_scripts.sh deploy dev local no`
        -   Executing a shutdown for a development environment on the server and remove the associated volumes: 
            -   `bash client_execute_CODE_scripts.sh shutdown dev server yes`
-   ### Runtime Scenarios:
    -   There are two different runtime scenarios implemented in this project. Both scenarios implement a docker volume for the Apex static files (apex-static-vol) that are used in the Apex upgrade process
    -   The $ORDS_ENABLED global bash variable (defined in [custom_container_config.sh](../scripts/config/custom_container_config.sh)) determines if the ORDS/Apex container is enabled
        -   If $ORDS_ENABLED is "yes" then the [CODE-ords.yml](../build/CODE-ords.yml) file is loaded during the building/running of the CODE containers to make the ORDS/Apex container available. 
            -   If the $ORDS_ENABLED is "yes" and the $TARGET_APEX_VERSION variable is defined and valid, then it will install the matching version of Apex version in the code-db and code-ords container.
        -   If $ORDS_ENABLED is "no" then the ORDS/Apex container is omitted from the CODE containers.
    -   #### Development:
        -   (env_name = "dev") This scenario retains the database across container restarts, this is intended for database and application development purposes
        -   This scenario implements a docker volume for the database files (code-db-vol) to retain the database data across container restarts
        -   \*Note: refer to the the file-based configuration [business rules](#file-based) for more information about $TARGET_APEX_VERSION
        -   \*Note: the initial container run can take up to approximately 30 minutes depending on the resources allocated to the container platform software since the database is initialized and when $ORDS_ENABLED is "yes" it also installs Apex on the ORDS container
    -   #### Test:
        -   (env_name = "test") This scenario does not retain the database across container restarts, this is intended to test the deployment process of schemas and applications
        -   \*Note: the container run process can take up to approximately 30 minutes depending on the resources allocated to the container platform software since the database is initialized and when $ORDS_ENABLED is "yes" it also installs Apex on the ORDS container
-   A log file for each client script execution is saved in the [logs](../../logs) folder and is named client_deploy_application.sh.$(date +%Y%m%d_%H%M%S).log based on the date/time the script is executed.  This file will include the output from the remote host and container scripts
-   ### CODE Execution Diagram
    -   The [CODE execution diagram](../docs/diagrams/CODE_execution_diagram.drawio.png) provides an overview of the CODE execution for both server and local deployments.
    -   Local Deployments:     
        -   (Shown as 1a) The Client Deployment Script runs to build and deploy the CODE Containers locally using Docker Desktop
    -   Server Deployments:
        -   (Shown as 2a) The Client Deployment Script runs and uses SSH to clone the repository and execute the Host Preparation Script
        -   (Shown as 2b) The Host Preparation Script runs and uses the "sudo -u" command to run the Host Deployment Script with a privileged server user that can run container commands
        -   (Shown as 2c) The Host Deployment Script runs to build and deploy the CODE Containers on the Docker Host
    -   CODE Container Deployments:
        -   The Database Deployment Container automatically runs on startup 
            -   (Shown as 3a) If $ORDS_ENABLED="yes" is enabled and $TARGET_APEX_VERSION is a valid version of Apex then the ORDS and DB containers will have the specified version of Apex installed
            -   (Shown as 3b) The custom project-specific scripts will execute to deploy the corresponding database objects    
    -   \*Note: Additional containers can be deployed using the COMPOSE_FILES variable from the custom [Configuration Arrays](#configuration-arrays)
![CODE execution diagram](../docs/diagrams/CODE_execution_diagram.drawio.png)

## Connection Information
For the following connections refer to the active [file-based configuration](#file-based) and the /secrets/secrets.sh for the corresponding $ORACLE_PWD value
-   \*Note: For server deployments the following command can create an SSH tunnel between the server and the developer workstation to allow the following URLs to connect to the corresponding server endpoints (where the variable references match the runtime values when the CODE containers were deployed):
    -   `ssh -N -L ${ORDS_HOST_PORT}:localhost:${ORDS_HOST_PORT} -L ${DB_HOST_PORT}:localhost:${DB_HOST_PORT} dev_docker`
-   Database connections:
    -   hostname: localhost:\$\{DB_HOST_PORT\}/$\{DBSERVICENAME\}
    -   username: SYSTEM or SYS AS SYSDBA
    -   password: \$\{ORACLE_PWD\}
-   Apex server:
    -   hostname: http://localhost:\$\{ORDS_HOST_PORT}/ords/apex
    -   workspace: internal
    -   username: ADMIN
    -   password: \$\{ORACLE_PWD\}
-   ORDS server:
    -   hostname: http://localhost:\$\{ORDS_HOST_PORT\}/ords

## Security Features
-   The CODE project inherits security features from the [CDS module](./modules/CDS/README.md#security-features).
-   Secure In-Memory Data Transmission (STDIN): Secret values (like passwords and API keys) are never passed as command-line arguments. Instead, they are securely transmitted to remote servers, and between script calls, purely via standard input (STDIN / pipelining). This prevents sensitive data from appearing in process lists, system logs, or bash history files.
-   Decoupled Configuration Adapter Pattern: The core CODE engine enforces a strict Separation of Concerns. It remains completely independent of project-specific global variables. It only operates on strictly validated associative arrays passed from the client adapter, ensuring that the engine itself cannot inadvertently expose or mishandle project-specific configurations.
-   Docker Secrets: Database credentials are defined as secrets and retrieved dynamically within the container to protect them from unauthorized access
-   Immutable Shell Executions: When elevating privileges to run container commands, CODE utilizes rigid Heredocs (\<\<EOF) to pipe commands into the new shell. This creates an immutable execution block that safely separates the runtime variables from the raw secret payload.