#!/bin/bash
# Author: Timotheus Pokorra <tp@tbits.net>
# Copyright: 2017 TBits.net
# Description: run the admin console against the specified server

if [ -z "$1" ]
then
  echo "call: $0 <customer>"
  exit -1
fi

customer=$1
path=/home/op-$customer/etc
if [ ! -d $path ]
then
  path=/home/$customer/etc
  customer=op_$customer
fi

NAME="$customer" userName="$customer" openpetra-server menu
