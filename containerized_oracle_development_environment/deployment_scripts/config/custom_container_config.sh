#!/bin/sh

# define any database/apex credentials necessary to deploy the database schemas and/or applications



# declare an associative array with the secret name as the array element and the bash variable name as the array value
declare -A SECRET_MAPPING_ARR=(
	["sys_password"]="ORACLE_PWD"
)
