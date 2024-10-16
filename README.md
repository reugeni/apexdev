# apexdev

Oracle APEX/ORDS Development

### TODO

* Create folder apex and oradata in current directory
* Start docker stack
  ```
  docker compose up -d
  ```
* install APEX 
  ```
  docker exec -it {project}-db-1 bash
  ./01_apex_install.sh
  ```
* install ORDS
  ```
  docker exec -it {project}-app-1 bash
  /tmp/02_ords_install.sh
  ```
* restart Tomcat
  ```
  docker restart -t 30 {project}-app-1
  ```

### Other reference
```
 docker create -it --name 23cfree -p 8521:1521 -p 8500:5500 -p 8023:8080 -p 9043:8443 -p 9922:22 -e ORACLE_PWD=E container-registry.oracle.com/database/free:latest
 curl -o unattended_apex_install_23c.sh https://raw.githubusercontent.com/Pretius/pretius-23cfree-unattended-apex-installer/main/src/unattended_apex_install_23c.sh
 curl -o 00_start_apex_ords_installer.sh https://raw.githubusercontent.com/Pretius/pretius-23cfree-unattended-apex-installer/main/src/00_start_apex_ords_installer.sh
 docker cp unattended_apex_install_23c.sh 23cfree:/home/oracle
 docker cp 00_start_apex_ords_installer.sh 23cfree:/opt/oracle/scripts/startup
 docker start 23cfree
```



