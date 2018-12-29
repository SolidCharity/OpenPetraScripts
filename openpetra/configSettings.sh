#!/bin/bash
# Author: Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
# Copyright: 2018 Solidcharity.com
# Description: set various config settings for the instance(s)

if [ -z "$1" ]
then
  echo "call: . $0 all"
  echo "call: . $0 <customer>"
  exit -1
fi

customer=$1

function set_config {
  customer=$1

  if [ -f /usr/lib/systemd/system/$customer.service ]
  then
    if [[ "`systemctl is-enabled $customer`" == "enabled" ]]
    then
      cfgfile="/home/$customer/etc/PetraServerConsole.config"

      # drop the line
      #cat $cfgfile | grep -v "Server.EmailDomain" > $cfgfile.new
      #mv $cfgfile.new $cfgfile

      # replace existing value
      sed -i 's/"Server.EmailDomain" value=".*"/"Server.EmailDomain" value="openpetra.com"/g' $cfgfile

      # add new line
      # grep -q returns 0 if text was found
      if ! grep -q 'Server.EmailDomain' $cfgfile ; then
      then
        sed -i 's#    <add key="ApplicationDirectory"#    <add key="Server.EmailDomain" value="openpetra.com"/>\n    <add key="ApplicationDirectory"#g' $cfgfile
      fi

      echo "restarting $customer"
      systemctl restart $customer
    fi
  fi
}

if [[ "$customer" == "all" ]]
then
  for d in /home/openpetra /home/op_*
  do
    if [ -d $d ]
    then
      service=`basename $d`
      set_config $service
    fi
  done
else
  set_config $customer
fi
