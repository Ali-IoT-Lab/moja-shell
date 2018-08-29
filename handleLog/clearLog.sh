#!/bin/bash

logPath="/var/tmp/remote-terminal-client-logs"
pm2Path="/home/moja/nodejs/bin/pm2"
logsTarPath="/var/tmp/remote-terminal-client-logs-tar"

$pm2Path flush
echo > $logPath/stderr.json
echo > $logPath/stdout.json
deleteTar=`cd /var/tmp/remote-terminal-client-logs-tar;ls -lrt *.tar|head -1|awk -F ' ' '{print $NF}'`
rotateCount=`cd /var/tmp/remote-terminal-client-logs-tar;ls -l|grep .tar|wc -l`

if [ $rotateCount -gt 7 ] ;then
rm $logsTarPath/$deleteTar -rf
fi


