#!/usr/bin/expect

log_user 0
set timeout -1
spawn -noecho sudo su moja
send "echo \"export PATH=\`echo \$PATH |sed 's/:\\\/home\\\/moja\\\/nodejs\\\/bin\\\///g'\`:\$HOME/nodejs/bin/\">> /home/moja/.bashrc && source /home/moja/.bashrc\r"
#send "echo \"export PATH=\$PATH:\$HOME/nodejs/bin/\" >> /home/moja/.bashrc\r"

#send "source /home/moja/.bashrc\r"
interact
expect eof
exit
