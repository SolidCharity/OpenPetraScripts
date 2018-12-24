#!/bin/bash
# Author: Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
# Copyright: 2018 Solidcharity.com
# Description: set the smtp settings for the instance(s)

if [ -z "$1" ]
then
  echo "call: . $0 all"
  echo "call: . $0 <customer>"
  exit -1
fi

if [ -z "$SMTP_HOST" -o -z "$SMTP_PORT" -o -z "$SMTP_USER" ]
then
  echo "you need to export first: SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PWD"
  exit -1
fi

customer=$1

function set_smtp {
  customer=$1

  if [ -f /usr/lib/systemd/system/$customer.service ]
  then
    if [[ "`systemctl is-enabled $customer`" == "enabled" ]]
    then
      cfgfile="/home/$customer/etc/PetraServerConsole.config"
      sed -i 's/"SmtpHost" value=".*"/"SmtpHost" value="'$SMTP_HOST'"/g' $cfgfile
      sed -i 's/"SmtpPort" value=".*"/"SmtpPort" value="'$SMTP_PORT'"/g' $cfgfile
      sed -i 's/"SmtpUser" value=".*"/"SmtpUser" value="'$SMTP_USER'"/g' $cfgfile
      sed -i 's/"SmtpPassword" value=".*"/"SmtpPassword" value="'$SMTP_PWD'"/g' $cfgfile
      sed -i 's/"SmtpEnableSsl" value=".*"/"SmtpEnableSsl" value="'true'"/g' $cfgfile
      sed -i 's/"SmtpAuthenticationType" value=".*"/"SmtpAuthenticationType" value="'config'"/g' $cfgfile

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
      set_smtp $service
    fi
  done
else
  set_smtp $customer
fi
