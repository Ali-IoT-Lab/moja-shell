#!/bin/bash

logPath="/var/tmp/client-logs"
logsTarPath="/var/tmp/client-logs-tar"

if [ ! -d $logsTarPath ]; then
  mkdir -p  $logsTarPath
fi

tar czvfP $logsTarPath/`date +%Y-%m-%d`-log.tar $logPath >>/dev/null
echo > $logPath/out.log
echo > $logPath/err.log

deleteTar=`cd /var/tmp/client-logs-tar;ls -lrt *.tar|head -1|awk -F ' ' '{print $NF}'`
rotateCount=`cd /var/tmp/client-logs-tar;ls -l|grep .tar|wc -l`

if [ $rotateCount -gt 7 ] ;then
  rm -r -f $logsTarPath/$deleteTar
fi
