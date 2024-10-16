#!/bin/bash

# Start the timer
start_time=$(date +%s)

# Install OS Tools
apt update
apt install -y unzip vim

# Make ORDS Folders
mkdir -p /etc/ords/config
mkdir -p /etc/ords/logs
mkdir /opt/ords
cd /opt/ords

# Get ORDS
curl -o ords-latest.zip https://download.oracle.com/otn_software/java/ords/ords-latest.zip
unzip -q ords-latest.zip
rm ords-latest.zip

# Install ORDS
/opt/ords/bin/ords --config /opt/ords/config install \
     --log-folder /etc/ords/logs \
     --admin-user SYS \
     --db-hostname dbora \
     --db-port 1521 \
     --db-servicename FREEPDB1 \
     --feature-db-api true \
     --feature-rest-enabled-sql true \
     --feature-sdw true \
     --proxy-user \
     --password-stdin <<EOF
${ORACLE_PWD}
${APEX_PWD}
EOF

# Set default landing to APEX --  http://localhost:8080/ords/apex
# Altering ords/config/global/settings.xml:
# <entry key="misc.defaultPage">apex</entry>
sed -i '/<\/properties>/i<entry key="misc.defaultPage">apex</entry>' /opt/ords/config/global/settings.xml

# Deploy ORDS into Tomcat Webapps
mkdir /usr/local/tomcat/webapps/i
cp -r /opt/apex/images/* /usr/local/tomcat/webapps/i/
#cp -r /opt/apex/apex_patch/36695709/images/* /usr/local/tomcat/webapps/i/
cp /opt/ords/ords.war /usr/local/tomcat/webapps/
sed -i '/-Djava.protocol.handler/aJAVA_OPTS="\$JAVA_OPTS -Dconfig.url=/opt/ords/config -Xms1024M -Xmx1024M"' /usr/local/tomcat/bin/catalina.sh

# Calculate the elapsed time
end_time=$(date +%s)
elapsed_time=$((end_time - start_time))

# Convert elapsed time to human-readble format
hours=$((elapsed_time / 3600))
minutes=$(((elapsed_time % 3600) / 60))
seconds=$((elapsed_time % 60))

# Print the elapsed time
echo "Elapsed time: ${hours}h ${minutes}m ${seconds}s"

echo "### ORDS INSTALLED ###"
