#!/bin/bash
# Author: Timotheus Pokorra <tp@tbits.net>
# Copyright: 2017-2018 TBits.net
# Description: add a new OpenPetra instance, creating/overwriting the database

if [ -z "$1" ]
then
  echo "call: URL=<domain> $0 <customer> localhost"
  echo "call: URL=<domain> $0 <customer> <dbhost> <dbname> <dbuser> <dbpwd>"
  exit -1
fi

if [ -z "$URL" ]
then
  echo "Please specify the domain that will be hosting your OpenPetra instances"
  exit -1
fi

function FindFreePort()
{
  # this functions searches the /etc/services file until it finds a free port for a new database
  startid=$1
  testid=$[$startid]
  exists="yes"
  while [[ ! "$exists" = "" ]]; do
    testid=$[$testid+1]
    exists=`getent services $testid/tcp`
  done;
  export id=$testid
}

export customer=$1
export OP_CUSTOMER=op_$customer
export userName=op_$customer
export OPENPETRA_URL=$customer.$URL
export OPENPETRA_HTTP_URL=https://$customer.$URL
export OPENPETRA_DBHOST=$2
if [[ "$OPENPETRA_DBHOST" == "localhost" ]]
then
  export OPENPETRA_DBNAME=op_$customer
  export OPENPETRA_DBUSER=op_$customer
  export OPENPETRA_DBPWD=`openpetra-server generatepwd`
else
  export OPENPETRA_DBNAME=$3
  export OPENPETRA_DBUSER=$4
  export OPENPETRA_DBPWD=$5
fi
FindFreePort 9000
export OPENPETRA_PORT=$id
export OPENPETRA_HTTP_PORT=$((OPENPETRA_PORT-1000))
# add service
echo -e "op_$customer\t$OPENPETRA_PORT/tcp\t\t\t# OpenPetra for $customer" >> /etc/services

openpetra-server init || exit -1
openpetra-server initdb || exit -1
