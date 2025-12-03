#!/bin/sh

# define any database/apex credentials necessary to deploy the database schemas and/or applications

# define DSC schema credentials
DB_DSC_USER="DSC"
DB_DSC_PASSWORD="[CONTAINER_PW]"

# define DSC connection string
DSC_CREDENTIALS="$DB_DSC_USER/$DB_DSC_PASSWORD@${DBHOST}:${DBPORT}/${DBSERVICENAME}"

# define the DSC database folder path
DSC_FOLDER_PATH="/usr/src/DSC/SQL"


# define CU schema credentials
DB_CU_USER="CEN_UTILS"
DB_CU_PASSWORD="[CONTAINER_PW]"

# define CU connection string
CU_CREDENTIALS="$DB_CU_USER/$DB_CU_PASSWORD@${DBHOST}:${DBPORT}/${DBSERVICENAME}"

# define the CU database folder path
CU_FOLDER_PATH="/usr/src/CU/SQL"