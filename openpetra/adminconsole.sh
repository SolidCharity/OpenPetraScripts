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
export OP_CUSTOMER=$customer
path=/home/$OP_CUSTOMER/etc
if [ ! -d $path ]
then
  export OP_CUSTOMER=op_$customer
fi

openpetra-server menu
