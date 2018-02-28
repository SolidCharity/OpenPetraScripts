#!/bin/bash
# Author: Timotheus Pokorra <tp@tbits.net>
# Copyright: 2017-2018 TBits.net
# Description: setup a development environment
#        this assumes that reinstall.sh has been run

yum -y install nant mono-devel

curl --silent --location https://rpm.nodesource.com/setup_8.x  | bash -
yum -y install nodejs
#node --version
#8.9.4
#npm --version
#5.6.0
npm install -g browserify
npm install -g uglify-es

cd ~

if [ ! -d openpetra ]
then
  git clone --depth 10 http://github.com/tbits/openpetra.git -b test
fi

if [ ! -d openpetra-client-js ]
then
  git clone https://github.com/tbits/openpetra-client-js.git -b test
fi

cd openpetra

# get the database password from the default server installed by reinstall.sh
dbpwd=`cat /home/openpetra/etc/PetraServerConsole.config  | grep Server.DBPassword | awk -F\" '{print $4;}'`
cat > OpenPetra.build.config <<FINISH
<?xml version="1.0"?>
<project name="OpenPetra-userconfig">
    <!-- DB password from /home/openpetra/etc/PetraServerConsole.config -->
    <property name="DBMS.Type" value="mysql"/>
    <property name="DBMS.Password" value="$dbpwd"/>
    <property name="Server.DebugLevel" value="0"/>
</project>
FINISH

# add symbolic link from /usr/local/openpetra/client to /root/openpetra-client-js
rm -Rf /usr/local/openpetra/client
ln -s /root/openpetra-client-js /usr/local/openpetra/client
chmod a+rx /root

cd ~/openpetra-client-js
npm install

echo "now run in ~/openpetra: nant generateSolution install"

