#!/bin/bash

hostName="terminal.moja-lab.com"
protocol="https"
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
logPath="/var/tmp/client-logs"
pm2Path="/$HOME_DIR/moja/.config/nodejs/bin/pm2"
clientPath="/$HOME_DIR/moja/.config/remote-terminal-client"
appPath="/$HOME_DIR/moja/.config/remote-terminal-client/app.js"
clientPath="/$HOME_DIR/moja/.config/remote-terminal-client"
npmopt="--userconfig=/$HOME_DIR/moja/.npmrc"
envrun="sudo -u moja env PATH=$PATH:/$HOME_DIR/moja/.config/nodejs/bin"
echo "0"> /$HOME_DIR/moja/.config/stage
echo "--------------------------------------备份旧版本---------------------------------------"
mv /$HOME_DIR/moja/.config/remote-terminal-client /$HOME_DIR/moja/.config/client-source
echo "1"> /$HOME_DIR/moja/.config/stage
echo "--------------------------------------下载新版本代码-------------------------------------"
curl -o $clientPath.tar.gz $protocol://$hostName/api/remote-terminal/tar/remote-terminal-client.tar.gz
if [ $? -ne 0 ] ; then
  echo "----------------------------------下载新版本代码失败-------------------------------------"
  exit 1
fi
echo "2"> /$HOME_DIR/moja/.config/stage
echo "--------------------------------------解压新版本代码-------------------------------------"
tar -xvf /$HOME_DIR/moja/.config/remote-terminal-client.tar.gz -C /$HOME_DIR/moja/.config
if [ $? -ne 0 ] ; then
  echo "----------------------------------解压新版本代码失败-------------------------------------"
  exit 1
fi
rm -r -f /$HOME_DIR/moja/.config/remote-terminal-client.tar.gz
echo "3"> /$HOME_DIR/moja/.config/stage
echo "--------------------------------------安装客户端依赖-------------------------------------"
cd /$HOME_DIR/moja/.config/remote-terminal-client

if [ `whoami` = 'moja' ] ; then
  npm install --unsafe-perm=true $npmopt
  if [ $? -ne 0 ] ; then
    echo "----------------------------------安装客户端依赖失败-------------------------------------"
    exit 1
  fi
else
  $envrun $npmPath install --unsafe-perm=true $npmopt
  if [ $? -ne 0 ] ; then
    echo "----------------------------------安装客户端依赖失败-------------------------------------"
    exit 1
  fi
fi
echo "4"> /$HOME_DIR/moja/.config/stage
echo "-----------------------------------加载新版本代码-----------------------------------"
if [ `whoami` = 'moja' ] ; then
  pm2 start $appPath --log-type json --merge-logs --log-date-format="YYYY-MM-DD HH:mm:ss Z" -o $logPath/out.log -e $logPath/err.log --name client-v$newClientVersion
  result=$?
else
  $envrun $pm2Path start $appPath --log-type json --merge-logs --log-date-format="YYYY-MM-DD HH:mm:ss Z" -o $logPath/out.log -e $logPath/err.log --name client-v$newClientVersion
  result=$?
fi

echo "5"> /$HOME_DIR/moja/.config/stage
if [ $result -ne 0 ] ; then
echo "----------------------------------升级失败回退到旧版本代码---------------------------------"
  rm -r -f $clientPath
  mv /$HOME_DIR/moja/.config/client-source/remote-terminal-client /$HOME_DIR/moja/.config/
  exit 1
fi
