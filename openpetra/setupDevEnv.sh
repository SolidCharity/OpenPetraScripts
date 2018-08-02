#!/bin/bash
# Author: Timotheus Pokorra <tp@tbits.net>
# Copyright: 2017-2018 TBits.net
# Description: setup a development environment
#        this assumes that reinstall.sh has been run

yum -y install nant mono-devel wget

curl --silent --location https://rpm.nodesource.com/setup_8.x  | bash -
yum -y install nodejs
#node --version
#8.9.4
#npm --version
#5.6.0

# support for corporate http web proxy
if [ ! -z "$http_proxy" ]
then
  # this will write to ~/.npmrc
  npm config set proxy $http_proxy
fi
if [ ! -z "$https_proxy" ]
then
  # this will write to ~/.npmrc
  npm config set https-proxy $https_proxy
fi

npm install -g browserify
npm install -g uglify-es

cd ~

if [ ! -z $1 ];
then
  devuser=$1
  home=/home/$1
  groupadd developers
  usermod -G developers,wheel $devuser
  chmod -R g+rs /usr/local/openpetra/
  chown -R $devuser:developers /usr/local/openpetra/
else
  devuser=root
  home=/root
fi

if [ ! -d $home/openpetra ]
then
  git clone --depth 10 http://github.com/tbits/openpetra.git -b test $home/openpetra
fi

if [ ! -d $home/openpetra-client-js ]
then
  git clone https://github.com/tbits/openpetra-client-js.git -b test $home/openpetra-client-js
fi

cd $home/openpetra

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
ln -s $home/openpetra-client-js /usr/local/openpetra/client
chmod a+rx $home

cd $home/openpetra-client-js
npm install
cd $home/openpetra
nant install.js

chown -R $devuser:$devuser $home

# install phpMyAdmin with PHP7.1
yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum -y install yum-utils
yum-config-manager --enable remi-php71
yum-config-manager --enable remi
yum -y install phpMyAdmin php-fpm
sed -i "s#user = apache#user = nginx#" /etc/php-fpm.d/www.conf
sed -i "s#group = apache#group = nginx#" /etc/php-fpm.d/www.conf
sed -i "s#listen = 127.0.0.1:9000#listen = 127.0.0.1:8080#" /etc/php-fpm.d/www.conf
sed -i "s#;chdir = /var/www#chdir = /usr/share/phpMyAdmin#" /etc/php-fpm.d/www.conf
chown nginx:nginx /var/lib/php/session
systemctl enable php-fpm
systemctl start php-fpm
if [[ -z "`cat /etc/nginx/conf.d/openpetra.conf | grep phpMyAdmin`" ]];
then
  sed -i "s#location / {#location / {\n         rewrite ^/phpmyadmin.*$ /phpMyAdmin redirect;#g" /etc/nginx/conf.d/openpetra.conf
  sed -i "s#^}##g" /etc/nginx/conf.d/openpetra.conf
  cat >> /etc/nginx/conf.d/openpetra.conf <<FINISH
    location /phpMyAdmin {
         root /usr/share/;
         index index.php index.html index.htm;
         location ~ ^/phpMyAdmin/(.+\.php)$ {
                   root /usr/share/;
                   fastcgi_pass 127.0.0.1:8080;
                   fastcgi_index index.php;
                   include /etc/nginx/fastcgi_params;
                   fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        }
    }
}
FINISH
fi

// behind reverse proxy, add to /etc/phpMyAdmin/config.inc.php
// $cfg['pma_absolute_uri'] = 'http://localhost:8180/phpMyAdmin';
// On CentOS/Epel7 it is pma_absolute_uri, on Fedora 28 it is PmaAbsoluteUri

systemctl reload nginx


# download the demo database
cd /home/openpetra
wget https://github.com/openpetra/demo-databases/raw/UsedForNUnitTests/demoWith1ledger.yml.gz
chown openpetra:openpetra demoWith1ledger.yml.gz
cd -

# install demo database
file=/home/openpetra/demoWith1ledger.yml.gz
if [ -f $file ]
then
  /usr/bin/openpetra-server loadYmlGz $file || exit -1
  systemctl restart openpetra-server || exit -1
fi

# copy web.config for easier debugging
cat > /usr/local/openpetra/server/web.config <<FINISH
<configuration>
    <system.web>
        <customErrors mode="Off"/>
    </system.web>
</configuration>
FINISH

echo "now run in ~/openpetra: nant generateSolution install"

