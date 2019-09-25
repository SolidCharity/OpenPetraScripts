#!/bin/bash
# Author: Timotheus Pokorra <tp@tbits.net>
# Copyright: 2018 TBits.net
# Description: disable automatic updates, and run the update
# if a customer or all is specified, the database updates are run.

repofile=/etc/yum.repos.d/lbs-solidcharity-openpetra.repo
sed -i "s/^enabled =.*/enabled = 0/g" $repofile
sed -i "s/^enabled=.*/enabled = 0/g" $repofile
# if line does not exist:
if ! grep -q '^enabled' $repofile
then
  sed -i 's#gpgcheck#enabled = 0\ngpgcheck#g' $repofile
fi
yum --enablerepo=lbs-solidcharity-openpetra update

customer=$1


function upgrade {
  customer=$1
  echo "updating $customer"
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
