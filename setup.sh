
hostName="terminal.mujiang.info"
VERSION=v8.12.0

HOME_DIR='home'

osType=`uname -s|tr '[A-Z]' '[a-z]'`
cpuType=`uname -m`

isX86=$( echo $cpuType | grep "x86" )
isArm=$( echo $cpuType | grep "arm" )

if [ -n "${isX86}" ] ; then
  cpuSize=$( echo $isX86 | awk -F '_' '{print $2}')
  verName=node-$VERSION-$osType-x$cpuSize
elif [  -n "${isArm}" ] ;then
  verName=node-$VERSION-$osType-$isArm
else
  echo "--------------------------------------不支持的系统类型---------------------------------------"
  exit 1
fi

if ! id moja
then
  echo "----------------------------------------创建moja用户------------------------------------------"
  if [ $osType = "darwin" ] ;then
    HOME_DIR='Users'
    dscl . -create /Users/moja
    dscl . -create /Users/moja UserShell /bin/bash
    dscl . -create /Users/moja RealName "USER NAME"
    dscl . -create /Users/moja UniqueID 1001
    dscl . -create /Users/moja PrimaryGroupID 20
    dscl . -create /Users/moja NFSHomeDirectory /Users/moja
    dscl . -passwd /Users/moja 123456
    dseditgroup -o create moja
    dscl . -append /Groups/moja GroupMembership moja
    createhomedir -c -u moja
  elif [ $osType = "linux" ] ;then
    useradd -s /bin/bash -d /$HOME_DIR/moja  -U moja -m
  else
    echo "--------------------------------------不支持的系统类型---------------------------------------"
  fi
else
  echo "-----------------------------------------清空moja用户-----------------------------------------"
  if [ $osType = "darwin" ] ;then
     HOME_DIR='Users'
     rm -r -f /$HOME_DIR/moja/nodejs
     rm -r -f /$HOME_DIR/moja/$verName.tar.gz
     rm -r -f /$HOME_DIR/moja/remote-terminal-client*
     rm -r -f /$HOME_DIR/moja/.config
     rm -r -f /var/tmp/client-logs
     rm -r -f /var/tmp//var/tmp/client-logs-tar
  fi
  if [ $osType = "linux" ] ;then
     rm /$HOME_DIR/moja/nodejs -rf
     rm /$HOME_DIR/moja/$verName.tar.gz -rf
     rm /$HOME_DIR/moja/remote-terminal-client* -rf
     rm /$HOME_DIR/moja/.config -rf
     rm /var/tmp/client-logs -rf
     rm /var/tmp//var/tmp/client-logs-tar -rf
  fi
fi
echo "-------------------------------------------读取私钥---------------------------------------------"
mkdir /$HOME_DIR/moja/.config
touch /$HOME_DIR/moja/.config/privateKey.js
touch /$HOME_DIR/moja/.config/email.js

echo "module.exports ={privateKey:\`$privateKey\`}" > /$HOME_DIR/moja/.config/privateKey.js
echo "module.exports ={email:\`$email\`}" > /$HOME_DIR/moja/.config/email.js
echo "-----------------------------------------变量初始化---------------------------------------------"
npmPath="/$HOME_DIR/moja/nodejs/bin/npm"
pm2Path="/$HOME_DIR/moja/nodejs/bin/pm2"
clientPath="/$HOME_DIR/moja/remote-terminal-client"
logPath="/var/tmp/client-logs"
appPath="/$HOME_DIR/moja/remote-terminal-client/app.js"
deamonPath="sh /$HOME_DIR/moja/remote-terminal-client/deamon/deamon.sh"
envrun="sudo -u moja env PATH=$PATH:/$HOME_DIR/moja/nodejs/bin"
startApp="$envrun $pm2Path start $appPath --log-type json --merge-logs --log-date-format=\"YYYY-MM-DD HH:mm:ss Z\" -o $logPath/out.log -e $logPath/err.log\""

echo "----------------------------------下载nodejs安装包 ------------------------------------"
wget -O /$HOME_DIR/moja/$verName.tar.xz http://$hostName/api/remote-terminal/tar/$verName.tar.xz

if [ $? -ne 0 ] ; then
  echo "----------------------------------nodejs安装包下载失败-------------------------------------"
  exit 1
fi
  echo "----------------------------------解压nodejs安装-------------------------------------"
cd /$HOME_DIR/moja
mkdir nodejs
tar xvJf /$HOME_DIR/moja/$verName.tar.xz --strip 1 -C /$HOME_DIR/moja/nodejs
if [ $? -ne 0 ] ; then
  echo "----------------------------------nodejs安装包解压失败-------------------------------------"
  exit 1
fi
chown moja:moja /$HOME_DIR/moja/nodejs -R

$envrun $npmPath config set loglevel=http

echo "------------------------------------------安装pm2--------------------------------------------"

$envrun $npmPath install pm2@latest -g
if [ $? -ne 0 ] ; then
  echo "-----------------------------------------pm2安装失败------------------------------------------"
  exit 1
