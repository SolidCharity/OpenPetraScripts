#!/bin/bash

if [ ! -d /root/.openpetra ]
then
  echo "this script is to be run inside the docker container"
  exit -1;
fi

if [ ! -d /root/openpetra/csharp ]
then
  cp -R /root/.openpetra/. /root/openpetra/
fi

if [ ! -d /home/openpetra ]
then
  export OPENPETRA_DBPWD="Dev1234"
  openpetra-server init && openpetra-server initdb
fi

cd /root/openpetra
nant install
