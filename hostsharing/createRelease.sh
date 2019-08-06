#!/bin/bash

# Author: timotheus.pokorra@solidcharity.com
# Copyright: 2019 SolidCharity.com
# Description: create a compiled tarball ready to be installed in Hostsharing environment

if [ ! -d openpetra ]
then
  cd ~
  git clone https://github.com/openpetra/openpetra.git -b prod

  yum install -y wget curl

  curl --silent --location https://rpm.nodesource.com/setup_8.x  | bash -
  yum -y install nodejs
  #node --version
  #8.9.4
  #npm --version
  #5.6.0
  npm install -g browserify
  npm install -g uglify-es

  cd ~/openpetra/js-client
  # we don't need cypress for the release
  npm uninstall cypress
  npm install
fi

cd ~/openpetra

git pull
version=`cat db/version.txt | awk -F- '{print $1}'`
release=0
while [ -f ~/release_$version.$release ]
do
  release=$((release+1))
done
touch ~/release_$version.$release

# branding of packages
sed -i 's~<title>OpenPetra</title>~<title>OpenPetra by SolidCharity</title>~g' js-client/index.html

# make sure the user gets the latest javascript and html specific to this build
sed -i 's~CURRENTRELEASE~$version}.$release~g' js-client/src/lib/navigation.js
sed -i 's~CURRENTRELEASE~$version}.$release~g' js-client/src/lib/i18n.js
sed -i 's~CURRENTRELEASE~$version}.$release~g' js-client/index.html
sed -i "s/develop = 1;/develop = 0;/g" js-client/src/lib/navigation.js
sed -i "s/debug = 1;/debug = 0;/g" js-client/src/lib/navigation.js
sed -i "s/develop = 1;/develop = 0;/g" js-client/src/lib/i18n.js
sed -i "s/develop = 1;/develop = 0;/g" js-client/index.html

nant buildTAR -D:ReleaseID=$version.$release \
  -D:LinuxTargetDistribution-list=debian-mysql \
  -D:DBMS.Type=mysql

