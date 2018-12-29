#!/bin/bash

#客户端进程守护脚本
HOME_DIR=""
USER_DIR=""

if [ -n "$1" ] ;then
  export PATH=$1
fi

osType=`uname -s|tr '[A-Z]' '[a-z]'`
if [ $osType = "darwin" ] ;then
  HOME_DIR='Users'
fi
if [ $osType = "linux" ] ;then
  HOME_DIR='home'
fi

if [ -f "/$HOME_DIR/moja/install-mode" ] ; then
  USER_DIR=/$HOME_DIR/moja/.moja
else
  USER_DIR=~/.moja
fi

currlVersion=`cat $USER_DIR/moja-version|tr -d '\n'`
appPath="$USER_DIR/client/remote-terminal-client-v$currlVersion/app.js"
tmp=`ps -ef | grep $appPath | grep -v grep`
if [ -f "/$HOME_DIR/moja/install-mode" ] ; then
  if [ -z "$tmp" ]; then
    sudo su - moja -c "env PATH=$PATH:/$HOME_DIR/moja/nodejs/bin /$HOME_DIR/moja/nodejs/bin/node /$HOME_DIR/moja/.moja/client/start.js"
  fi
else
  if [ -z "$tmp" ]; then
    node $USER_DIR/client/start.js $currlVersion
  fi
fi



