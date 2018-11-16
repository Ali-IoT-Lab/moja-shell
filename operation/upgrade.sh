#!/bin/bash

newClientVersion=$1
HOME_DIR=""
osType=`uname -s|tr '[A-Z]' '[a-z]'`
if [ $osType = "linux" ] ;then
  HOME_DIR="home"
elif [ $osType = "darwin" ] ;then
  HOME_DIR="Users"
else
  echo "-----------------------------------不支持的系统类型------------------------------------"
  exit 1
fi

echo "0"> /$HOME_DIR/moja/.moja/stage
hostName=`cat /$HOME_DIR/moja/.moja/moja-cloud-server-host|tr -d '\n'`
clientPath="/$HOME_DIR/moja/.moja/client/remote-terminal-client-v$newClientVersion"
npmPath="/$HOME_DIR/moja/.moja/nodejs/bin/npm"
oldVersion=`cat /$HOME_DIR/moja/.moja/moja-version`

npmopt="--userconfig=/$HOME_DIR/moja/.npmrc"
nodePath="/$HOME_DIR/moja/.moja/nodejs/bin/node"
mkdir $clientPath

echo "1"> /$HOME_DIR/moja/.moja/stage
echo "--------------------------------------下载新版本代码-------------------------------------"
curl -o $clientPath.tar.gz $hostName/api/remote-terminal/tar/remote-terminal-client-v$newClientVersion.tar.gz
if [ $? -ne 0 ] ; then
  echo "----------------------------------下载新版本代码失败-------------------------------------"
   echo > /$HOME_DIR/moja/.moja/stage
  exit 1
fi
echo "2"> /$HOME_DIR/moja/.moja/stage
echo "--------------------------------------解压新版本代码-------------------------------------"
tar -xvf $clientPath.tar.gz --strip 1 -C /$HOME_DIR/moja/.moja/client/remote-terminal-client-v$newClientVersion

if [ $? -ne 0 ] ; then
  echo "----------------------------------解压新版本代码失败-------------------------------------"
  echo > /$HOME_DIR/moja/.moja/stage
  exit 1
fi

rm -r -f /$HOME_DIR/moja/.moja/client/remote-terminal-client-v$newClientVersion.tar.gz
echo "3"> /$HOME_DIR/moja/.moja/stage
echo "--------------------------------------安装客户端依赖-------------------------------------"
cd /$HOME_DIR/moja/.moja/client/remote-terminal-client-v$newClientVersion

if [ `whoami` = 'moja' ] ; then
  npm install --unsafe-perm $npmopt
  if [ $? -ne 0 ] ; then
    echo "----------------------------------安装客户端依赖失败-------------------------------------"
    echo > /$HOME_DIR/moja/.moja/stage
    exit 1
  fi
else
  $envrun $npmPath install --unsafe-perm $npmopt
  if [ $? -ne 0 ] ; then
    echo "----------------------------------安装客户端依赖失败-------------------------------------"
    echo > /$HOME_DIR/moja/.moja/stage
    exit 1
  fi
fi

echo "4"> /$HOME_DIR/moja/.moja/stage
echo "-----------------------------------启动新版本代码-----------------------------------"
$nodePath /$HOME_DIR/moja/.moja/client/start.js
result=$?

echo "5"> /$HOME_DIR/moja/.moja/stage
if [ $result -ne 0 ] ; then
echo "----------------------------------升级失败回退到旧版本代码---------------------------------"
  rm -r -f /$HOME_DIR/moja/.moja/client/remote-terminal-client-v$newClientVersion
  echo > /$HOME_DIR/moja/.moja/stage
  exit 1
fi
