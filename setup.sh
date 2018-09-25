
if [ `whoami` = "moja" ];then
  echo "请切换到拥有sudo权限的用户下再下载执行脚本！"
  exit 0
fi

hostName="xuyaofang.com"
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
      dscl . -create /Users/moja UniqueID 503
      dscl . -create /Users/moja PrimaryGroupID 20
      dscl . -create /Users/moja NFSHomeDirectory /Users/moja
      dscl . -passwd /Users/moja 123456
      dseditgroup -o create moja
      dscl . -append /Groups/moja GroupMembership moja
      createhomedir -c -u moja
    elif [ $osType = "linux" ] ;then
      useradd -s /bin/bash -d /$HOME_DIR/moja  -U moja -m
    else
      echo "-----------------------------------部分文件可能会被覆盖------------------------------------"
    fi
else
      echo "清空moja用户!"
       if [ $osType = "darwin" ] ;then
         HOME_DIR='Users'
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


startApp="$pm2Path start $appPath --log-type json --merge-logs --log-date-format=\"YYYY-MM-DD HH:mm:ss Z\" -o $logPath/out.log -e $logPath/err.log"

echo "----------------------------------下载nodejs安装包 ------------------------------------"

echo $startApp

wget -O /$HOME_DIR/moja/$verName.tar.xz https://nodejs.org/dist/$VERSION/$verName.tar.xz

if [ $? -ne 0 ] ; then
echo "----------------------------------nodejs安装包解压失败-------------------------------------"
exit 1
fi
cd /$HOME_DIR/moja
mkdir nodejs
tar xvJf /$HOME_DIR/moja/$verName.tar.xz --strip 1 -C /$HOME_DIR/moja/nodejs

if [ $? -ne 0 ] ; then
  echo "-------------------------------------nodejs安装包解压失败----------------------------------------"
  exit 1
fi

#PATH=$PATH:/$HOME_DIR/moja/nodejs/bin
#export PATH

rm /usr/bin/node

if [ $osType = "darwin" ]; then
  alias node=/$HOME_DIR/moja/nodejs/bin/node
else
  ln -s /$HOME_DIR/moja/nodejs/bin/node /usr/bin/node
fi


$npmPath config set loglevel=http

#$npmPath set progress=false
echo "------------------------------------------安装pm2--------------------------------------------"

$npmPath install pm2@latest -g
if [ $? -ne 0 ] ; then
echo "-----------------------------------------pm2安装失败------------------------------------------"
exit 1
fi

echo "--------------------------------------下载客户端安装包--------------------------------------"

wget -O $clientPath.tar.gz http://$hostName/api/remote-terminal/tar

if [ $? -ne 0 ] ; then
  echo "------------------------------------解压客户端安装包--------------------------------------"
  exit 1
fi

echo "-------------------------------------解压客户端安装包---------------------------------------"
cd /$HOME_DIR/moja/
tar -xvf /$HOME_DIR/moja/remote-terminal-client.tar.gz -C /$HOME_DIR/moja

if [ $? -ne 0 ] ; then
  echo "----------------------------------客户端安装包解压失败-------------------------------------"
  exit 1
fi


echo "-------------------------------------下载客户端项目依赖-------------------------------------"

cd /$HOME_DIR/moja/remote-terminal-client

$npmPath install --unsafe-perm=true --allow-root node-pty@0.7.6

if [ $? -ne 0 ] ; then
  echo "------------------------------------node-pty@0.7.6下载失败----------------------------------"
  exit 1
fi

$npmPath install socket.io-client@2.1.1
if [ $? -ne 0 ] ; then
  echo "---------------------------socket.io-client@2.1.1下载失败------------------------------"
  exit 1
fi
$npmPath install physical-cpu-count@2.0.0
if [ $? -ne 0 ] ; then
  echo "--------------------------physical-cpu-count@2.0.0下载失败----------------------------"
  exit 1
fi
$npmPath install request@2.88.0
if [ $? -ne 0 ] ; then
  echo "--------------------------------request@2.88.0下载失败 -------------------------------"
  exit 1
fi
$npmPath install nano-time@1.0.0
if [ $? -ne 0 ] ; then
    echo "------------------------------nano-time@1.0.0下载失败-------------------------------"
  exit 1
fi

if [ $osType = 'linux' ]; then
  chown -R moja:moja /$HOME_DIR/moja
fi

echo "--------------------------------------启动服务--------------------------------------"
chmod 777 /var/tmp
mkdir -p $logPath
chmod 777 $logPath

if [ $osType = 'linux' ]; then
su - moja -c "$pm2Path start $appPath --log-type json --merge-logs --log-date-format=\"YYYY-MM-DD HH:mm:ss Z\" -o $logPath/out.log -e $logPath/err.log"
fi

if [ $osType = 'darwin' ]; then
$pm2Path start $appPath --log-type json --merge-logs --log-date-format="YYYY-MM-DD HH:mm:ss Z" -o $logPath/out.log -e $logPath/err.log
fi

#echo "export PATH=`echo $PATH |sed 's/:\/home\/moja\/nodejs\/bin//g'`:/home/moja/nodejs/bin" >> /etc/bashrc
#source /etc/bashrc

if [ $? -ne 0 ] ; then
  echo "-----------------------------------------启动服务失败-------------------------------------"
  #exit 1
fi

echo "-------------------------------------添加守护进程任务---------------------------------------"

(echo '*/1 * * * * sh /\$HOME_DIR/moja/remote-terminal-client/deamon/deamon.sh' ;crontab -l) | crontab

echo "--------------------------------------添加日志管理任务--------------------------------------"

(echo '1 0 * * */1 sh /\$HOME_DIR/moja/remote-terminal-client/handleLog/clearMonitorLog.sh' ;crontab -l) | crontab
(echo '0 0 */1 * * sh /\$HOME_DIR/moja/remote-terminal-client/handleLog/tarMonitorLog.sh' ;crontab -l) | crontab

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
echo "------------------------------------------安装完成--------------------------------------------"

