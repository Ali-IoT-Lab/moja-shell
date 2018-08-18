#!/bin/bash
#install and configure nodejs
# USAGE: sh setup.sh version , e.g. sh node_setup.sh 10.6.0
#

#安装expect

if [ `whoami` = "moja" ];then
  echo "请切换到pi用户或root用户下再执行脚本！"
  exit 0
fi

apt-get -y install expect

logPath="/var/tmp/remote-terminal-client-logs"
appPath="/home/moja/remote-terminal-client/app.js"
pm2Path="/home/moja/nodejs/bin/pm2"
npmPath="/home/moja/nodejs/bin/npm"
hostName="47.98.253.35"
port=3000

#设置开机启动pm2
autoStart="su - moja -c '$pm2Path start $appPath --log-type json --merge-logs --log-date-format="YYYY-MM-DD HH:mm:ss Z" -o $logPath/stdout.json -e $logPath/stderr.json'"
if [ ! -f "/etc/init.d/rc.local" ]; then
  touch /etc/init.d/rc.local
fi

chmod 755 /etc/init.d/rc.local
sed -i ‘/${autoStart}/d’ /etc/init.d/rc.local
echo "${autoStart}" >> /etc/init.d/rc.local

#获取nodejs版本号
if [ $# -eq 0 ] ; then
	VERSION=8.11.3
else
	VERSION=$1
fi

#获取平台类型
archName=`arch`
NODE_VERSION=node-v$VERSION
isX86=$( echo $archName | grep "x86" )
if [ -n "${isX86}" ] ;then
verName=${NODE_VERSION}-linux-x64.tar.xz
elif [ $(echo $archName | grep "arm64") ] ;then
verName=${NODE_VERSION}-linux-arm64.tar.xz
elif [ $( echo $archName | grep "armv6l" ) ] ;then
verName=${NODE_VERSION}-linux-armv6l.tar.xz
elif [ $( echo $archName | grep "armv7l" ) ] ;then
verName=${NODE_VERSION}-linux-armv7l.tar.xz
else
echo "The device type you are using is not supported！"
  exit 1
fi

if ! id moja
then
useradd -s /bin/bash -d /home/moja  -U moja -p 123456 -m
fi
chmod 777 moja
mkdir -p /home/moja/nodejs

cd /home/moja/
runuser -l moja -c "$pm2Path delete all"
runuser -l moja -c "$pm2Path  kill"
runuser -l moja -c "$npmPath  uninstall -g pm2"

runsuer -l moja -c "rm /home/moja/.pm2 -rf"
runuser -l moja -c "rm /home/moja/nodejs -rf"

mkdir -p /home/moja/nodejs

echo `which pm2` |  while read line
do
rm $line -rf
done
echo `which node` |  while read line
do
rm $line -rf
done
echo `which npm` |  while read line
do
rm $line -rf
done

wget -O /home/moja/${verName} https://nodejs.org/dist/v${VERSION}/${verName}
tar -xJf /home/moja/${verName} --no-wildcards-match-slash --anchored \
     --exclude */CHANGELOG.md --exclude */LICENSE --exclude */README.md \
     --strip 1 -C /home/moja/nodejs

echo "export PATH=`echo $PATH |sed 's/:\/home\/moja\/nodejs\/bin\///g'`:/home/moja/nodejs/bin/" >> /home/moja/.profile
source /home/moja/.profile
wget -O /home/moja/remote-terminal-client.tar.gz http://$hostName:$port/api/remote_terminal/getterminaltar
tar -xz -f /home/moja/remote-terminal-client.tar.gz
sleep 2
runuser -l moja -c "$npmPath install --prefix /home/moja/remote-terminal-client node-pty"
runuser -l moja -c "$npmPath install --prefix /home/moja/remote-terminal-client socket.io-client@2.1.1"
mv /var/tmp/`basename $0` /home/moja/remote-terminal-client/bin/`basename $0`

$npmPath install pm2@latest -g

runuser -l moja -c "$pm2Path start $appPath --log-type json --merge-logs --log-date-format=\"YYYY-MM-DD HH:mm:ss Z\" -o $logPath/stdout.json -e $logPath/stderr.json"
runuser -l moja -c "$pm2Path save"

runuser -l moja -c "crontab -r"
runuser -l moja -c "(echo '* * * * */1 $pm2Path flush' ;crontab -l) | crontab"
runuser -l moja -c "(echo '* * */1 * * tar czvfP /var/tmp/\$(date +\"\%Y-\%m-\%d\")-log.tar $logPath >>/dev/null' ;crontab -l) |crontab"
runuser -l moja -c "(echo '*/1 * * * * if ps -ef |grep -v grep|grep $logPath == \"\";then $pm2Path start $appPath --log-type json --merge-logs --log-date-format=\"YYYY-MM-DD HH:mm:ss Z\" -o $logPath/stdout.json -e $logPath/stderr.json; fi';crontab -l) | crontab"

wget -O /home/moja/su_moja http://$hostName:$port/api/remote_terminal/getshell/su_moja.sh
/usr/bin/expect /home/moja/su_moja
