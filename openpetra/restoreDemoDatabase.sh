#!/bin/bash
# Author: Timotheus Pokorra <tp@tbits.net>
# Copyright: 2017 TBits.net
# Description: restore the demo database

file=/home/op_demo/demoWith1ledger.yml.gz
if [ -f $file ]
then
  OP_CUSTOMER=op_demo /usr/bin/openpetra-server loadYmlGz $file || exit -1
  systemctl restart op_demo || exit -1
fi

