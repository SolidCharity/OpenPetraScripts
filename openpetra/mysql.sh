#!/bin/bash
# Author: Timotheus Pokorra <tp@tbits.net>
# Copyright: 2017 TBits.net
# Description: export the database connection settings for an OpenPetra instance

customer=$1

if [ -z "$customer" ]
then
  echo "call: . $0 <customer>"
  echo " defaulting to customer openpetra"
  customer="openpetra"
fi

export OP_CUSTOMER=$customer

/usr/bin/openpetra-server mysql
