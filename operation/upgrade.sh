#!/bin/bash

newClientVersion=$1
HOME_DIR=""
USER_DIR=""
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
elif [ -f "/$HOME_DIR/moja/.moja/install-mode" ] ; then
  USER_DIR=/$HOME_DIR/moja/.moja
else
  exit 1
fi

echo "0"> $USER_DIR/stage
hostName=`cat $USER_DIR/moja-cloud-server-host|tr -d '\n'`
clientPath="$USER_DIR/client/remote-terminal-client-v$newClientVersion"
oldVersion=`cat $USER_DIR/moja-version`
mkdir $clientPath

echo "1"> $USER_DIR/stage
echo "--------------------------------------下载新版本代码-------------------------------------"
curl -o $clientPath.tar.gz $hostName/api/remote-terminal/tar/remote-terminal-client-v$newClientVersion.tar.gz


if [ $? -ne 0 ] ; then
  echo "----------------------------------下载新版本代码失败-------------------------------------"
   rm -r -f $clientPath.tar.gz
   echo > $USER_DIR/stage
  exit 1
fi
echo "2"> $USER_DIR/stage
echo "--------------------------------------解压新版本代码-------------------------------------"
tar -xvf $clientPath.tar.gz --strip 1 -C $USER_DIR/client/remote-terminal-client-v$newClientVersion

if [ $? -ne 0 ] ; then
  echo "----------------------------------解压新版本代码失败-------------------------------------"
  rm -r -f $clientPath.tar.gz
  rm -r -f $clientPath
  echo > $USER_DIR/stage
  exit 1
fi

rm -r -f $USER_DIR/client/remote-terminal-client-v$newClientVersion.tar.gz
echo "3"> $USER_DIR/stage
echo "--------------------------------------安装客户端依赖-------------------------------------"
cd $USER_DIR/client/remote-terminal-client-v$newClientVersion
 npm config set loglevel=http
 npm install --unsafe-perm=true --registry https://registry.cnpmjs.org
if [ $? -ne 0 ] ; then
  echo "----------------------------------安装客户端依赖失败-------------------------------------"
  rm -r -f $clientPath
  echo > $USER_DIR/stage
  exit 1
fi

echo "4"> $USER_DIR/stage
echo "-----------------------------------启动新版本代码-----------------------------------"
if [ -f ~/.moja/install-mode ] ; then
  node $USER_DIR/client/start.js $newClientVersion npm
  result=$?
elif [ -f "$USER_DIR/install-mode" ] ; then
  $USER_DIR/nodejs/bin/node $USER_DIR/client/start.js $newClientVersion
  result=$?
else
  exit 1
fi

echo "5"> $USER_DIR/stage
if [ $result -ne 0 ] ; then
echo "----------------------------------升级失败回退到旧版本代码---------------------------------"
  rm -r -f $clientPath
  echo > $USER_DIR/stage
  exit 1
fi
