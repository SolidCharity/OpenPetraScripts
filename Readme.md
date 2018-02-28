Purpose
-------

These scripts are useful for deploying OpenPetra into test environments.

You can easily regenerate a configuration without the need to reinstall the full machine.

You can also test the hosting of multiple OpenPetra services within one server.

There are also scripts to setup a development environment.

Our only target is CentOS7 currently.

Setup a test environment
------------------------

On CentOS:

    yum install git
    git clone https://github.com/TBits/OpenPetraScripts.git
    cd OpenPetraScripts/openpetra
    ./reinstall.sh
    # replace localhost with the IP address or with the URL of your installation
    sed -i "s#http://localhost/api';#http://192.168.124.70/api';#g" /etc/nginx/conf.d/openpetra.conf
    systemctl restart nginx

You can now reach OpenPetra at:

* http://192.168.124.70
* http://192.168.124.70/api

You can login with user sysadmin and password CHANGEME.

Please note: It is recommended to use https for production use. You could modify the nginx configuration, but that is not part of these scripts, because we are using a reverse proxy for https at TBits.net.

Setup a development environment
-------------------------------

On CentOS:
 
    # same steps as above
    yum install git
    git clone https://github.com/TBits/OpenPetraScripts.git
    cd OpenPetraScripts/openpetra
    ./reinstall.sh
    # replace localhost with the IP address or with the URL of your installation
    sed -i "s#http://localhost/api';#http://192.168.124.70/api';#g" /etc/nginx/conf.d/openpetra.conf
    systemctl restart nginx

    ./setupDevEnv.sh
    cd ~/openpetra
    nant generateSolution
    nant resetDatabase
    nant install
    systemctl restart openpetra-server

You can now reach OpenPetra at:

* http://192.168.124.70
* http://192.168.124.70/api

You can login with user sysadmin and password CHANGEME, or with user demo and password DEMO.

You can now edit the client code in /root/openpetra-client-js, run there `npm run build` and refresh your browser.

And you can work on the server code in /root/openpetra, run there `nant quickCompile install` and refresh your browser.

Setup the demo.openpetra.org
----------------------------

    # same steps as above
    yum install git
    git clone https://github.com/TBits/OpenPetraScripts.git
    cd OpenPetraScripts/openpetra
    ./reinstall.sh

    # configure the demo
    yum install wget
    ./configureDemo.sh
    systemctl stop openpetra-server
    systemctl disable openpetra-server
    systemctl status op_demo

