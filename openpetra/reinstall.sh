#!/bin/bash
# Author: Timotheus Pokorra <tp@tbits.net>
# Copyright: 2017-2018 TBits.net
# Description: reinstall the whole server, losing all data

echo "this script will remove OpenPetra, and DELETE all YOUR data!!!"
read -p "Are you sure? Type y or Ctrl-C " -r
echo 
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

shopt -s nullglob
systemctl stop openpetra
systemctl stop nginx
systemctl stop mariadb

yum -y remove mariadb nginx openpetranow-mysql-test

# remove the users
if [ -d /home/openpetra ]
then
  userdel -r openpetra || exit -1
fi
for d in /home/op_*
do
  userdel -r `basename $d` || exit -1
done

rm -Rf /etc/nginx
rm -Rf /var/lib/mysql

# drop OpenPetra services from /etc/services
cat /etc/services | grep -v "# OpenPetra for" > /etc/services.new
mv /etc/services.new /etc/services

# enable the repo
cd /etc/yum.repos.d
repourl=https://lbs.solidcharity.com/repos/solidcharity/openpetra/centos/7/lbs-solidcharity-openpetra.repo
repofile=`basename $repourl`
if [ ! -f $repofile ]
then
  curl -L $repourl -o $repofile
fi
sed -i "s/^enabled.*/enabled = 1/g" $repofile
cd -

yum clean all
yum -y install epel-release

# install Copr repository for Mono >= 5.10
su -c 'curl https://copr.fedorainfracloud.org/coprs/tpokorra/mono-5.18/repo/epel-7/tpokorra-mono-5.18-epel-7.repo | tee /etc/yum.repos.d/tpokorra-mono5.repo'

yum -y install https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox-0.12.5-1.centos7.x86_64.rpm
yum -y install openpetranow-mysql-test || exit -1

if [ -f /tmp/openpetra-server ]
then
  echo "testing: use /tmp/openpetra-server"
  cp /tmp/openpetra-server /usr/bin
fi

crontab -l || echo | crontab - >> /dev/null 2>&1
if [[ "`crontab -l | grep openpetra/backup.sh`" == "" ]]
then
  pwd=`pwd`
  (crontab -l && echo "45 0 * * * $pwd/backup.sh all" ) | crontab -
  systemctl enable crond
  systemctl start crond
fi

echo "now initialize your instance, for example:"
echo "to install the instance demo.openpetra.org, with the database on localhost, and the initial password for SYSADMIN:"
echo
echo "URL=openpetra.org PREFIX= ./addOpenPetraInstance.sh demo localhost"
