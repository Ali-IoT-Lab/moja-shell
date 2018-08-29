#!/bin/bash

# pm2 守护脚本

logPath="/var/tmp/remote-terminal-client-logs"
appPath="/home/moja/remote-terminal-client/app.js"
pm2Path="/home/moja/nodejs/bin/pm2"

tmp=`ps -ef | grep $appPath | grep -v grep`

if [ -z "$tmp" ]; then 
$pm2Path start $appPath --log-type json --merge-logs --log-date-format="YYYY-MM-DD HH:mm:ss Z" -o $logPath/stdout.json -e $logPath/stderr.json
fi


