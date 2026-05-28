# PIFSC Containerized Oracle Development Environment Presentation

## Overview
This project was created to provide a containerized Oracle developer environment (ODE) for PIFSC software developers so they can develop databases and APEX applications locally and deploy them to the enterprise test and production server instances.  This flexible collection of containers can be customized to include database and APEX application dependencies for systems that are deployed to the test and production instances to help ensure that the software will work as intended when it is deployed to the enterprise server instances.  

## Outline
-   Documentation (show in GitHub)
    -   overview
    -   Appropriate Use (only intended for dev/test scenarios, not production)
    -   Prerequisites
        -   _ need docker login?
        -   Bash and SSH
        -   automated database deployment, this framework doesn't deploy the database for you, but it will execute the automated scripts to deploy/upgrade the database
    -   Dependencies (CDS is used as the core engine for the CODE project)    
    -   Container architecture
        -   3 core standard containers depending on the runtime configuration 
        -   code-db uses the official Oracle database image
        -   code-db-ords-deploy is a custom container intended to deploy databases and apex applications when the CODE containers startup and then shuts down
        -   code-ords is the official ORDS image (does not come with Apex pre-installed out of the box), this is included based on the runtime configuration variables
    -   naming conventions (pause if there are questions, should be self-explanatory)
    -   fork network diagram
        -   each directed arrow represents a parent-fork relationship where the source connector is the parent and the arrow connector is the forked repository of child repository
        -   You can see how they build on each other based on the dependencies the given forked repository has
        -   (pause for any questions)
    -   CODE folder structure
        -   intended to prevent merge conflicts when pulling upstream changes 
        -   core folder is managed by the actual CODE repository and the changes are pulled into the individual forks, no downstream forks should update any of these files
            -   The core folder can function on its own as a standalone dev environment
            -   build contains the .yml files and custom Dockerfile 
                -   separate files for different use cases (based on runtime configuration) that are added to an array so the .yml files can be specified at runtime
            -   scripts contains the core CODE scripts that are used for every CODE framework deployment
            -   templates folder can be copied into the projects folder and renamed to customize a given forked project
        -   logs folder contains logs of the deployment scripts
        -   projects folder contains separate folders for each forked repository
            -   the only repository that can modify a given project folder is the one that corresponds to the project folder (e.g. don't modify other project folders since that will introduce unintended changes that are not properly reflected in the upstream repositories)
            -   build contains custom .yml files needed for the CODE implementation. Intended to add secrets to the database deployment container
        -   secrets/secrets.sh defines the credentials for the database schemas and any other endpoints (e.g. API keys)
            -   This is a cumulative file for all dependencies that is not managed in version control
            -   Used to define the credentials for the database objects and also to connect to deploy the appropriate database objects
        -   (pause for any questions)
    -   CODE Business Rules
        -   This defines how the behavior of the application is driven by configuration files and allows custom code to be injected for a given forked project using hooks for specific scopes and timing
        -   Linear dependency example (review so we can use that as the example)
        -   Linear dependency configuration
            -   active project (deepest fork)
            -   linear dependency (defined by configuration file pointing towards parent project's folder)
            -   Top-level parent (highest parent project, excluding CODE repo)
        -   Configuration arrays
            -   These drive the behavior of the framework, they are implemented in order from the top-level parent through the dependency chain, to the active project
            -   CUSTOM_ENV_VARS - defines custom environment variables needed by the CODE containers
            -   DB_SCRIPTS_MAP - defines the automated database deployment scripts that run when the CODE containers start
            -   SECRET_MAPPING_ARR - defines the relationship between the bash variables defined in the secrets.sh file and the container secret names so these can be defined accordingly
            -   COMPOSE_FILES - defines the .yml files that are included for the CODE framework and project dependencies
        -   Secret definitions
            -   ORACLE_PWD is the password defined for all of the system accounts
        -   Runtime configuration
            -   user-defined configuration when the scripts are executed:
                -   deploy/shutdown
                -   environment name (dev or test) -> dev will retain the database data using a volume and test will not retain the database data so deployments/upgrades can be tested from the current enterprise database version to help ensure they will work when they are deployed
            -   file-based configuration 
                -   options for port numbers, ORDS/Apex enabled, application schema name (to determine if the database has already been deployed -> to prevent redeployments on subsequent "dev" deployments)
        -   Automated hooks
            -   multiple scopes (client local, host deploy, container, etc.) and timing (pre and post event)
                -   These allow custom project-specific code to be run by the core CODE framework, so far I have only had to use it in one project (PRI) because it also needs to define a CRON schedule
    -   CODE implementation procedure
        -   uses the CODE project template and an SOP to fork the appropriate repository and customize it for a specific data system
        -   (We don't need to review this in detail unless you would like to)
        -   Implementation examples developers can review to see how they were configured
    -   Setup process
        -   recursively clone the desired repo
        -   create the secrets.sh file
        -   There are two runtime scenarios
            -   This can be run as-is from the CODE repository if the user wants to have a blank database and ORDS/Apex to begin experimenting/building a database/application
                -   Update runtime configuration 
            -   This can also be run from a forked CODE repository
                -   Update runtime configuration 
            -   The configuration supports running multiple instances of the same CODE project on the same container host, by defining unique values for 3 configuration variables
    -   Executing the CODE project
        -   Specify the user-defined runtime arguments or provide them when prompted by the script
        -   Runtime Scenarios:
            -   Development -> retains the database data using a volume across restarts
            -   Test -> does not retain the database, so deployments can be tested
            -   this framework supports flexible software development workflows:
                -   development and test deployments can be run concurrently to allow flexible software development workflows. 
                -   For example, a development instance can be used for incremental development and the updated database scripts can be periodically tested by deploying them with a test environment to ensure the database deployment process works properly. The database diff tool can be used to ensure the deployment process on the test instance produces the same data model as the development instance    
        -   CODE Execution Diagram (show image)
            -   This is the main workflow that includes both local and server deployments
            -   For local deployments, the client deployment script defines the secrets and runs the containers
            -   For server deployments, the client connects to the container host via SSH and clones the repository and executes the server preparation and deployment scripts
            -   When the CODE containers run, the code-db-ords-deploy container will optionally install/upgrade apex based on the runtime configuration
                -   Then it will check if the database schema specified in the runtime configuration already exists, if not it will deploy the database objects using the specified database scripts using the configuration arrays that are defined for the projects in the defined linear dependencies
-   Contributions and Repository Management
    -   to prevent merge conflicts some contribution guidelines have been established    
    -   as mentioned earlier the CODE repository is the only repository that can make changes to files/folders in the core folder
    -   for downstream code forks the given repository should only make changes to files/folders in the project-specific projects folder
-   Monitoring and Syncing Upstream Updates
    -   Watch upstream releases on GitHub
        -   Watch the direct parent for the repository for releases and security alerts, upstream changes can be pulled and merged to take advantage of updates    
        -   (Optionally) watch the direct parent for the repository for releases and security alerts, the changes can't be pulled until they are merged by the parent repository
    -   syncing procedure
        -   Basically just pull and merge the upstream changes, the vast majority of the git pulls should merge automatically because the project-specific files should be kept separate from upstream updates
        -   .active_project is configured to automatically ignore upstream changes because it is intended to change for every fork
        -   handle merge conflicts as normal with standard Git tools
-   Connection information
    -   Can create an SSH tunnel for server deployments so the application and database endpoints can be accessed
    -   connection information is listed for each type of resource








-   Look at forked repository examples (review code)
    -   DSC (simplest of all, contains the current login function so it is used by many different data systems)
    -   CAS (DB dependency + custom DB and Apex application)
    -   CTP (more complicated with dependency layers)
    -   PRI (most complicated container app)
        -   show the minimal code involved to define configuration array elements and the custom hooks for the API key


-   Receiving notifications for available updates
    -   PRI could provide information about utilization based on matching version tags
        -   PRI could be modified to parse the .gitsubmodules to determine how many times a given repository is implemented as a submodule (e.g. CDS, CAD, CDD utilization)
        -   PRI could be modified to use github as a data source so we can map the github repos















    -   execution diagram



        -   divide into core and projects categories
-   Base Image
    -   Look at the .yml files
    -   DB uses DB and ORDS images directly
    -   Custom DB deployment container that install/upgrades APEX and deploys DB objects and Apex apps (when applicable)

-   Look at the runtime configuration
    -   used to specify the behavior of the containers (Apex version, ORDS enabled, DB image, ports, etc.)



-   Fork examples:
    -   look at the project-specific configuration files -> parent project config
        -   look at the implementation documentation (what needs to be configured)

    -   custom standalone DB (for local database development and to implement data dependencies)
    -   custom DB + Apex (for local data system development, and to implement dependencies -> one or more DB schemas and apps)
    -   custom DB + container apps (for local data system development, and to implement dependencies -> one or more DB schemas and container apps)






















-   Base image:
    -   Build and run the trivial case using the dev configuration
        -   Remove all containers, images, and volumes first
        -   Show that the database and APEX server are available (when we first build the DB and install APEX it takes a while)
        -   Pull down the containers (docker compose down)
        -   Build and run the trivial case using the dev configuration (show that the process takes a lot less time when the data volume exists and APEX is already installed in the database container)
    -   Show project README.md
    -   Show file system
        -   docker folder contains the files used to build the images and run the containers
        -   automated_deployments folder contains automated bash scripts
            -   project_config.sh - defines variables that are used to prepare and build the images and run the containers, these specify the directory location for the prepared directory  
            -   prepare_docker_project.sh - to prepare a directory with files from the different data system repositories that will be used to build a custom SQLPlus image that is used to deploy the data systems.  It clones the corresponding repositories and copies the necessary files to the docker/src folder that is used to build the image  
            -   build_deploy_project.sh (dev and test options exist for different scenarios), they each use their own docker-compose.yml files based on the scenario.  These scripts build the images and run the containers
    -   Show the main files (docker folder)
        -   dev and test.yml files
            -   auto-xe-reg - Utilizes the official Oracle database express (XE) and ORDS-Developer images from the Oracle container registry
             -   auto-ords-reg - Configured for the ORDS/APEX container to start after the XE database is up and running (service-healthy)
            -   auto-db-app-deploy - custom SQLPlus image that is used to deploy the database schemas and APEX workspaces, and APEX applications to the express database.  This container starts after the XE database is up and running (service-healthy)
            -   docker volumes are created for the development scenario so the schemas and APEX objects are retained across restarts of the containers so developers can pick up where they left off.  The test scenario has no docker volumes explicitly created since this scenario is intended to deploy everything to a blank database server  
        -   Dockerfile.deploy is used to build the custom SQLPlus image with data system files that are copied from the docker/src folder
        -   conn_string.txt is used to define the connection string including credentials for the APEX container that are used to connect to the express database container
        -   src/run_db_app_deployment.sh - this is the bash script that will automaticaly run when the database and/or APEX server are available
            -   The script specifies variables to store database connection details and evaluate them when executing the individual DB/app deployment SQLPlus scripts
            -   It defines a check_database_initialized() function to specify a schema ([SCHEMA_NAME] - e.g. DSC) that will exist if the database has been provisioned previously
            -   The bash script executes the SQLPlus scripts in a specific order to respect dependencies to deploy schemas, APEX workspaces, and APEX apps that were copied to the /src directory when the [prepare_docker_project.sh](../deployment_scripts/prepare_docker_project.sh) script is executed.
                -   If the project has already initialized the database then it will not run the automated SQLPlus deployment scripts
    -   Show README documentation
        -   This project is intended to be forked so it can be quickly customized for specific data systems.  SOP provided for how to customize the project
        -   This project is also intended to have its child repos forked as well.  For instance the base repository was forked to implement the DSC schema which is used in many different data systems (performs authentication and other standardized procedures/functions are provided).  The DSC fork was then forked again for the Centralized Authorization System since it depends on the DSC schema.  This way when improvements are made to the parent repository they can be pulled into the forked repositories.  Also, it makes it easier to build off of a container that already handles the dependencies of the given project
    -   Next, look at the DSC repo
        -   This was forked from the parent repo
        -   Simple schema with no dependencies
        -   Only have to change a few files to customize it for the new Oracle data system
            -   project_config.sh needs to be updated to specify the ODE git url and the root/project directory paths.  It is also updated to specify any additional external repositories that are used when building the custom SQLPlus image
            -   Preparation script was updated (this is an important script)
                -   Updated the script to use the git URLs to retrieve the external repository files and copy them to the appropriate folders within the docker/src folder
                -   The code to wait until APEX is installed was commented out since there are no APEX workspaces/apps that need to be deployed in this scenario
            -   run_db_app_deployment.sh was updated (this is an important script)
                -   Updated to run the additional SQLplus scripts to create the DSC schema, grant privileges, and deploy the DSC objects
        -   The rest of the files don't change much from the base image except for the documentation since it defines the dependencies and provides other important information
        -   Look at the README.md
            -   (Resources Section) It specifies the git repositories used in the DSC ODE project
             -   (Automated Preparation Process) It specifies the files that were copied into the docker/src folder of the prepared directory
            -   (Automated Deployment Process) It specifies the SQLPlus scripts that are executed when the custom SQLPlus container is run
            -   The rest of the sections are largely the same as the parent repository
    -   Next, look at the CAS repo
        -   This was forked from the DSC repo
        -   DB schema, APEX app with a dependency on DSC
        -   Only have to change a few files to customize it for the new Oracle data system
            -   project_config.sh was updated with the project directory path and URLs for the CAS repo and the CAS ODE project
            -   Preparation script was updated (this is an important script)
                -   Updated the script to use the git URLs to retrieve the CAS repository files and copy them to the appropriate folders within the docker/src folder
                -   The code to wait until APEX is installed was uncommented since the CAS data system has an APEX app
            -   run_db_app_deployment.sh was updated (this is an important script)
                -   Updated to run the additional SQLplus scripts to create the CAS schema, grant privileges, and deploy the CAS database objects and CAS APEX app
        -   Look at the README.md
            -   (Resources Section) It specifies the git repositories used in the CAS ODE project
             -   (Automated Preparation Process) It specifies the files that were copied into the docker/src folder of the prepared directory
            -   (Automated Deployment Process) It specifies the SQLPlus scripts that are executed when the custom SQLPlus container is run
            -   The rest of the sections are largely the same as the parent repository
