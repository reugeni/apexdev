#!/bin/bash

# Start the timer
start_time=$(date +%s)

# Make JRI Folders
mkdir -p /opt/jri
cd /opt/jri

# Get JRI
curl -sSL https://github.com/daust/JasperReportsIntegration/releases/download/v2.11.0/jri-2.11.0-jasper-6.20.6.tar | tar xvf -
mv jri-2.11.0-jasper-6.20.6/* .
rmdir jri-2.11.0-jasper-6.20.6

# Install JRI
export OC_JASPER_CONFIG_HOME=/opt/jri
./setConfigDir.sh ../webapp/jri.war /opt/jri
sed -i "s/username=my_oracle_user/username=${ORACLE_USER:-username}/;s/password=my_oracle_user_pwd/password=${ORACLE_USER_PWD:-password}/;s/url=jdbc:oracle:thin:@127.0.0.1:1521:XE/url=jdbc:oracle:thin:@dbora:1521:FREEPDB1/' conf/application.properties
# TIPS: fix reportsPath (default ../reports) with custom folder(s)
# reportsPath=../reports,/path/to/reports1,/path/to/reports2,/path/to/reports3

# Deploy JRI into Tomcat Webapps
# TIPS: edit or create $TOMCAT_HOME/bin/setenv.sh
# # #!/bin/sh
# export JAVA_OPTS="${JAVA_OPTS} -Djava.awt.headless=true -server -Xms2048m -Xms2048m -XX:MaxPermSize=192m"
cp -r /opt/jri/webapp/jri.war /usr/local/tomcat/webapps/

# Calculate the elapsed time
end_time=$(date +%s)
elapsed_time=$((end_time - start_time))

# Convert elapsed time to human-readble format
hours=$((elapsed_time / 3600))
minutes=$(((elapsed_time % 3600) / 60))
seconds=$((elapsed_time % 60))

# Print the elapsed time
echo "Elapsed time: ${hours}h ${minutes}m ${seconds}s"

echo "### JRI INSTALLED ###"
