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

if [ -f "/$HOME_DIR/moja/install-mode" ] ; then
  USER_DIR=/$HOME_DIR/moja/.moja
  pm2Path='pm2'
else
  USER_DIR=~/.moja
  pm2Path=$USER_DIR/pmtwo/node_modules/pm2/bin/pm2
fi

oldVersion=`cat $USER_DIR/moja-version|tr -d '\n'`

if [ "$oldVersion" = "$newClientVersion" ];then
  echo "相同版本的应用！"
else
  $pm2Path delete client-v$oldVersion
  rm -r -f $USER_DIR/client/remote-terminal-client-v$oldVersion
fi

cp -r -f $USER_DIR/client/remote-terminal-client-v$newClientVersion/deamon $USER_DIR/client
cp -r -f $USER_DIR/client/remote-terminal-client-v$newClientVersion/handleLog $USER_DIR/client

echo $newClientVersion > $USER_DIR/moja-version
echo > $USER_DIR/stage
