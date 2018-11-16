#!/bin/bash
osType=`uname -s|tr '[A-Z]' '[a-z]'`
cpuUsage=""
memTotal=""
memUsed=""

if [ $osType = 'linux' ]; then
  cpuUsage=`top -b -n 1 |grep Cpu|awk NR==1|cut -d ',' -f 4|awk -F ' ' '{print $1}'|awk -F '%' '{print $1}'`;
  r1=$?
  memTotal=`free | awk 'NR==2{print $2}'`
  r2=$?
  memFree=`free | awk 'NR==2{print $4}'`
  r3=$?
  rest=`free|grep 'buff/cache'`
  if [ -z "$rest" ] ; then
    memBuff=`free|awk 'NR==2{print $6}'`
    memCach=`free | awk 'NR==2{print $7}'`
    memUnused=`expr $memFree + $memBuff + $memCach`
    memUsed=`expr $memTotal - $memUnused`
  else
    memBuffCach=`free | awk 'NR==2{print $6}'`
    memUnused=`expr $memFree + $memBuffCach`
    memUsed=`expr $memTotal - $memUnused`
  fi
  currentTimeStamp=`date "+%s%N"`
fi

if [ $osType = 'darwin' ]; then
  cpuUsage=`top -l 1|awk 'NR==4{print $3}'|awk -F '%' '{print $1}'`;
  r1=$?
  memTotal=`top -l 1|awk '/PhysMem/{print $2}'|awk -F 'M' '{print $1}'`
  r2=$?
  memUsed=`top -l 1|awk '/PhysMem/{print $6}'|awk -F 'M' '{print $1}'`
  r3=$?
 # cpuUsage=${cpuUsage%?}
  currentTimeStamp=`python -c 'import time; print(int(time.time()*1000*1000*1000))'`
fi

memUsage=`awk 'BEGIN{printf "%.2f\n",'$memUsed'/'$memTotal'}'`
diskUsage=`df -k|awk 'NR==2{print $5}'|awk -F '%' '{print $1}'`
r4=$?
if [ $r1=$r2=$r3=$r4=0 ] ;then
  echo "{\"code\":\"0\",\"cpuUsage\":\"$cpuUsage\",\"memUsage\":\"$memUsage\",\"diskUsage\":\"$diskUsage\",\"time\":\"$currentTimeStamp\"}"
else
  echo "{\"code\":\"1\"}"
fi


