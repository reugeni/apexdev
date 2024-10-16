#!/bin/bash

# Start the timer
start_time=$(date +%s)

# Get APEX
curl -o apex-latest.zip https://download.oracle.com/otn_software/apex/apex-latest.zip

# Enter APEX Folder
unzip -q apex-latest.zip
rm apex-latest.zip
cd apex

# Install APEX
sqlplus / as sysdba <<EOF
ALTER SESSION SET CONTAINER = FREEPDB1;
@apxsilentins.sql SYSAUX SYSAUX TEMP /i/ ${APEX_PWD} ${APEX_PWD} ${APEX_PWD} ${APEX_ADMIN_PWD}
EXIT;
EOF

# Set Accounts
sqlplus / as sysdba <<EOF
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${APEX_PWD};
EXIT;
EOF

# Configure Oracle REST Data Services
sqlplus sys/${ORACLE_PWD}@FREEPDB1 as sysdba @apex_rest_config.sql <<EOF
${APEX_PWD}
${APEX_PWD}
EOF

# Calculate the elapsed time
end_time=$(date +%s)
elapsed_time=$((end_time - start_time))

# Convert elapsed time to human-readble format
hours=$((elapsed_time / 3600))
minutes=$(((elapsed_time % 3600) / 60))
seconds=$((elapsed_time % 60))

# Print the elapsed time
echo "Elapsed time: ${hours}h ${minutes}m ${seconds}s"

echo "### APEX INSTALLED ###"
