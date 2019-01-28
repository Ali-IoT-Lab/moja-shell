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

currVersion=`cat $USER_DIR/moja-version|tr -d '\n'`
appPath="$USER_DIR/client/v$currVersion/node_modules"
startPath="$USER_DIR/client/v$currVersion/node_modules/remote-terminal-client/start.js"
tmp=`ps -ef | grep $appPath | grep -v grep`

if [ -f "/$HOME_DIR/moja/install-mode" ] ; then
  if [ -z "$tmp" ]; then
    sudo su - moja -c "/$HOME_DIR/moja/nodejs/bin/node $startPath $currVersion"
    cd $USER_DIR/client;rm -r -f `ls | grep -v "v$currVersion"`
  fi
else
  if [ -z "$tmp" ]; then
    node $startPath $currVersion
    cd $USER_DIR/client;rm -r -f `ls | grep -v "v$currVersion"`
  fi
fi
