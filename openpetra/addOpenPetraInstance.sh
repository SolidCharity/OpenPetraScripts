#!/bin/bash
# Author: Timotheus Pokorra <tp@tbits.net>
# Copyright: 2017-2018 TBits.net
# Copyright: 2019 SolidCharity.com
# Description: add a new OpenPetra instance, creating/overwriting the database

export FIRST_HTTP_PORT=7000

if [ -z "$1" ]
then
  echo "call: URL=<domain> PREFIX=<prefix> SYSADMIN_PWD=<inital_passwd> [OPENPETRA_HTTP_PORT=<port>] $0 <customer> localhost"
  echo "call: URL=<domain> $0 <customer> <dbhost> <dbname> <dbuser> <dbpwd> <sysadminpwd>"
  echo " eg. URL=openpetra.org PREFIX= SYSADMIN_PWD=`openpetra-server generatepwd` ./addOpenPetraInstance.sh test localhost"
  echo " eg. URL=openpetra.org PREFIX=op SYSADMIN_PWD=Test1234_ ./addOpenPetraInstance.sh 012345 localhost"
  exit -1
fi

if [ -z "$URL" ]
then
  echo "Please specify the domain that will be hosting your OpenPetra instances"
  exit -1
fi

# lets keep it simple: it is CHANGEME by default
#if [ -z "$SYSADMIN_PWD" ]
#then
#  export SYSADMIN_PWD=`openpetra-server generatepwd`
#fi

function FindFreePort()
{
  # this functions searches the /etc/services file until it finds a free port for a new database 
  # that has not been used for an OpenPetra instance yet.
  # getent services 7102/tcp would find too many other service ports that are not in use.
  startid=$1
  testid=$[$startid]
  exists=`grep -E "$testid/tcp.*OpenPetra" /etc/services`
  while [[ ! "$exists" = "" ]]; do
    testid=$[$testid+1]
    exists=`grep -E "$testid/tcp.*OpenPetra" /etc/services`
  done;
  export id=$testid
}

export customer=$1
export OP_CUSTOMER=op_$customer
export userName=op_$customer
export OPENPETRA_URL=$PREFIX$customer.$URL
export OPENPETRA_EMAILDOMAIN=$URL
export OPENPETRA_HTTP_URL=https://$OPENPETRA_URL
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
  export SYSADMIN_PWD=$6
fi

if [ -z "$OPENPETRA_HTTP_PORT" ]
then
  FindFreePort $FIRST_HTTP_PORT
  export OPENPETRA_HTTP_PORT=$id
fi

# add service
echo -e "op_$customer\t$OPENPETRA_HTTP_PORT/tcp\t\t\t# OpenPetra for $customer" >> /etc/services

openpetra-server init || exit -1
openpetra-server initdb || exit -1

if [ ! -z "$AUTHTOKENINIT" ]
then
  cfgfile="/home/op_$customer/etc/PetraServerConsole.config"
  sed -i "s#    <add key=\"ApplicationDirectory\"#    <add key=\"AuthTokenForInitialisation\" value=\"$AUTHTOKENINIT\"/>\n    <add key=\"ApplicationDirectory\"#g" $cfgfile
fi

echo "make sure you have configured the tunnel for the web access: "
echo "./initWebproxy.sh 150 $OPENPETRA_URL dummy $OPENPETRA_HTTP_PORT"
