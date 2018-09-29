#!/bin/bash


osType=`uname -s|tr '[A-Z]' '[a-z]'`

if [ $osType = "darwin" ] ;then
  HOME='Users'
fi
if [ $osType = "linux" ] ;then
  HOME='home'
fi

envrun="sudo -u moja env PATH=$PATH:/$HOME_DIR/moja/.config/nodejs/bin"
logPath="/var/tmp/client-logs"
logsTarPath="/var/tmp/client-logs-tar"
pm2Path="/$HOME/moja/.config/nodejs/bin/pm2"

$envrun $pm2Path flush

echo > $logPath/err.log
echo > $logPath/out.log
deleteTar=`cd /var/tmp/client-logs-tar;ls -lrt *.tar|head -1|awk -F ' ' '{print $NF}'`
rotateCount=`cd /var/tmp/client-logs-tar;ls -l|grep .tar|wc -l`

if [ $rotateCount -gt 7 ] ;then
  rm $logsTarPath/$deleteTar -rf
fi


