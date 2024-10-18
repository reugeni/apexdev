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
  docker compose exec -it dbora bash
  ./01_apex_install.sh
  ```
* install ORDS
  ```
  docker compose exec -it tomcat bash
  /tmp/02_ords_install.sh
  ```
* install JRI (JasperReportsIntegration)
  ```
  docker compose cp 03_jri_install.sh tomcat:/tmp/
  docker compose exec -it tomcat bash
  /tmp/03_jri_install.sh
  ```
* restart Tomcat
  ```
  docker compose restart -t 30 tomcat
  ```
### Invoke JasperReportsIntegration from APEX

![immagine](https://github.com/user-attachments/assets/9165035d-7a43-4d0f-b5ed-b6fd5341e16e)

```
declare
 l_body       clob; 
 l_body_html  clob; 
 l_email varchar2(60);
 l_proc varchar2(100) := 'show report';
 l_additional_parameters varchar2(32767);
 l_blob blob;
 l_mime_type varchar2(30):='application/pdf';
 l_mensaje_id number;
begin
 l_body:= 'Reciba un cordial saludo. Enviamos la siguiente orden de pedido.<br>Cordiales';
 BEGIN

   xlib_jasperreports.set_report_url('http://tomcat:8080/jri/report');
   -- construct addional parameter list
   --l_additional_parameters := 'P_PRESUPUESTO_ID=' || apex_util.url_encode(:P34_PRESUPUESTO);
 
   xlib_jasperreports.get_report (p_rep_name => 'test',
     p_rep_format => 'pdf',
     p_data_source => 'default',
     p_rep_locale => 'en_US',
     p_rep_encoding => 'UTF-8',
     p_additional_params => l_additional_parameters,
     p_out_blob => l_blob,
     p_out_mime_type => l_mime_type
   );
   --apex_application.stop_apex_engine;
 END;
 /*
 l_mensaje_id:=apex_mail.send(
       p_to        => 'example@example.com',
       p_from      => 'example@example.com',
       p_body      => l_body,
       p_body_html => NULL,
       p_subj      => 'Report');
 APEX_MAIL.ADD_ATTACHMENT(
       p_mail_id    => l_mensaje_id,
       p_attachment => l_blob,
       p_filename   => 'Report_Nro_'||:P34_PRESUPUESTO||'.pdf   ',
       p_mime_type  => l_mime_type);
 commit;
 */

   ------------------------------------------------------------------------
   -- set mime header
   ------------------------------------------------------------------------
   htp.flush;
   htp.init;
   OWA_UTIL.mime_header (ccontent_type      => l_mime_type,
                         bclose_header      => FALSE);
   ------------------------------------------------------------------------
   -- set content length
   ------------------------------------------------------------------------
   HTP.p ('Content-length: ' || DBMS_LOB.getlength (l_blob));
   OWA_UTIL.http_header_close;
   ------------------------------------------------------------------------
   -- download the file and display in browser
   ------------------------------------------------------------------------
   WPG_DOCLOAD.download_file (l_blob);
   ------------------------------------------------------------------------
   -- release resources
   ------------------------------------------------------------------------
   DBMS_LOB.freetemporary (l_blob);
   ------------------------------------------------------------------------
   -- stop rendering of APEX page
   ------------------------------------------------------------------------
  -- this was used before apex 4.1
  --apex_application.g_unrecoverable_error := true;
  apex_application.stop_apex_engine;

 l_body_html:=null;
  
 dbms_lob.freetemporary (l_blob);
 
end;
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



