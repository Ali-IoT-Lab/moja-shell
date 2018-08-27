#!/bin/bash
#install and configure nodejs
# USAGE: sh setup.sh version , e.g. sh node_setup.sh 10.6.0

#安装expect

if [ `whoami` = "moja" ];then
  echo "请切换到pi用户或root用户下再执行脚本！"
  exit 0
fi

apt-get -y install expect

logPath="/var/tmp/remote-terminal-client-logs"
logsTarPath="/var/tmp/remote-terminal-client-logs-tar"

appPath="/home/moja/remote-terminal-client/app.js"
pm2Path="/home/moja/nodejs/bin/pm2"
npmPath="/home/moja/nodejs/bin/npm"
clientPath="/home/moja/remote-terminal-client"
deamonPath="sh /home/moja/remote-terminal-client/deamon/deamon.sh"
hostName="terminal.moja.studio"
port=3000

#设置开机启动pm2
autoStart="sudo runuser -l moja -c '$pm2Path start $appPath --log-type json --merge-logs --log-date-format=\"YYYY-MM-DD HH:mm:ss Z\" -o $logPath/stdout.json -e $logPath/stderr.json'"
if [ ! -f "/etc/rc.local" ]; then
  touch /etc/rc.local
fi
chmod 755 /etc/rc.local
sed -i '/exit 0/d' /etc/rc.local
sed -i '/--log-type json --merge-logs --log-date-format=\"YYYY-MM-DD HH:mm:ss Z\"/d' /etc/rc.local
echo "${autoStart}" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local
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
chmod 777 /home/moja
mkdir -p /home/moja/nodejs

cd /home/moja/
runuser -l moja -c "$pm2Path delete all"
runuser -l moja -c "$pm2Path  kill"
runuser -l moja -c "$npmPath  uninstall -g pm2"

runuser -l moja -c "rm /home/moja/.pm2 -rf"
runuser -l moja -c "rm /home/moja/nodejs -rf"

runuser -l moja -c "mkdir -p /home/moja/nodejs"

runuser -l moja -c "echo `which pm2` |  while read line
do
rm $line -rf
done
"
runuser -l moja -c "echo `which node` |  while read line
do
rm $line -rf
done
"
runuser -l moja -c "echo `which npm` |  while read line
do
rm $line -rf
done
"
wget -O /home/moja/${verName} https://nodejs.org/dist/v${VERSION}/${verName}
tar -xJf /home/moja/${verName} --no-wildcards-match-slash --anchored \
     --exclude */CHANGELOG.md --exclude */LICENSE --exclude */README.md \
     --strip 1 -C /home/moja/nodejs


sed -i '/moja/d' /home/moja/.profile

echo "export PATH=`echo $PATH |sed 's/:\/home\/moja\/nodejs\/bin\///g'`:/home/moja/nodejs/bin/" >> /home/moja/.profile
source /home/moja/.profile

wget -O $clientPath.tar.gz http://$hostName/api/remote_terminal/getterminaltar
tar -xz -f $clientPath.tar.gz

sleep 2

$npmPath install --prefix $clientPath node-pty
$npmPath install --prefix $clientPath socket.io-client@2.1.1
mv /var/tmp/`basename $0` $clientPath/bin/`basename $0`

$npmPath install pm2@latest -g

chown -R moja:moja /home/moja

runuser -l moja -c "$pm2Path start $appPath --log-type json --merge-logs --log-date-format=\"YYYY-MM-DD HH:mm:ss Z\" -o $logPath/stdout.json -e $logPath/stderr.json"
runuser -l moja -c "$pm2Path save"
runuser -l moja -c "crontab -r"
runuser -l moja -c "(echo '*/1 * * * * $deamonPath' ;crontab -u moja -l) | crontab -u moja -"
runuser -l moja -c "(echo '0 0 * * */1 $pm2Path flush;echo > $logPath/stderr.json;echo > $logPath/stdout.json;rm $logsTarPath/* -rf';crontab -u moja -l) | crontab -u moja -"
runuser -l moja -c "(echo '0 0 */1 * * if [ ! -d $logsTarPath ]; then mkdir -p  $logsTarPath; fi;tar czvfP $logsTarPath/`date +\%Y-\%m-\%d`-log.tar $logPath >>/dev/null;echo > $logPath/stdout.json;echo > $logPath/stderr.json' ;crontab -u moja -l) | crontab -u moja -"

/etc/init.d/cron restart

wget -O /home/moja/su_moja http://$hostName/getshell/su_moja.sh?type=1
#/usr/bin/expect /home/moja/su_moja
