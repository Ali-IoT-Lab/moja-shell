
VERSION=v10.14.2

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
    passwd -d moja
  else
    echo "--------------------------------------不支持的系统类型---------------------------------------"
  fi
else
  echo "-----------------------------------------清空moja用户-----------------------------------------"
  if [ $osType = "darwin" ] ;then
    HOME_DIR='Users'
    sed -i '' '/export PS1/d' /$HOME_DIR/moja/.bashrc
    sed -i '' '/Users\/moja/d' /$HOME_DIR/moja/.bashrc
  fi
  if [ $osType = "linux" ] ;then
    sed -i '/export PS1/d' /$HOME_DIR/moja/.bashrc
    sed -i '/home\/moja/d' /$HOME_DIR/moja/.bashrc
  fi
fi

rm -r -f /$HOME_DIR/moja/nodejs
rm -r -f /var/tmp//var/tmp/client-logs-tar

echo "-----------------------------------------变量初始化---------------------------------------------"
npmPath="/$HOME_DIR/moja/nodejs/bin/npm"
envrun="sudo -u moja env PATH=$PATH:/$HOME_DIR/moja/nodejs/bin"
npmopt="--userconfig=/$HOME_DIR/moja/.npmrc"
echo "curl" > /$HOME_DIR/moja/install-mode
echo "--------------------------------------下载nodejs安装包 -----------------------------------------"
curl -o /$HOME_DIR/moja/$verName.tar.xz $hostName/api/remote-terminal/tar/$verName.tar.xz

if [ $? -ne 0 ] ; then
  echo "-------------------------------------nodejs安装包下载失败---------------------------------------"
  exit 1
fi
  echo "---------------------------------------解压nodejs安装------------------------------------------"
cd /$HOME_DIR/moja
mkdir nodejs
tar xvJf /$HOME_DIR/moja/$verName.tar.xz --strip 1 -C /$HOME_DIR/moja/nodejs

if [ $? -ne 0 ] ; then
  echo "-------------------------------------nodejs安装包解压失败---------------------------------------"
  exit 1
fi
rm -r -f /$HOME_DIR/moja/$verName.tar.xz
mkdir /$HOME_DIR/moja/npm-cache
if [ $osType = 'linux' ]; then
  export HOME="/home/moja"
  rm /$HOME_DIR/moja/$verName.tar.xz -rf
  chown moja:moja /$HOME_DIR/moja -R
  chown moja:moja /$HOME_DIR/moja/nodejs -R
  chown moja:moja /$HOME_DIR/moja/npm-cache -R
fi
if [ $osType = 'darwin' ]; then
  export HOME="/Users/moja"
  rm -r -f /$HOME_DIR/moja/$verName.tar.xz
  chown -R moja:moja /$HOME_DIR/moja
  chown -R moja:moja /$HOME_DIR/moja/nodejs
  chown -R moja:moja /$HOME_DIR/moja/npm-cache
  $envrun $npmPath config set cache /$HOME_DIR/moja/npm-cache $npmopt
fi

$envrun $npmPath config set registry=https://registry.cnpmjs.org $npmopt
$envrun $npmPath config set loglevel=http $npmopt
$envrun $npmPath install -g moja-terminal --unsafe-perm=true --prefix /$HOME_DIR/moja/nodejs $npmopt
$envrun $npmPath install -g pm2 --unsafe-perm=true --prefix /$HOME_DIR/moja/nodejs $npmopt
$envrun moja set-key $userKey

crontab -u root -l | grep -v '.moja' |crontab -
(echo "*/1 * * * * sh /$HOME_DIR/moja/.moja/client/deamon/deamon.sh" ;crontab -l) | crontab
(echo "*/1 * * * * sh deamon.sh" ;crontab -l) | crontab
(echo "*/1 * * * * if [ -f \"/$HOME_DIR/moja/uninstall\" ]; then crontab -u root -l | grep -v \".moja\" |crontab -;rm -r -f /$HOME_DIR/moja/uninstall;fi;" ;crontab -l) | crontab
(echo "1 0 * * */1 sh /$HOME_DIR/moja/.moja/client/handleLog/tarLog.sh" ;crontab -l) | crontab
(echo "@reboot sh /$HOME_DIR/moja/.moja/client/deamon/deamon.sh" ;crontab -l) | crontab

echo "export PS1=\"\\[\\033[38;5;14m\\]\u\\[$(tput bold)\\]\\[$(tput sgr0)\\]\\[\\033[38;5;15m\\]@\\[$(tput sgr0)\\]\\[$(tput sgr0)\\]\\[\\033[38;5;165m\\]\\w\\[$(tput sgr0)\\]\\[\\033[38;5;15m\\] \\[$(tput bold)\\]\\[$(tput sgr0)\\]\\[\\033[38;5;10m\\]>\\[$(tput sgr0)\\]\\[$(tput sgr0)\\]\\[\\033[38;5;15m\\] \\[$(tput sgr0)\\]\"" >> /$HOME_DIR/moja/.bashrc
echo "export PATH=\"`echo \"$PATH:/$HOME_DIR/moja/nodejs/bin\"`\"" >> /$HOME_DIR/moja/.bashrc
echo "--------------------------------------------启动服务---------------------------------------------"
$envrun moja start
