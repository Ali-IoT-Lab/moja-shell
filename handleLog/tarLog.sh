#!/bin/bash

logPath="/var/tmp/remote-terminal-client-logs"
logsTarPath="/var/tmp/remote-terminal-client-logs-tar"

if [ ! -d $logsTarPath ]; then
mkdir -p  $logsTarPath
fi

tar czvfP $logsTarPath/`date +%Y-%m-%d`-log.tar $logPath >>/dev/null
echo > $logPath/stdout.json
echo > $logPath/stderr.json

deleteTar=`cd /var/tmp/remote-terminal-client-logs-tar;ls -lrt *.tar|head -1|awk -F ' ' '{print $NF}'`
rotateCount=`cd /var/tmp/remote-terminal-client-logs-tar;ls -l|grep .tar|wc -l`

if [ $rotateCount -gt 7 ] ;then
rm $logsTarPath/$deleteTar -rf
fi
