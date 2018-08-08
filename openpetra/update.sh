#!/bin/bash
# Author: Timotheus Pokorra <tp@tbits.net>
# Copyright: 2018 TBits.net
# Description: disable automatic updates, and run the update
sed -i "s/^enabled=.*/enabled=0/g" /etc/yum.repos.d/lbs-tbits.net-openpetra.repo
yum --enablerepo=lbs-tbits.net-openpetra update