fi

echo "--------------------------------------下载客户端安装包--------------------------------------"

wget -O $clientPath.tar.gz http://$hostName/api/remote-terminal/tar/remote-terminal-client.tar.gz

if [ $? -ne 0 ] ; then
  echo "------------------------------------客户端安装包下载失败--------------------------------------"
  exit 1
fi

echo "-------------------------------------解压客户端安装包---------------------------------------"
cd /$HOME_DIR/moja/
tar -xvf /$HOME_DIR/moja/remote-terminal-client.tar.gz -C /$HOME_DIR/moja
if [ $? -ne 0 ] ; then
  echo "------------------------------------客户端安装包解压失败--------------------------------------"
  exit 1
fi

chown moja:moja /$HOME_DIR/moja/remote-terminal-client -R
chmod 777 $clientPath/identify/terminalId.js
chmod 777 $clientPath/identify/userId.js

echo "-------------------------------------下载客户端项目依赖-------------------------------------"

cd /$HOME_DIR/moja/remote-terminal-client

#$npmPath install --unsafe-perm=true --allow-root node-pty@0.7.6

$envrun $npmPath install --unsafe-perm=true

echo "--------------------------------------启动服务--------------------------------------"
chmod 777 /var/tmp
mkdir -p $logPath
chmod 777 $logPath
$envrun export PS1="\[\033[38;5;14m\]\u\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;15m\]@\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;165m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;10m\]>\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"
$envrun $pm2Path start $appPath --log-type json --merge-logs --log-date-format="YYYY-MM-DD HH:mm:ss Z" -o $logPath/out.log -e $logPath/err.log

if [ $? -ne 0 ] ; then
  echo "-----------------------------------------启动服务失败-------------------------------------"
  exit 1
fi

echo "-------------------------------------添加守护进程任务---------------------------------------"
if [ $osType = "linux" ] ;then
      (echo '*/1 * * * * sh /home/moja/remote-terminal-client/deamon/deamon.sh' ;crontab -l) | crontab
fi
if [ $osType = "darwin" ] ;then
    (echo '*/1 * * * * sh /Users/moja/remote-terminal-client/deamon/deamon.sh' ;crontab -l) | crontab
fi
echo "--------------------------------------添加日志管理任务--------------------------------------"
if [ $osType = "linux" ] ;then
    (echo '1 0 * * */1 sh /home/moja/remote-terminal-client/handleLog/clearLog.sh' ;crontab -l) | crontab
    (echo '1 0 * * */1 sh /home/moja/remote-terminal-client/handleLog/tarLog.sh' ;crontab -l) | crontab
fi
if [ $osType = "darwin" ] ;then
    (echo '1 0 * * */1 sh /Users/moja/remote-terminal-client/handleLog/clearLog.sh' ;crontab -l) | crontab
    (echo '1 0 * * */1 sh /Users/moja/remote-terminal-client/handleLog/tarLog.sh' ;crontab -l) | crontab
fi
echo "------------------------------------- 添加开机自启动任务 -----------------------------------"
 if [ ! -f "/etc/rc.local" ]; then
    touch /etc/rc.local
 fi
  chmod 755 /etc/rc.local
  if [ $HOME_DIR = 'Users' ]; then
    sed -i '' '/exit 0/d' /etc/rc.local
    sed -i '' '/--log-type json --merge-logs --log-date-format=\"YYYY-MM-DD HH:mm:ss Z\"/d' /etc/rc.local
  elif [ $HOME_DIR = 'home' ]; then
    sed -i '/exit 0/d' /etc/rc.local
    sed -i '/--log-type json --merge-logs --log-date-format=\"YYYY-MM-DD HH:mm:ss Z\"/d' /etc/rc.local
  else
    echo "--------------------------------------不支持的系统类型--------------------------------------"
    exit 1
  fi
  echo "${startApp}" >> /etc/rc.local
  echo "exit 0" >> /etc/rc.local

  touch /$HOME_DIR/moja/.bashrc
  chmod 777 /$HOME_DIR/moja/.bashrc

  echo "export PS1=\"\\[\\033[38;5;14m\\]\u\\[$(tput bold)\\]\\[$(tput sgr0)\\]\\[\\033[38;5;15m\\]@\\[$(tput sgr0)\\]\\[$(tput sgr0)\\]\\[\\033[38;5;165m\\]\\w\\[$(tput sgr0)\\]\\[\\033[38;5;15m\\] \\[$(tput bold)\\]\\[$(tput sgr0)\\]\\[\\033[38;5;10m\\]>\\[$(tput sgr0)\\]\\[$(tput sgr0)\\]\\[\\033[38;5;15m\\] \\[$(tput sgr0)\\]\"" >> /$HOME_DIR/moja/.bashrc
  echo "export PATH=\"`echo \"$PATH:/$HOME_DIR/moja/nodejs/bin\"`\"" >> /$HOME_DIR/moja/.bashrc
echo "------------------------------------------安装完成--------------------------------------------"



