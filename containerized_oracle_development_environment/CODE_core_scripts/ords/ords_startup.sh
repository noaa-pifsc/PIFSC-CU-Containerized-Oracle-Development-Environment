#!/bin/bash

# Define resource paths
CONFIG_DIR="/etc/ords/config"
PW_FILE="/run/secrets/oracle_pwd"

# validate the database admin password secret exists
if [ ! -f "${PW_FILE}" ]; then
    echo "Error: Secret oracle_pwd was not found."
    exit 1
fi

# wait for the .deploy_ready_${DEPLOY_ID} file before configuring and starting the ORDS container
echo "Waiting for database deployment to finish..."
while [ ! -f "/opt/oracle/ords/static/.deploy_ready_${DEPLOY_ID}" ]; do 
  sleep 5
  echo "Still waiting for database deployment to finish..."
done
echo "The apex installation/upgrade has completed, configure the ORDS container"

# create the default database pool configuration folder
mkdir -p "${CONFIG_DIR}/databases/default"

# generate the global settings.xml configuration file
echo "generate the global settings.xml configuration file"
cat > "${CONFIG_DIR}/databases/default/pool.xml" <<EOF
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

# define the db.password securely with the secret value
echo "define the db password"
ords --config "${CONFIG_DIR}" config secret --password-stdin db.password < "${PW_FILE}"

# launch the official ords entrypoint script and specify the configuration directory
echo "Use the official docker-entrypoint.sh to start the ords container"
exec docker-entrypoint.sh --config "${CONFIG_DIR}" serve