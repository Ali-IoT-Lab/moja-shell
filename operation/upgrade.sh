

#!/bin/bash

clientVersion=$1

mkdir -p ~/.moja/client/v$1
echo "3"> ~/.moja/stage
npm install remote-terminal-client@latest --unsafe-perm=true --registry=https://registry.cnpmjs.org --prefix ~/.moja/client/v$clientVersion
echo "4"> ~/.moja/stage
node ~/.moja/client/v$clientVersion/node_modules/remote-terminal-client/start.js $clientVersion
result=$?

echo "5"> ~/.moja/stage
if [ $result -ne 0 ] ; then
echo "----------------------------------升级失败回退到旧版本代码---------------------------------"
  rm -r -f ~/.moja/client/v$clientVersion
  echo > ~/.moja/stage
  exit 1
fi