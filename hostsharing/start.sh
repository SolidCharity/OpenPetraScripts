#!/bin/bash

# Author: timotheus.pokorra@solidcharity.com
# Copyright: 2019 SolidCharity.com
# Description: start the OpenPetra Mono server. Can call this in a cronjob in a hosting environment
userName=openpetra
OpenPetraPath=/home/$userName/app
documentroot=/home/$userName/app
OPENPETRA_PORT=9000

echo "Starting OpenPetra server"
if [ "`whoami`" = "$userName" ]
then
  cd $documentroot
  LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OpenPetraPath/bin fastcgi-mono-server4 /socket=tcp:127.0.0.1:$OPENPETRA_PORT /applications=/:$documentroot /appconfigfile=/home/$userName/etc/OpenPetra.global.config /logfile=/home/$userName/log/mono.log /loglevels=Standard > /dev/null 2>&1 &
  # other options for loglevels: Debug Notice Warning Error Standard(=Notice Warning Error) All(=Debug Standard)
  # improve speed of initial request by user by forcing to load all assemblies now
  #sleep 1
  #curl --retry 5 --silent http://localhost/api/serverSessionManager.asmx/IsUserLoggedIn > /dev/null
else
  echo "Error: can only start the server as user $userName"
  echo "su $userName start.sh"
  exit -1
fi
