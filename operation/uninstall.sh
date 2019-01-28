#!/bin/bash

osType=`uname -s|tr '[A-Z]' '[a-z]'`
moja_home=~/.moja
currHOME=~

if [ -f "$currHOME/install-mode" ] ; then
  touch $currHOME/uninstall
  rm -r -f $currHOME/.npm
  rm -r -f $currHOME/nodejs
  rm -r -f $currHOME/.npmrc
  rm -r -f $currHOME/.pm2
  rm -r -f $currHOME/install-mode
  rm -r -f $currHOME/npm-cache
fi

rm -r -f $currHOME/.moja_key
rm -r -f $moja_home
rm -r -f /var/tmp/client-logs
rm -r -f var/tmp/client-logs-tar
crontab -l | grep -v '.moja' |crontab -

if [ $osType = "darwin" ] ;then
  rm -r -f /Users/moja/.moja
  kill -9 $(ps -ef|grep "$currHOME/.pm2"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
  kill -9 $(ps -ef|grep "$moja_home/client"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
  sed -i '' '/export PS1/d' $currHOME/.bashrc
  sed -i '' '/Users\/moja/d' $currHOME/.bashrc
fi

if [ $osType = "linux" ] ;then
  rm -r -f /home/moja/.moja
  ps -ef|grep -w "$currHOME/.pm2"|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
  ps -ef|grep -w "$moja_home/client"|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
  sed -i '/export PS1/d' $currHOME/.bashrc
  sed -i '/home\/moja/d' $currHOME/.bashrc
fi


