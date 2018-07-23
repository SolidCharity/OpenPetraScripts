#!/bin/bash
# Author: Timotheus Pokorra <tp@tbits.net>
# Copyright: 2017-2018 TBits.net
# Description: create the server for demo.openpetra.org

# setup the instance
export URL=openpetra.org
./addOpenPetraInstance.sh demo localhost

# download the demo database
cd /home/op_demo
wget https://github.com/openpetra/demo-databases/raw/master/demoWith1ledger.yml.gz
chown op_demo:op_demo demoWith1ledger.yml.gz
cd -

# restore the demo database
./restoreDemoDatabase.sh

# install cronjob
crontab -l || echo | crontab - >> /dev/null 2>&1
if [[ "`crontab -l | grep openpetra/restoreDemoDatabase.sh`" == "" ]]
then
  pwd=`pwd`
  (crontab -l && echo "45 1 * * * $pwd/restoreDemoDatabase.sh" ) | crontab -
  systemctl enable crond
  systemctl start crond
fi

