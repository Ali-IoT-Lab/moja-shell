#!/bin/bash

newClientVersion=$1
oldVersion=`cat ~/.moja/moja-version|tr -d '\n'`
~/.moja/pmtwo/node_modules/pm2/bin/pm2 delete client-v$oldVersion
echo $newClientVersion > ~/.moja/moja-version
rm -r -f ~/.moja/client/v$oldVersion
echo > ~/.moja/stage
