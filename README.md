# PIFSC Oracle Developer Environment

## Overview
The PIFSC Oracle Developer Environment (ODE) project was developed to provide a containerized Oracle development environment for PIFSC software developers.  The project can be extended to automatically create/deploy database schemas and applications to allow data systems with dependencies to be developed and tested using the ODE.  This repository can be forked to customize ODE for a specific software project.  

## Resources
-   ### ODE Version Control Information
    -   URL: https://picgitlab.nmfs.local/oracle-developer-environment/pifsc-oracle-developer-environment
    -   Version: 1.0 (git tag: ODE_v1.0)
-   [ODE Demonstration Outline](./docs/demonstration_outline.md)

# Prerequisites
-   Have Docker Installed(of course)
-   <mark>Create an account & test login to Oracle Image Registry</mark>
    -   [Oracle Image/Container Registry](https://container-registry.oracle.com/ords/f?p=113:10)
-   Then, in a command(cmd) window, Log into Oracle Registry
```
docker login container-registry.oracle.com
```
-   To sign in with a different user account, just use logout command:
```
docker logout container-registry.oracle.com
```
-   And Pull the latest Oracle XE & ORDS Images from the Oracle Registry
    -   \*Note: Oracle's container registry will not allow downloads from within the PIFSC network, you must disconnect before you can download the images or you will need to get them a different way (container registry, .tar.gz files, etc.)
```
docker pull container-registry.oracle.com/database/express:latest
docker pull container-registry.oracle.com/database/ords-developer:latest
```

## Customization Process
-   \*Note: this process will fork the ODE parent repository and repurpose it as a project-specific ODE
-   Fork the [project](#ode-version-control-information)
    -   Update the name/description of the project to specify the data system that is implemented in ODE
-   Clone the forked project to a working directory
-   Update the forked project in the working directory
    -   Update the [documentation](./README.md) to reference all of the repositories that are used to build the image and deploy the container
    -   Update the [prepare_docker_project.sh](./deployment_scripts/prepare_docker_project.sh) bash script to retrieve DB/app files for all dependencies (if any) as well as the DB/app files for the given data system and place them in the appropriate subfolders in the [src folder](./docker/src)
    -   Update the [project_config.sh](./deployment_scripts/sh_script_config/project_config.sh) bash script to specify the variable values that will be used to identify the repositories to clone for the container dependencies and to specify the root folder and the prepared project folder
    -   Specify the password for the SYS and SYSTEM database accounts
        -   Update the [conn_string.txt](./docker/variables/conn_string.txt) to specify the password for the SYS and SYSTEM database accounts.
             -   CONN_STRING=sys/[PASSWORD]@database:1521/XEPDB1 where [PASSWORD] is the specified password
        -   Update the docker-compose.yml files to specify the password for the SYS and SYSTEM database accounts in the following line: "ORACLE_PWD=[PASSWORD]" where [PASSWORD] is the specified password
            -   Development scenario: [docker-compose-dev.yml](./docker/docker-compose-dev.yml)
            -   Test scenario: [docker-compose-test.yml](./docker/docker-compose-test.yml)
    -   Update [run_db_app_deployment.sh](./docker/src/run_db_app_deployment.sh) bash script to automatically deploy the database schemas, schema objects, APEX workspaces, and APEX applications.  This process can be customized for any Oracle data system.
        -   Update the check_database_initialized() function definition to specify a schema ([SCHEMA_NAME] - e.g. DSC) that will exist if the database has been provisioned
        -   Update the Database connection details (DB_PASSWORD variable) to match the [PASSWORD] value specified in the .yml and conn_string.txt files
        -   Specify any additional variables to store database connection details and evaluate them when executing the individual DB/app deployment SQLPlus scripts
        -   Update the bash script to execute the SQLPlus scripts in the proper order to deploy schemas, APEX workspaces, and APEX apps that were copied to the /src directory when the [prepare_docker_project.sh](./deployment_scripts/prepare_docker_project.sh) script is executed.
-   ### Implementation Examples
    -   Single database with no dependencies: [DSC ODE project](https://picgitlab.nmfs.local/oracle-developer-environment/dsc-pifsc-oracle-developer-environment)
    -   Database and APEX app with a single database dependency: [Centralized Authorization System (CAS) ODE project](https://picgitlab.nmfs.local/oracle-developer-environment/cas-pifsc-oracle-developer-environment)
    -   Database and APEX app with two levels of database dependencies and an application dependency: [PARR Tools ODE project](https://picgitlab.nmfs.local/oracle-developer-environment/parr-tools-pifsc-oracle-developer-environment)

## Deployment Process
-   ### Prepare the folder structure
    -   Run the [prepare_docker_project.sh](./deployment_scripts/prepare_docker_project.sh) bash script to prepare a folder by retrieving the DB/app files for all dependencies (if any) as well as the DB/app files for the given data system which will be used to build and run the ODE container
-   ### Build and run the container
    -   Navigate to the prepared folder (e.g. /c/docker/pifsc-oracle-developer-environment/docker) to build and run the container
    -   #### Choose a runtime scenario:
        -   Development: The [build_deploy_project_dev.sh](./deployment_scripts/build_deploy_project_dev.sh) bash script is intended for development purposes   
            -   This scenario retains the Oracle data in the database when the container starts by specifying a docker volume for the Oracle data folder so developers can pick up where they left off
        -   Test: The [build_deploy_project_test.sh](./deployment_scripts/build_deploy_project_test.sh) bash script is intended for testing purposes
            -   This scenario does not retain any Oracle data in the database so it can be used to deploy schemas and/or APEX applications to a blank database instance.  This can be used to test the deployment process.  

## Container Architecture
-   The auto-xe-reg container is built from the official Oracle database express image maintained in the Oracle container registry
-   The auto-ords-reg container is built from the official Oracle ords-developer image maintained in the Oracle container registry and contains both ORDS and APEX capabilities
    -   This container waits until the auto-xe-reg container is running and the service is healthy
-   The auto-db-app-deploy container is built from a custom dockerfile that uses an official Oracle InstantClient image with some custom libraries installed and copies the source code from the [src folder][./docker/src].  
    -   This container waits until the auto-xe-reg container is running and the service is healthy and APEX has been installed on the database container
    -   This container runs the [run_db_app_deployment.sh](./docker/src/run_db_app_deployment.sh) bash script to deploy all database schemas, APEX workspaces, and APEX apps
    -   Once the container finishes deploying the database schemas/apps the container will shut down.  

## Connection Information
-   Database connections:
    -   hostname: localhost:1521/XEPDB1
    -   username: SYSTEM or SYS AS SYSDBA
    -   password: [PASSWORD] as it is specified when the database is first created
-   APEX server:
    -   hostname: http://localhost:8181/ords/apex
    -   workspace: internal
    -   username: ADMIN
    -   password: Welcome_1
-   ORDS server:
    -   hostname: http://localhost:8181/ords
