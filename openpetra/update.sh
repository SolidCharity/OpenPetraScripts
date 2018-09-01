#!/bin/bash
# Author: Timotheus Pokorra <tp@tbits.net>
# Copyright: 2018 TBits.net
# Description: disable automatic updates, and run the update
# if a customer or all is specified, the database updates are run.

sed -i "s/^enabled=.*/enabled=0/g" /etc/yum.repos.d/lbs-tbits.net-openpetra.repo
yum --enablerepo=lbs-tbits.net-openpetra update

customer=$1


function upgrade {
  customer=$1
  export OP_CUSTOMER=$customer
  /usr/bin/openpetra-server upgradedb
}

if [ ! -z "$customer" ]
then
  if [[ "$customer" == "all" ]]
  then
    for d in /home/openpetra /home/op_*
    do
      if [ -d $d ]
      then
        upgrade `basename $d`
      fi
    done
  else
    upgrade $customer
  fi
fi
