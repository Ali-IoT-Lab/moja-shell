
VERSION=v10.14.2

HOME_DIR='home'
envrun=""
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

#卸载旧版本
uninstall_old(){
  if [ $osType = "darwin" ] ;then
    if [ -d "/Users/moja/.config/nodejs" ]; then
      HOME_DIR='Users'
      mv /Users/moja/.config/terminalId.js /Users/terminalId.js
      mv /Users/moja/.config/userId.js /Users/userId.js
      kill -9 $(ps -ef|grep "/Users/moja/.pm2"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
      kill -9 $(ps -ef|grep "/Users/moja/.config/remote-terminal-client/app.js"|awk '$0 !~/grep/ {print $2}'|tr -s '\n' ' ') >/dev/null 2>&1
      dscl . delete /Groups/moja
      dscl . delete /Users/moja
      rm -r -f /Users/moja
    fi
  elif [ $osType = "linux" ] ;then
   if [ -d "/home/moja/.config/nodejs" ]; then
      HOME_DIR='home'
      mv /home/moja/.config/terminalId.js /home/terminalId.js
      mv /home/moja/.config/userId.js /home/userId.js
      ps -ef|grep -w '/home/moja/.pm2'|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
      ps -ef|grep -w '/home/moja/.config/remote-terminal-client/app.js'|grep -v grep|cut -c 9-15|xargs kill -9 >/dev/null 2>&1
      userdel -f moja
      rm -r -f /home/moja
   fi
  else
    echo "--------------------------------------不支持的系统类型---------------------------------------"
    exit 1
  fi
  crontab -u root -l | grep -v '.config' |crontab -
  rm -r -f /var/tmp/client-logs
  rm -r -f /var/tmp/client-logs-tar
}
#创建用户工作空间
create_work_user(){
  if ! id moja
  then
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
      exit 1
    fi
  else
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
}

#重复安装清除目录
clean_dir(){
  rm -r -f /$HOME_DIR/moja/nodejs
  rm -r -f /var/tmp//var/tmp/client-logs-tar
}

#环境变量初始化
init_var(){
  npmPath="/$HOME_DIR/moja/nodejs/bin/npm"
  envrun="sudo -u moja env PATH=$PATH:/$HOME_DIR/moja/nodejs/bin"
  npmopt="--userconfig=/$HOME_DIR/moja/.npmrc"
  echo "curl" > /$HOME_DIR/moja/install-mode
}

#安装设备应用
install_app(){
  #下载nodejs
  mkdir /$HOME_DIR/moja/.moja
  if [ -f "/$HOME_DIR/userId.js" ]; then
    mv /$HOME_DIR/userId.js /$HOME_DIR/moja/.moja
  fi
  if [ -f "/$HOME_DIR/terminalId.js" ]; then
    mv /$HOME_DIR/terminalId.js /$HOME_DIR/moja/.moja
  fi
  curl -o /$HOME_DIR/moja/$verName.tar.xz $hostName/api/remote-terminal/tar/$verName.tar.xz

  if [ $? -ne 0 ] ; then
    echo "-------------------------------------nodejs安装包下载失败---------------------------------------"
    exit 1
  fi
  cd /$HOME_DIR/moja
  mkdir nodejs
  #解压nodejs
  tar xvJf /$HOME_DIR/moja/$verName.tar.xz --strip 1 -C /$HOME_DIR/moja/nodejs

  if [ $? -ne 0 ] ; then
    echo "-------------------------------------nodejs安装包解压失败---------------------------------------"
    exit 1
  fi
  rm -r -f /$HOME_DIR/moja/$verName.tar.xz
  mkdir /$HOME_DIR/moja/npm-cache
  #更改文件夹所属用户
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
  #安装管理模块
  $envrun $npmPath install -g moja-terminal --unsafe-perm=true --prefix /$HOME_DIR/moja/nodejs $npmopt
  #安装pm2
  $envrun $npmPath install -g pm2 --unsafe-perm=true --prefix /$HOME_DIR/moja/nodejs $npmopt
  #设置key
  $envrun moja set-key $userKey
}
#添加定时任务列表 开机自启动任务
add_crontab_list(){
  crontab -u root -l | grep -v '.moja' |crontab -
  (echo "*/1 * * * * sh /$HOME_DIR/moja/.moja/client/deamon/deamon.sh" ;crontab -l) | crontab
  (echo "*/1 * * * * if [ -f \"/$HOME_DIR/moja/uninstall\" ]; then crontab -u root -l | grep -v \".moja\" |crontab -;rm -r -f /$HOME_DIR/moja/uninstall;fi;" ;crontab -l) | crontab
  (echo "1 0 * * */1 sh /$HOME_DIR/moja/.moja/client/handleLog/tarLog.sh" ;crontab -l) | crontab
  (echo "@reboot sh /$HOME_DIR/moja/.moja/client/deamon/deamon.sh" ;crontab -l) | crontab
}

uninstall_old
echo "--------------------------------------------创建用户---------------------------------------------"
create_work_user
echo "--------------------------------------------清除目录---------------------------------------------"
clean_dir
echo "------------------------------------------环境变量初始化------------------------------------------"
init_var
echo "------------------------------------------安装客户端应用------------------------------------------"
install_app

#修改登录名样式
echo "------------------------------------------设置登录名样式------------------------------------------"
echo "export PS1=\"\\[\\033[38;5;14m\\]\u\\[$(tput bold)\\]\\[$(tput sgr0)\\]\\[\\033[38;5;15m\\]@\\[$(tput sgr0)\\]\\[$(tput sgr0)\\]\\[\\033[38;5;165m\\]\\w\\[$(tput sgr0)\\]\\[\\033[38;5;15m\\] \\[$(tput bold)\\]\\[$(tput sgr0)\\]\\[\\033[38;5;10m\\]>\\[$(tput sgr0)\\]\\[$(tput sgr0)\\]\\[\\033[38;5;15m\\] \\[$(tput sgr0)\\]\"" >> /$HOME_DIR/moja/.bashrc
#设置nodejs环境变量
echo "----------------------------------------设置nodejs环境变量----------------------------------------"
echo "export PATH=\"`echo \"$PATH:/$HOME_DIR/moja/nodejs/bin\"`\"" >> /$HOME_DIR/moja/.bashrc
#启动应用
echo "--------------------------------------------启动应用----------------------------------------------"
$envrun moja start
echo "-------------------------------------------添加定时任务--------------------------------------------"
add_crontab_list
