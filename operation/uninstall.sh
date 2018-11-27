#!/bin/bash

osType=`uname -s|tr '[A-Z]' '[a-z]'`
HOME_DIR=""
USER_DIR=""
PM2_DIR=""
if [ -f ~/.moja/install-mode ] ; then
  USER_DIR=~/.moja
  PM2_DIR=~
elif [ -f "/$HOME_DIR/moja/.moja/install-mode" ] ; then
  PM2_DIR=~/moja
  if [ $osType = "darwin" ] ;then
     HOME_DIR='Users'
     USER_DIR=/$HOME_DIR/moja/.moja
     sed -i '' '/export PS1/d' /$HOME_DIR/moja/.bashrc
     sed -i '' '/Users\/moja/d' /$HOME_DIR/moja/.bashrc
     rm -r -f /$HOME_DIR/moja/.npm
     rm -r -f /$HOME_DIR/moja/.npmrc
     rm -r -f /$HOME_DIR/moja/.node-gyp
     rm -r -f /$HOME_DIR/moja/.pm2
  elif [ $osType = "linux" ] ;then
    HOME_DIR='home'
    USER_DIR=/$HOME_DIR/moja/.moja
    sed -i '/export PS1/d' /$HOME_DIR/moja/.bashrc
    sed -i '/home\/moja/d' /$HOME_DIR/moja/.bashrc
    rm -r -f /$HOME_DIR/moja/.npm
    rm -r -f /$HOME_DIR/moja/.npmrc
    rm -r -f /$HOME_DIR/moja/.node-gyp
    rm -r -f /$HOME_DIR/moja/.pm2
  else
    exit 1
  fi
else
  exit 1
fi


rm -r -f $USER_DIR
rm -r -f /var/tmp/client-logs
rm -r -f /var/tmp//var/tmp/client-logs-tar
crontab -u root -l | grep -v '.moja' |crontab -

if [ $osType = "darwin" ] ;then
  kill -9 $(ps -ef|grep "$PM2_DIR/.pm2"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
  kill -9 $(ps -ef|grep "$USER_DIR/client"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
fi
if [ $osType = "linux" ] ;then
  ps -ef|grep -w "$PM2_DIR/.pm2"|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
  ps -ef|grep -w "$USER_DIR/client"|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
fi