#!/bin/bash
# Author: Timotheus Pokorra <tp@tbits.net>
# Copyright: 2017 TBits.net

if [ -z "$URL" ]
then
  export URL=demo.openpetra.org
fi

echo "this script will remove OpenPetra, and DELETE all YOUR data!!!"
read -p "Are you sure? Type y or Ctrl-C " -r
echo 
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

shopt -s nullglob
for f in /usr/lib/systemd/system/op_*
do
echo "stopping $f"
  systemctl stop `basename $f`
  systemctl disable `basename $f`
done
systemctl stop openpetra-server
systemctl stop lighttpd
systemctl stop mariadb

yum -y remove mariadb lighttpd openpetranow-mysql-test

# remove the users
if [ -d /home/openpetra ]
then
  userdel -r openpetra
fi
for d in /home/op_*
do
  userdel -r `basename $d`
done

rm -Rf /etc/lighttpd
rm -Rf /var/lib/mysql
rm -Rf /usr/lib/systemd/system/op_*

# drop OpenPetra services from /etc/services
cat /etc/services | grep -v "# OpenPetra for" > /etc/services.new
mv /etc/services.new /etc/services

# enable the repo
cd /etc/yum.repos.d
repourl=https://lbs.solidcharity.com/repos/tbits.net/openpetra/centos/7/lbs-tbits.net-openpetra.repo
if [ ! -f `basename $repourl` ]
then
  curl -L $repourl -o `basename $repourl`
fi
cd -

yum clean all
yum -y install openpetranow-mysql-test

openpetra-server init
openpetra-server initdb
