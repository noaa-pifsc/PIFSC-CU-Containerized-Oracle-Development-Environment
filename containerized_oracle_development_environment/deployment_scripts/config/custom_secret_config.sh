#!/bin/sh

##### Container Secret Configuration Variables: #####

	# declare an associative array with the secret name as the array element and the bash variable name as the array value, the array element values should match the variable names in secrets.sh
	declare -A SECRET_MAPPING_ARR=(
		["oracle_pwd"]="ORACLE_PWD"
	)
