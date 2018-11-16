#!/bin/bash

osType=`uname -s|tr '[A-Z]' '[a-z]'`
HOME_DIR=" "

if [ $osType = "darwin" ] ;then
   HOME_DIR='Users'
   sed -i '' '/export PS1/d' /$HOME_DIR/moja/.bashrc
   sed -i '' '/Users\/moja/d' /$HOME_DIR/moja/.bashrc
elif [ $osType = "linux" ] ;then
  HOME_DIR='home'
  sed -i '/export PS1/d' /$HOME_DIR/moja/.bashrc
  sed -i '/home\/moja/d' /$HOME_DIR/moja/.bashrc
else
  exit 1
fi

rm -r -f /$HOME_DIR/moja/.moja
rm -r -f /$HOME_DIR/moja/.npm
rm -r -f /$HOME_DIR/moja/.npmrc
rm -r -f /$HOME_DIR/moja/.node-gyp
rm -r -f /$HOME_DIR/moja/.pm2
rm -r -f /var/tmp/client-logs
rm -r -f /var/tmp//var/tmp/client-logs-tar
crontab -u root -l | grep -v '.moja' |crontab -

if [ $osType = "darwin" ] ;then
  kill -9 $(ps -ef|grep "/Users/moja/.pm2"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
  kill -9 $(ps -ef|grep "/Users/moja/.moja/client"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
fi
if [ $osType = "linux" ] ;then
  ps -ef|grep -w '/home/moja/.pm2'|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
  ps -ef|grep -w '/home/moja/.moja/client'|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
fi