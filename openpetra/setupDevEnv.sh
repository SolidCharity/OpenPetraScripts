#!/bin/bash
# Author: Timotheus Pokorra <tp@tbits.net>
# Copyright: 2017-2018 TBits.net
# Description: setup a development environment
#        this assumes that reinstall.sh has been run

yum -y install nant mono-devel

cd ~

git clone --depth 10 http://github.com/tbits/openpetra.git -b test

git clone https://github.com/openpetra/openpetra-client-js.git

cd openpetra

# get the database password from 
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

echo "now run in ~/openpetra: nant generateSolution install"

