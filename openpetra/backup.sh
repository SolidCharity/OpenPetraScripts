#!/bin/bash
# Author: Timotheus Pokorra <tp@tbits.net>
# Copyright: 2017 TBits.net
# Description: backup all or one databases

if [ -z "$1" ]
then
  echo "call: . $0 all"
  echo "call: . $0 <customer>"
  exit -1
fi

customer=$1

function backupdb {
  customer=$1
  path=/home/op-$customer/backup
  if [ ! -d $path ]
  then
    path=/home/$customer/backup
  fi
  export OP_CUSTOMER=$customer
  /usr/bin/openpetra-server backup $path/mysql-`date +%Y%m%d%H`.sql.gz
  echo "backup stored to" $path/mysql-`date +%Y%m%d%H`.sql.gz
  rm -f $path/mysql-`date --date='5 days ago' +%Y%m%d`*.sql.gz
  rm -f $path/mysql-`date --date='6 days ago' +%Y%m%d`*.sql.gz
  rm -f $path/mysql-`date --date='7 days ago' +%Y%m%d`*.sql.gz
}

if [[ "$1" == "all" ]]
then
  for d in /home/openpetra /home/op_*
  do
    if [ -d $d ]
    then
      backupdb `basename $d`
    fi
  done
else
  backupdb $1
fi
