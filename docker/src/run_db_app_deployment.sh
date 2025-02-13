#!/bin/bash

# Database connection details
DB_HOST="auto-xe-reg"
DB_PORT="1521"
DB_SID="XEPDB1"
DB_USER="sys"
DB_PASSWORD="[PASSWORD]"
DB_ROLE="SYSDBA"  # Can be adjusted depending on the role needed

SYS_CREDENTIALS="$DB_USER/$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_SID as $DB_ROLE"

# define DSC schema credentials
DB_DSC_USER="DSC"
DB_DSC_PASSWORD="[CONTAINER_PW]"

# define DSC connection string
DSC_CREDENTIALS="$DB_DSC_USER/$DB_DSC_PASSWORD@$DB_HOST:$DB_PORT/$DB_SID"

# define a query to check if APEX is installed, this is unnecessary if there is no APEX workspace or application deployed or developed
# APEX_QUERY="SELECT COUNT(*) FROM DBA_REGISTRY WHERE COMP_ID = 'APEX' AND STATUS = 'VALID';"

echo "The value of APEX_QUERY is: $APEX_QUERY"

# echo "$DSC_CREDENTIALS"

# Function to check if the database is initialized
check_database_initialized() {
    # Check if a specific user exists in the database ($DB_DSC_USER) (i.e., initialized)
    echo "SELECT COUNT(*) FROM DBA_USERS WHERE USERNAME = '$DB_DSC_USER';" | sqlplus -s $SYS_CREDENTIALS | grep -q '1'
}

# Wait until the database is available
echo "Waiting for Oracle Database to be ready..."

# Loop until a DB connection is successful
until echo "exit" | sqlplus -s $SYS_CREDENTIALS > /dev/null; do
    echo "Database not ready, waiting 5 seconds..."
    sleep 5
done

# Comment out this code when there is no APEX application that is being deployed or APEX workspaces are installed

# Loop until APEX is installed on the DB:
# echo "Waiting for APEX to be installed..."

# Loop until the APEX installation is completed
# until echo "$APEX_QUERY" | sqlplus -S $SYS_CREDENTIALS <<EOF | grep -P -o '^\s*(1)\s*$'
# SET HEADING OFF
# $APEX_QUERY
# EXIT;
# EOF
# do
#    echo "APEX not installed or not ready, waiting 5 seconds..."
#    sleep 5
# done
# echo "APEX is installed and ready!"


echo "Database is ready! Checking if the database has been initialized (based on schema existence)..."


# Check if the database is initialized by querying DBA_USERS
if ! check_database_initialized; then
    echo "Database is not initialized. Running the SQL scripts..."

	# run each of the sqlplus scripts to deploy the schemas, objects for each schema, applications, etc.


	echo "Create the DSC schemas"

	# change the directory so the script can run without alterations
	cd /usr/src/DSC/SQL

	# create the DSC schema(s)
sqlplus -s /nolog <<EOF
@dev_container_setup/create_docker_schemas.sql
$SYS_CREDENTIALS
EOF


	echo "Create the DSC objects"

	# change the directory to the DSC SQL folder to allow the scripts to run unaltered:
sqlplus -s /nolog <<EOF
@automated_deployments/deploy_dev_container.sql
$DSC_CREDENTIALS
EOF

	echo "the DSC objects were created"


    echo "SQL scripts executed successfully!"
else
    echo "Database already initialized. Skipping deployment script."
fi
