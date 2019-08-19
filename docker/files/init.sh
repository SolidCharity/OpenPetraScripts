#!/bin/bash

if [ ! -d /root/.openpetra ]
then
  echo "this script is to be run inside the docker container"
  exit -1;
fi

if [ ! -d /root/openpetra/csharp ]
then
  # copy the working directory to the mounted directory so that it is outside of the container
  cp -R /root/.openpetra/. /root/openpetra/
  chmod a+wr -R /root/openpetra
fi

alias cp=cp
cp -f /root/openpetra/setup/petra0300/linuxserver/mysql/centos/openpetra-server.service /usr/lib/systemd/system/openpetra.service
cp -f /root/openpetra/setup/petra0300/linuxserver/mysql/centos/openpetra-server.sh /usr/bin/openpetra-server && chmod a+x /usr/bin/openpetra-server

rm -Rf /usr/local/openpetra/client && ln -s /root/openpetra/js-client /usr/local/openpetra/client
rm -Rf /usr/local/openpetra/reports && ln -s /root/openpetra/XmlReports /usr/local/openpetra/reports
chmod a+rx /root

if [ ! -d /home/openpetra ]
then
  # make sure we get the right PetraServerConsole.config file in the right place
  cd /root/openpetra
  nant install -D:with-restart=false

  cd /usr/local/openpetra/server && ln -s . api && ln -s ../bin
  cd /usr/local/openpetra/bin && ln -s /usr/lib64/libgdiplus.so
  cd /usr/local/openpetra/bin && ln -s /usr/lib64/libsodium.so.23 libsodium.so

  # install the database and openpetra instance
  export OPENPETRA_DBPWD="ThisIsJustForDevelopment1234"
  /usr/bin/openpetra-server init && /usr/bin/openpetra-server initdb
  cp /root/*.yml.gz /home/openpetra
  chown openpetra:openpetra /home/openpetra/*.yml.gz
  /usr/bin/openpetra-server loadYmlGz /home/openpetra/demoWith1ledger.yml.gz
  systemctl restart openpetra
else
  cd /root/openpetra
  nant install
fi
