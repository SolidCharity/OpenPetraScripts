#!/bin/bash
# Author: Timotheus Pokorra <tp@tbits.net>
# Copyright: 2018 TBits.net
# Description: restart one or all openpetra services

if [ -z "$1" ]
then
  echo "call: . $0 all"
  echo "call: . $0 <customer>"
  exit -1
fi

customer=$1

function restart {
  customer=$1

  if [ -f /usr/lib/systemd/system/$customer.service ]
  then
    echo "restarting $customer"
    systemctl restart $1
  fi
}

if [[ "$1" == "all" ]]
then
  for d in /home/openpetra /home/op_*
  do
    if [ -d $d ]
    then
      restart `basename $d`
    fi
  done
else
  restart $1
fi
