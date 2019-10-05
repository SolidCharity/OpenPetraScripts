#!/bin/bash
# Author: Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
# Copyright: 2018-2019 Solidcharity.com
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

  cfgfile="/home/$customer/etc/PetraServerConsole.config"
  if [ -f $cfgfile ]
  then

      # drop the line
      #cat $cfgfile | grep -v "Server.EmailDomain" > $cfgfile.new
      #mv $cfgfile.new $cfgfile

      # replace existing value
      sed -i 's/"Server.EmailDomain" value=".*"/"Server.EmailDomain" value="openpetra.com"/g' $cfgfile

      if [ ! -z $SMTPHOST ]
      then
        sed -i "s/\"SmtpHost\" value=\".*\"/\"SmtpHost\" value=\"$SMTPHOST\"/g" $cfgfile
        sed -i "s/\"SmtpPort\" value=\".*\"/\"SmtpPort\" value=\"$SMTPPORT\"/g" $cfgfile
        sed -i "s/\"SmtpUser\" value=\".*\"/\"SmtpUser\" value=\"$SMTPUSER\"/g" $cfgfile
        sed -i "s/\"SmtpPassword\" value=\".*\"/\"SmtpPassword\" value=\"$SMTPPWD\"/g" $cfgfile
      fi

      if [ ! -z $LICENSECHECKURL ]
      then
        sed -i "s#\"LicenseCheck.Url\" value=\".*\"#\"LicenseCheck.Url\" value=\"https://$LICENSECHECKURL/api.validate?instance_number=\"#g" $cfgfile
      fi

      # add new line
      # grep -q returns 0 if text was found
      if ! grep -q 'Server.EmailDomain' $cfgfile
      then
        sed -i 's#    <add key="ApplicationDirectory"#    <add key="Server.EmailDomain" value="openpetra.com"/>\n    <add key="ApplicationDirectory"#g' $cfgfile
      fi
      if ! grep -q 'LicenseCheck.Url' $cfgfile
      then
        sed -i 's#    <add key="ApplicationDirectory"#    <add key="LicenseCheck.Url" value="https://www.openpetra.com/api/validate.php?instance_number="/>\n    <add key="ApplicationDirectory"#g' $cfgfile
      fi

  fi
}

if [[ "$customer" == "all" ]]
then
  for d in /home/op_*
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
