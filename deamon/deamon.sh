#!/bin/bash

#客户端进程守护脚本
HOME_DIR=""
USER_DIR=""

osType=`uname -s|tr '[A-Z]' '[a-z]'`
if [ $osType = "darwin" ] ;then
  HOME_DIR='Users'
fi
if [ $osType = "linux" ] ;then
  HOME_DIR='home'
fi

if [ -f ~/.moja/install-mode ] ; then
  USER_DIR=~/.moja
elif [ -f "/$HOME_DIR/moja/.moja/install-mode" ] ; then
  USER_DIR=/$HOME_DIR/moja/.moja
else
  exit 1
fi

currlVersion=`cat $USER_DIR/moja-version|tr -d '\n'`
appPath="$USER_DIR/client/remote-terminal-client-v$currlVersion/app.js"
nodePath="$USER_DIR/nodejs/bin/node"
tmp=`ps -ef | grep $appPath | grep -v grep`

if [ -f ~/.moja/install-mode ] ; then
  if [ -z "$tmp" ]; then
    node $USER_DIR/client/start.js $currlVersion npm
  fi
elif [ -f "/$HOME_DIR/moja/.moja/install-mode" ] ; then
  if [ -z "$tmp" ]; then
    sudo su - moja -c "env PATH=$PATH:$USER_DIR/nodejs/bin $nodePath $USER_DIR/client/start.js"
  fi
else
  exit 1
fi




