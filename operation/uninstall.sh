#!/bin/bash

osType=`uname -s|tr '[A-Z]' '[a-z]'`
HOME_DIR=""
USER_DIR=""
PM2_DIR=""

if [ $osType = "darwin" ] ;then
  HOME_DIR='Users'
fi

if [ $osType = "linux" ] ;then
  HOME_DIR='home'
fi

if [ -f "/$HOME_DIR/moja/install-mode" ] ; then
  PM2_DIR=/$HOME_DIR/moja
  USER_DIR=/$HOME_DIR/moja/.moja
  if [ $osType = "darwin" ] ;then
     sed -i '' '/export PS1/d' /$HOME_DIR/moja/.bashrc
     sed -i '' '/Users\/moja/d' /$HOME_DIR/moja/.bashrc
  elif [ $osType = "linux" ] ;then
    sed -i '/export PS1/d' /$HOME_DIR/moja/.bashrc
    sed -i '/home\/moja/d' /$HOME_DIR/moja/.bashrc
  else
    exit 1
  fi
  rm -r -f /$HOME_DIR/moja/.npm
  rm -r -f /$HOME_DIR/moja/.npmrc
  rm -r -f /$HOME_DIR/moja/npm-cache
  rm -r -f /$HOME_DIR/moja/nodejs
  rm -r -f /$HOME_DIR/moja/.pm2
  rm -r -f /$HOME_DIR/moja/.moja_key
  rm -r -f /$HOME_DIR/moja/install-mode
  touch /$HOME_DIR/moja/uninstall
else
  USER_DIR=~/.moja
  PM2_DIR=~
  crontab -l | grep '.moja' |crontab -
fi

rm -r -f $USER_DIR
rm -r -f /var/tmp/client-logs
rm -r -f /var/tmp//var/tmp/client-logs-tar


if [ $osType = "darwin" ] ;then
  kill -9 $(ps -ef|grep "$PM2_DIR/.pm2"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
  kill -9 $(ps -ef|grep "$USER_DIR/client"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
fi
if [ $osType = "linux" ] ;then
  ps -ef|grep -w "$PM2_DIR/.pm2"|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
  ps -ef|grep -w "$USER_DIR/client"|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
fi