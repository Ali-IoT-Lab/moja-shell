#!/bin/bash

# pm2 守护脚本

osType=`uname -s|tr '[A-Z]' '[a-z]'`

if [ $osType = "darwin" ] ;then
  HOME='Users'
fi
if [ $osType = "linux" ] ;then
  HOME='home'
fi

envrun="sudo -u moja env PATH=$PATH:/$HOME_DIR/moja/nodejs/bin"

logPath="/var/tmp/client-logs"
appPath="/$HOME/moja/remote-terminal-client/app.js"
pm2Path="/$HOME/moja/nodejs/bin/pm2"

tmp=`ps -ef | grep $appPath | grep -v grep`

if [ -z "$tmp" ]; then 
$envrun $pm2Path start $appPath --log-type json --merge-logs --log-date-format="YYYY-MM-DD HH:mm:ss Z" -o $logPath/out.log -e $logPath/err.log
fi


