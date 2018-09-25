# moja_shell
一，deamon
   1，deamon.sh pm2进程守护脚本 功能：每隔1分钟检测一次客户端代码进程，如果进程不存在就通过pm2 启动
二，handleLog
    1，clearLog.sh 日志清除脚本 功能：每隔一周清除一次 维持7天以内到日志文件数量
    2，tarlog.sh  日志打包脚本 功能：每天打包一次日志

三，setup.sh 客户端安装脚本 功能： 1，安装nodejs 2, 安装pm2 3，客户端依赖包安装 3，pm2 守护进程任务 日志打包清除任务挂载 ，4开机自启动任务添加 
