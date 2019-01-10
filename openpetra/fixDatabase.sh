#!/bin/bash
# Author: Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
# Copyright: 2018 Solidcharity.com
# Description: fix something in the database for all instances

if [ -z "$1" ]
then
  echo "call: . $0 all"
  echo "call: . $0 <customer>"
  exit -1
fi

if [ -z "$MYSQL_CMD" ]
then
  echo "you need to export first: MYSQL_CMD"
  exit -1
fi

customer=$1

function run_mysql {
  customer=$1

  if [ -f /usr/lib/systemd/system/$customer.service ]
  then
    if [[ "`systemctl is-enabled $customer`" == "enabled" ]]
    then
      export OP_CUSTOMER=$customer
      /usr/bin/openpetra-server mysql
    fi
  fi
}

if [[ "$customer" == "all" ]]
then
  for d in /home/openpetra /home/op_*
  do
    if [ -d $d ]
    then
      service=`basename $d`
      run_mysql $service
    fi
  done
else
  run_mysql $customer
fi

echo
echo "Please remember to reset the MYSQL_CMD environment variable! export MYSQL_CMD="
