#!/bin/bash

#客户端进程守护脚本
osType=`uname -s|tr '[A-Z]' '[a-z]'`
if [ $osType = "darwin" ] ;then
  HOME_DIR='Users'
fi
if [ $osType = "linux" ] ;then
  HOME_DIR='home'
fi
currlVersion=`cat /$HOME_DIR/moja/.moja/moja-version|tr -d '\n'`
appPath="/$HOME_DIR/moja/.moja/client/remote-terminal-client-v$currlVersion/app.js"
nodePath="/$HOME_DIR/moja/.moja/nodejs/bin/node"
tmp=`ps -ef | grep $appPath | grep -v grep`

if [ -z "$tmp" ]; then
  sudo su - moja -c "env PATH=$PATH:/$HOME_DIR/moja/.moja/nodejs/bin $nodePath /$HOME_DIR/moja/.moja/client/start.js"
fi


