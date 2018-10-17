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

pm2Path="/$HOME_DIR/moja/.config/nodejs/bin/pm2"
envrun="sudo -u moja env PATH=$PATH:/$HOME_DIR/moja/.config/nodejs/bin"
oldVersion=`cat /$HOME_DIR/moja/.config/moja-version`
echo $newClientVersion > /$HOME_DIR/moja/.config/moja-version
rm -r -f /$HOME_DIR/moja/.config/client-source/*
if [ `whoami` = 'moja' ] ; then
  if [ "$oldVersion" = "$newClientVersion" ];then
    echo "相同版本的应用！"
  else
    pm2 delete client-v$oldVersion
  fi
else
  if [ "$oldVersion" = "$newClientVersion" ];then
    echo "相同版本的应用！"
  else
    $envrun $pm2Path delete client-v$oldVersion
  fi
fi