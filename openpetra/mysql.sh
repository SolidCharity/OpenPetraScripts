#!/bin/bash
# Author: Timotheus Pokorra <tp@tbits.net>
# Copyright: 2017 TBits.net
# Description: export the database connection settings for an OpenPetra instance

if [ -z "$1" ]
then
  echo "call: . $0 <customer>"
  exit -1
fi

customer=$1
path=/home/op-$customer/etc
if [ ! -d $path ]
then
  path=/home/$customer/etc
fi

export DBHost=`cat $path/PetraServerConsole.config | grep DBHostOrFile | awk -F'"' '{print $4}'`
export DBUser=`cat $path/PetraServerConsole.config | grep DBUserName | awk -F'"' '{print $4}'`
export DBName=`cat $path/PetraServerConsole.config | grep DBName | awk -F'"' '{print $4}'`
export DBPort=`cat $path/PetraServerConsole.config | grep DBPort | awk -F'"' '{print $4}'`
export DBPwd=`cat $path/PetraServerConsole.config | grep DBPassword | awk -F'"' '{print $4}'`
echo 'call: mysql -u $DBUser -h $DBHost --port=$DBPort --password="$DBPwd" $DBName'
