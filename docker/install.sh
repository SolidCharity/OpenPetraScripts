#!/bin/bash

if [ -z "$2" ]
then
  echo "please specify either fedora or ubuntu, and your local working directory"
  echo "  e.g. $0 fedora $HOME/dev/openpetra"
  exit -1
fi
typeOfOS=$1
localworkdir=$2

organisation=solidcharity
image=$organisation/openpetra-dev.$typeOfOS
name=openpetra-dev.$typeOfOS
sshport=2008
httpport=8008

mountWorkingDirectory="-v $localworkdir:/root/openpetra"
mountcgroup="-v /sys/fs/cgroup:/sys/fs/cgroup:ro"
mount="$mountWorkingDirectory $mountcgroup"

tmp="-d --tmpfs /tmp --tmpfs /run"
sudo docker run --name $name $tmp $mount -p $sshport:22 -p $httpport:80 -h $name -d -t -i $image || exit -1
ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[localhost]:$sshport"
echo
echo
echo "Login with initial password for root: CHANGEME"
echo "first step: ./init.sh"
echo
echo
sleep 5
ssh -p $sshport root@localhost
