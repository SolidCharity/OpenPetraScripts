#!/bin/bash

# Author: timotheus.pokorra@solidcharity.com
# Copyright: 2019 SolidCharity.com
# Description: prepare a Debian host for OpenPetra mass hosting

installPackages=1
userName=openpetra
OpenPetraPath="/home/$userName/app"
OPENPETRA_HTTP_PORT=80
OPENPETRA_PORT=9000

OPENPETRA_URL=$1 
 
if [ -z "$OPENPETRA_URL" ] 
then 
   echo "call: . $0 <openpetra_url>"
   exit -1
fi

OPENPETRA_HTTP_URL="https://$OPENPETRA_URL"

if [ $installPackages -eq 1 ]
then
  apt-get update
  apt-get -y install mono-fastcgi-server4 nginx mariadb-server

  # configure nginx
  if [ $OPENPETRA_HTTP_PORT == 80 ]
  then
    # let the default nginx server run on another port
    sed -i "s/listen\(.*\)80/listen\181/g" /etc/nginx/nginx.conf
  fi

  if [ ! -d /home/$userName ]
  then
    useradd --home-dir /home/$userName --create-home $userName
  fi

  if [[ "`grep SCRIPT_FILENAME /etc/nginx/fastcgi_params`" == "" ]]
  then
    cat >> /etc/nginx/fastcgi_params <<FINISH
fastcgi_param  PATH_INFO          "";
fastcgi_param  SCRIPT_FILENAME    \$document_root\$fastcgi_script_name;
FINISH
  fi

  mkdir -p /etc/nginx/conf.d
  cat > /etc/nginx/conf.d/$userName.conf <<FINISH
server {
    listen $OPENPETRA_HTTP_PORT;
    server_name $OPENPETRA_URL;

    root $OpenPetraPath/client;

    location / {
         rewrite ^/Settings.*$ /;
         rewrite ^/Partner.*$ /;
         rewrite ^/Finance.*$ /;
         rewrite ^/CrossLedger.*$ /;
         rewrite ^/System.*$ /;
         rewrite ^/.git/.*$ / redirect;
         rewrite ^/etc/.*$ / redirect;
    }

    location /api {
         index index.html index.htm default.aspx Default.aspx;
         fastcgi_index Default.aspx;
         fastcgi_pass 127.0.0.1:$OPENPETRA_PORT;
         include /etc/nginx/fastcgi_params;
         sub_filter_types text/html text/css text/xml;
         sub_filter 'http://127.0.0.1:$OPENPETRA_PORT' '$OPENPETRA_HTTP_URL/api';
         sub_filter 'http://localhost/api' '$OPENPETRA_HTTP_URL/api';
    }
}
FINISH

  mkdir -p /home/$userName/etc
  cat > /home/$userName/etc/OpenPetra.global.config <<FINISH
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
  <system.web>
     <sessionState
       mode="InProc"
       timeout="30" /> <!-- timeout in minutes -->
     <customErrors mode="Off"/>
     <compilation tempDirectory="/home/$userName/tmp" debug="true" strict="false" explicit="true"/>
  </system.web>
</configuration>
FINISH

  systemctl restart nginx

fi




