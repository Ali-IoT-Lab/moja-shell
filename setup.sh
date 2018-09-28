
hostName="120.27.212.27:443"
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
    echo "--------------------------------------安装gcc---------------------------------------"
    g++ -v
    if [ $? -ne 0 ] ; then
       yum install gcc-c++ -y
    fi
  else
    echo "--------------------------------------不支持的系统类型---------------------------------------"
  fi
else
  echo "-----------------------------------------清空moja用户-----------------------------------------"
  if [ $osType = "darwin" ] ;then
     HOME_DIR='Users'
     envRun="sudo -u moja env PATH=$PATH:/Users/moja/.config/nodejs/bin"
     pm2path="/Users/moja/.config/nodejs/bin/pm2"
     envRun pm2path kill >/dev/null 2>&1
     envRun pm2path delete all >/dev/null 2>&1
     if [ -d "/$HOME_DIR/moja" ]; then
        rm -r -f /$HOME_DIR/moja/.config/nodejs
        rm -r -f /$HOME_DIR/moja/.config/remote-terminal-client*
        rm -r -f /$HOME_DIR/moja/.config/privateKey.js
        rm -r -f /$HOME_DIR/moja/.config/email.js
        rm -r -f /$HOME_DIR/moja/.config/npm-cache
        rm -r -f /$HOME_DIR/moja/.npm
        rm -r -f /$HOME_DIR/moja/.npmrc
        rm -r -f /$HOME_DIR/moja/.node-gyp
        rm -r -f /$HOME_DIR/moja/.pm2
        rm -r -f /var/tmp/client-logs
        rm -r -f /var/tmp//var/tmp/client-logs-tar
     fi
     kill -9 $(ps -ef|grep "/Users/moja/.pm2"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
     kill -9 $(ps -ef|grep "/Users/moja/.config/remote-terminal-client/app.js"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
     sed -i '' '/export PS1/d' /$HOME_DIR/moja/.bashrc
     sed -i '' '/Users\/moja/d' /$HOME_DIR/moja/.bashrc
  fi
  if [ $osType = "linux" ] ;then
     envRun="sudo -u moja env PATH=$PATH:/home/moja/.config/nodejs/bin"
     pm2path="/home/moja/.config/nodejs/bin/pm2"
     envRun pm2path kill >/dev/null 2>&1
     envRun pm2path delete all >/dev/null 2>&1
     if [ -d "/$HOME_DIR/moja" ]; then
       rm /$HOME_DIR/moja/.config/nodejs -rf
       rm /$HOME_DIR/moja/remote-terminal-client* -rf
       rm /$HOME_DIR/moja/.config/privateKey.js -rf
       rm /$HOME_DIR/moja/.config/email.js -rf
       rm /$HOME_DIR/moja/.config/npm-cache -rf
       rm /$HOME_DIR/moja/.npm -rf
       rm /$HOME_DIR/moja/.npmrc -rf
       rm /$HOME_DIR/moja/.node-gyp -rf
       rm /$HOME_DIR/moja/.pm2 -rf
       rm /var/tmp/client-logs -rf
       rm /var/tmp//var/tmp/client-logs-tar -rf
     fi
      ps -ef|grep -w '/home/moja/.pm2'|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
      ps -ef|grep -w '/home/moja/.config/remote-terminal-client/app.js'|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
      sed -i '/export PS1/d' /$HOME_DIR/moja/.bashrc
      sed -i '/home\/moja/d' /$HOME_DIR/moja/.bashrc
  fi
fi

echo "-------------------------------------------读取私钥---------------------------------------------"
mkdir /$HOME_DIR/moja/.config
touch /$HOME_DIR/moja/.config/privateKey.js
touch /$HOME_DIR/moja/.config/email.js
echo "module.exports ={privateKey:\`$privateKey\`}" > /$HOME_DIR/moja/.config/privateKey.js
echo "module.exports ={email:\`$email\`}" > /$HOME_DIR/moja/.config/email.js

if [ ! -f "/$HOME_DIR/moja/.config/terminalId.js" ]; then
  touch /$HOME_DIR/moja/.config/terminalId.js
  echo "module.exports =\"\";" > /$HOME_DIR/moja/.config/terminalId.js
fi
if [ ! -f "/$HOME_DIR/moja/.config/userId.js" ]; then
   touch /$HOME_DIR/moja/.config/userId.js
   echo "module.exports =\"\";" > /$HOME_DIR/moja/.config/userId.js
fi
chmod 777 /$HOME_DIR/moja/.config/terminalId.js
chmod 777 /$HOME_DIR/moja/.config/userId.js
echo "-----------------------------------------变量初始化---------------------------------------------"
npmPath="/$HOME_DIR/moja/.config/nodejs/bin/npm"
pm2Path="/$HOME_DIR/moja/.config/nodejs/bin/pm2"
clientPath="/$HOME_DIR/moja/.config/remote-terminal-client"
logPath="/var/tmp/client-logs"
appPath="/$HOME_DIR/moja/.config/remote-terminal-client/app.js"
deamonPath="sh /$HOME_DIR/moja/.config/remote-terminal-client/deamon/deamon.sh"
envrun="sudo -u moja env PATH=$PATH:/$HOME_DIR/moja/.config/nodejs/bin"
npmopt="--userconfig=/$HOME_DIR/moja/.npmrc"
startApp="$envrun $pm2Path start $appPath --log-type json --merge-logs --log-date-format=\"YYYY-MM-DD HH:mm:ss Z\" -o $logPath/out.log -e $logPath/err.log"

echo "----------------------------------下载nodejs安装包 ------------------------------------"
curl -o /$HOME_DIR/moja/.config/$verName.tar.xz https://$hostName/api/remote-terminal/tar/$verName.tar.xz

if [ $? -ne 0 ] ; then
  echo "----------------------------------nodejs安装包下载失败-------------------------------------"
  exit 1
fi
  echo "----------------------------------解压nodejs安装-------------------------------------"
cd /$HOME_DIR/moja/.config
mkdir nodejs
tar xvJf /$HOME_DIR/moja/.config/$verName.tar.xz --strip 1 -C /$HOME_DIR/moja/.config/nodejs
if [ $? -ne 0 ] ; then
  echo "----------------------------------nodejs安装包解压失败-------------------------------------"
  exit 1
fi

mkdir /$HOME_DIR/moja/.config/npm-cache
if [ $osType = 'linux' ]; then
  export HOME="/home/moja"
  rm /$HOME_DIR/moja/$verName.tar.xz -rf
  chown moja:moja /$HOME_DIR/moja/.config -R
  chown moja:moja /$HOME_DIR/moja/.config/nodejs -R
  chown moja:moja /$HOME_DIR/moja/.config/npm-cache -R
fi
if [ $osType = 'darwin' ]; then
  export HOME="/Users/moja"
  rm -r -f /$HOME_DIR/moja/$verName.tar.xz
  chown -R moja:moja /$HOME_DIR/moja/.config
  chown -R moja:moja /$HOME_DIR/moja/.config/nodejs
  chown -R moja:moja /$HOME_DIR/moja/.config/npm-cache
  $envrun $npmPath config set cache /$HOME_DIR/moja/.config/npm-cache $npmopt
fi
$envrun $npmPath config set registry=https://registry.cnpmjs.org $npmopt
$envrun $npmPath config set loglevel=http $npmopt
echo "------------------------------------------安装pm2--------------------------------------------"
$envrun $npmPath install pm2@latest -g --prefix /$HOME_DIR/moja/.config/nodejs/ $npmopt
if [ $? -ne 0 ] ; then
  echo "-----------------------------------------pm2安装失败------------------------------------------"
  exit 1
fi

echo "--------------------------------------下载客户端安装包--------------------------------------"

curl -o $clientPath.tar.gz https://$hostName/api/remote-terminal/tar/remote-terminal-client.tar.gz

if [ $? -ne 0 ] ; then
  echo "------------------------------------客户端安装包下载失败--------------------------------------"
  exit 1
fi

echo "-------------------------------------解压客户端安装包---------------------------------------"
cd /$HOME_DIR/moja/.config/
tar -xvf /$HOME_DIR/moja/.config/remote-terminal-client.tar.gz -C /$HOME_DIR/moja/.config
if [ $? -ne 0 ] ; then
  echo "------------------------------------客户端安装包解压失败--------------------------------------"
  exit 1
fi

chown moja:moja /$HOME_DIR/moja/.config/remote-terminal-client -R

echo "-------------------------------------下载客户端项目依赖-------------------------------------"

cd /$HOME_DIR/moja/.config/remote-terminal-client

$envrun $npmPath install --unsafe-perm=true $npmopt

echo "--------------------------------------启动服务--------------------------------------"
chmod 777 /var/tmp
mkdir -p $logPath
chmod 777 $logPath
$envrun $pm2Path start $appPath --log-type json --merge-logs --log-date-format="YYYY-MM-DD HH:mm:ss Z" -o $logPath/out.log -e $logPath/err.log

if [ $? -ne 0 ] ; then
  echo "-----------------------------------------启动服务失败-------------------------------------"
  exit 1
fi
echo "-------------------------------------添加守护进程任务---------------------------------------"
retDeamon=`crontab -l -u root|grep /$HOME_DIR/moja/.config/remote-terminal-client/deamon/deamon.sh`
if [ -z "$retDeamon" ]; then
  if [ $osType = "linux" ] ;then
    (echo '*/1 * * * * sh /home/moja/.config/remote-terminal-client/deamon/deamon.sh' ;crontab -l) | crontab
  fi
  if [ $osType = "darwin" ] ;then
    (echo '*/1 * * * * sh /Users/moja/.config/remote-terminal-client/deamon/deamon.sh' ;crontab -l) | crontab
  fi
fi
echo "--------------------------------------添加日志管理任务--------------------------------------"
retClearLog=`crontab -l -u root|grep /$HOME_DIR/moja/.config/remote-terminal-client/handleLog/clearLog.sh`
retTarLog=`crontab -l -u root|grep /$HOME_DIR/moja/.config/remote-terminal-client/handleLog/tarLog.sh`
if [ -z "$retClearLog" ]; then
  if [ $osType = "linux" ] ;then
    (echo '1 0 * * */1 sh /home/moja/.config/remote-terminal-client/handleLog/clearLog.sh' ;crontab -l) | crontab
  fi

  if [ $osType = "darwin" ] ;then
    (echo '1 0 * * */1 sh /Users/moja/.config/remote-terminal-client/handleLog/clearLog.sh' ;crontab -l) | crontab
  fi

fi
if [ -z "$retTarLog" ]; then
  if [ $osType = "linux" ] ;then
    (echo '1 0 * * */1 sh /home/moja/.config/remote-terminal-client/handleLog/tarLog.sh' ;crontab -l) | crontab
  fi
  if [ $osType = "darwin" ] ;then
    (echo '1 0 * * */1 sh /Users/moja/.config/remote-terminal-client/handleLog/tarLog.sh' ;crontab -l) | crontab
  fi
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
echo "export PATH=\"`echo \"$PATH:/$HOME_DIR/moja/.config/nodejs/bin\"`\"" >> /$HOME_DIR/moja/.bashrc
echo "------------------------------------------安装完成--------------------------------------------"

