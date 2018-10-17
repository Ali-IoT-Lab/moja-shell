#!/bin/bash

osType=`uname -s|tr '[A-Z]' '[a-z]'`
HOME_DIR=" "

if [ $osType = "darwin" ] ;then
   HOME_DIR='Users'
   sed -i '' '/export PS1/d' /$HOME_DIR/moja/.bashrc
   sed -i '' '/Users\/moja/d' /$HOME_DIR/moja/.bashrc
   sed -i '' '/--log-type json --merge-logs --log-date-format=\"YYYY-MM-DD HH:mm:ss Z\"/d' /etc/rc.local
elif [ $osType = "linux" ] ;then
  HOME_DIR='home'
  sed -i '/export PS1/d' /$HOME_DIR/moja/.bashrc
  sed -i '/home\/moja/d' /$HOME_DIR/moja/.bashrc
  sed -i '/--log-type json --merge-logs --log-date-format=\"YYYY-MM-DD HH:mm:ss Z\"/d' /etc/rc.local
else
  echo "-----------------------------------不支持的系统类型------------------------------------"
  exit 1
fi

rm -r -f /$HOME_DIR/moja/.config
rm -r -f /$HOME_DIR/moja/.npm
rm -r -f /$HOME_DIR/moja/.npmrc
rm -r -f /$HOME_DIR/moja/.node-gyp
rm -r -f /$HOME_DIR/moja/.pm2
rm -r -f /var/tmp/client-logs
rm -r -f /var/tmp//var/tmp/client-logs-tar

if [ $osType = "darwin" ] ;then
  kill -9 $(ps -ef|grep "/Users/moja/.pm2"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
  kill -9 $(ps -ef|grep "/Users/moja/.config/remote-terminal-client/app.js"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
fi
if [ $osType = "linux" ] ;then
  ps -ef|grep -w '/home/moja/.pm2'|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
  ps -ef|grep -w '/home/moja/.config/remote-terminal-client/app.js'|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
fi