

#!/usr/bin/expect -f

log_user 0
set timeout -1

spawn -noecho sudo su - moja
send "sed -i '/moja/d' /home/moja/.bashrc && echo \"export PATH=\`echo \$PATH |sed 's/:\\\/home\\\/moja\\\/nodejs\\\/bin\\\///g'\`:\$HOME/nodejs/bin/\">> /home/moja/.bashrc && source /home/moja/.bashrc && (echo \"PATH=\"\$PATH;crontab -u moja -l)|crontab\r"
interact
#expect eof
exit

