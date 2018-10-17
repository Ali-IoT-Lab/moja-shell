#!/bin/bash
hostName="terminal.moja-lab.com"
protocol="https"
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
envrun="sudo -u moja env PATH=$PATH:/$HOME_DIR/moja/.config/nodejs/bin"
oldVersion=`cat /$HOME_DIR/moja/.config/moja-version`

echo "--------------------------------------备份旧版本---------------------------------------"
rm -r -f clientPath.tar.gz
mv /$HOME_DIR/moja/.config/remote-terminal-client /$HOME_DIR/moja/
echo "--------------------------------------下载新版本---------------------------------------"
curl -o $clientPath.tar.gz $protocol://$hostName/api/remote-terminal/tar/remote-terminal-client.tar.gz
echo "--------------------------------------解压新版本---------------------------------------"
tar -xvf /$HOME_DIR/moja/.config/remote-terminal-client.tar.gz -C /$HOME_DIR/moja/.config
rm -r -f /$HOME_DIR/moja/.config/remote-terminal-client.tar.gz
echo "-----------------------------------加载新版本代码-----------------------------------"
if [ `whoami` = 'moja' ] ; then
  pm2 start $appPath --log-type json --merge-logs --log-date-format="YYYY-MM-DD HH:mm:ss Z" -o $logPath/out.log -e $logPath/err.log --name client-v$newClientVersion
  result=$?
else
  $envrun $pm2Path start $appPath --log-type json --merge-logs --log-date-format="YYYY-MM-DD HH:mm:ss Z" -o $logPath/out.log -e $logPath/err.log --name client-v$newClientVersion
  result=$?
fi

if [ $result -ne 0 ] ; then
echo "----------------------------------升级失败回退到旧版本代码---------------------------------"
  rm -r -f $clientPath
  mv /$HOME_DIR/moja/remote-terminal-client /$HOME_DIR/moja/.config/
else
  if [ ! -f "/$HOME_DIR/moja/.config/moja-version" ];then
    if [ `whoami` = 'moja' ] ; then
      pm2 delete app
    else
      $envrun $pm2Path delete app
    fi
  else
    if [ `whoami` = 'moja' ] ; then
      pm2 delete client-v$oldVersion
    else
      $envrun $pm2Path delete client-v$oldVersion
    fi
  fi
fi