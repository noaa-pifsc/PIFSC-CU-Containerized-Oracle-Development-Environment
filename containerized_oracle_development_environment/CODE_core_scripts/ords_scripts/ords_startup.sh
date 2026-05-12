#!/bin/bash

# ords_startup.sh runs as the entrypoint to the CODE-ords.yml configuration file

# Define resource paths
CONFIG_DIR="/etc/ords/config"
PW_FILE="/run/secrets/oracle_pwd"

# validate the database admin password secret exists
if [ ! -f "${PW_FILE}" ]; then
	echo "Error: Secret oracle_pwd was not found."
	exit 1
fi

# wait for the code-db-ords-deploy Apex installation/upgrade process to finish
echo "Waiting for database deployment to finish:"
while [ ! -f /opt/oracle/ords/static/deployments/.deploy_ready_${DEPLOY_ID} ]; do
  sleep 5
  echo "Still waiting for database deployment to finish..."
done
echo "Apex installation/upgrade completed"
export ORACLE_PWD=$(cat /run/secrets/oracle_pwd)
export ORDS_PWD=$(cat /run/secrets/oracle_pwd)
export ORACLE_USR_PWD=$(cat /run/secrets/oracle_pwd)

# create the default database pool configuration folder
mkdir -p "${CONFIG_DIR}/databases/default"

# generate the pool.xml configuration file with the database settings from the environment configuration variables
echo "generate the pool.xml configuration file"
cat <<EOF > "${CONFIG_DIR}/databases/default/pool.xml"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<comment>Generated dynamically for ORDS container based on database configuration values</comment>
<entry key="db.connectionType">basic</entry>
<entry key="db.hostname">${DBHOST}</entry>
<entry key="db.port">${DBPORT}</entry>
<entry key="db.servicename">${DBSERVICENAME}</entry>
<entry key="db.username">ORDS_PUBLIC_USER</entry>
<entry key="feature.sdw">true</entry>
<entry key="plsql.gateway.mode">proxied</entry>
<entry key="restEnabledSql.active">true</entry>
<entry key="security.requestValidationFunction">ords_util.authorize_plsql_gateway</entry>
</properties>
EOF

# create the directory for the global ORDS configuration
mkdir -p "${CONFIG_DIR}/global"

# generate the global settings.xml configuration file
echo "generate the global settings.xml configuration file"
cat <<EOF > "${CONFIG_DIR}/global/settings.xml"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<comment>Generated dynamically for ORDS container based on database configuration values</comment>
<entry key="database.api.enabled">true</entry>
<entry key="mongo.enabled">true</entry>
<entry key="standalone.access.log">/tmp/ords_access_logs/</entry>
<entry key="standalone.static.context.path">/i</entry>
<entry key="standalone.static.path">/opt/oracle/ords/static</entry>
</properties>      
EOF

# define the db.password securely with the secret value
echo "define the db password securely with the specified secret value"
ords --config "${CONFIG_DIR}" config secret --password-stdin db.password < "${PW_FILE}"

echo "Starting official ORDS entrypoint"
docker-entrypoint.sh