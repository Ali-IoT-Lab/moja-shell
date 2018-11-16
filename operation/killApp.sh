#!/bin/bash

newClientVersion=$1
osType=`uname -s|tr '[A-Z]' '[a-z]'`
if [ $osType = "linux" ] ;then
  HOME_DIR="home"
elif [ $osType = "darwin" ] ;then
  HOME_DIR="Users"
else
  echo "-----------------------------------不支持的系统类型------------------------------------"
  exit 1
fi

pm2Path="/$HOME_DIR/moja/.moja/nodejs/bin/pm2"
oldVersion=`cat /$HOME_DIR/moja/.moja/moja-version`
envrun="sudo -u moja env PATH=$PATH:/$HOME_DIR/moja/.moja/nodejs/bin"

if [ "$oldVersion" = "$newClientVersion" ];then
  echo "相同版本的应用！"
else
  if [ `whoami` = 'moja' ] ; then
    pm2 delete client-v$oldVersion
  else
    $envrun $pm2Path delete client-v$oldVersion
  fi
  rm -r -f /$HOME_DIR/moja/.moja/client/remote-terminal-client-v$oldVersion
fi

echo $newClientVersion > /$HOME_DIR/moja/.moja/moja-version
rm -r -f /$HOME_DIR/moja/.moja/client-source/*
echo > /$HOME_DIR/moja/.moja/stage
