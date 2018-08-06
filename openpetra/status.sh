#!/bin/bash
# Author: Timotheus Pokorra <tp@tbits.net>
# Copyright: 2018 TBits.net
# Description: show status of all openpetra services

if [ -z "$1" ]
then
  echo "call: . $0 all"
  echo "call: . $0 <customer>"
  exit -1
fi

customer=$1

function status {
  customer=$1

  if [ -f /usr/lib/systemd/system/$customer.service ]
  then
    echo "status of $customer"
    #systemctl status $1
    export OP_CUSTOMER=$customer
    /usr/bin/openpetra-server status
  fi
}

if [[ "$1" == "all" ]]
then
  for d in /home/openpetra /home/op_*
  do
    if [ -d $d ]
    then
      status `basename $d`
    fi
  done
else
  status $1
fi
