#!/bin/bash

newClientVersion=$1
HOME_DIR=""
USER_DIR=""
pm2Path=""

osType=`uname -s|tr '[A-Z]' '[a-z]'`
if [ $osType = "linux" ] ;then
  HOME_DIR="home"
elif [ $osType = "darwin" ] ;then
  HOME_DIR="Users"
else
  echo "-----------------------------------不支持的系统类型------------------------------------"
  exit 1
fi

if [ -f ~/.moja/install-mode ] ; then
  USER_DIR=~/.moja
  pm2Path=$USER_DIR/client/remote-terminal-client-v$newClientVersion/node_modules/pm2/bin/pm2
elif [ -f "/$HOME_DIR/moja/.moja/install-mode" ] ; then
  USER_DIR=/$HOME_DIR/moja/.moja
else
  exit 1
fi

oldVersion=`cat $USER_DIR/moja-version`

if [ "$oldVersion" = "$newClientVersion" ];then
  echo "相同版本的应用！"
else
  if [ -f ~/.moja/install-mode ] ; then
    $pm2Path delete client-v$oldVersion
  elif [ -f "/$HOME_DIR/moja/.moja/install-mode" ] ; then
    pm2 delete client-v$oldVersion
  else
    exit 1
  fi
  rm -r -f $USER_DIR/client/remote-terminal-client-v$oldVersion
fi

cp -r -f $USER_DIR/client/remote-terminal-client-v$newClientVersion/deamon $USER_DIR/client
cp -r -f $USER_DIR/client/remote-terminal-client-v$newClientVersion/handleLog $USER_DIR/client

echo $newClientVersion > $USER_DIR/moja-version
echo > $USER_DIR/stage
