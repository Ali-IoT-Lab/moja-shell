const fs = require("fs");
const os = require("os");
const p = require("path");
const child_process = require("child_process");
var HOME="";
var pm2Path="";
var envrun = "";
var fileDirectory = "";
var logPath="/var/tmp/client-logs";

if(os.platform() == 'linux') {
  HOME='home'
}
if(os.platform() == 'darwin'){
  HOME='Users'
}

if(fs.existsSync(p.join('/',HOME,'moja','.moja','install-mode'))){ //curl安装方式判断
 fileDirectory = `/${HOME}/moja/.moja/client`;
 pm2Path=`/${HOME}/moja/.moja/nodejs/bin/pm2`;
 envrun = `sudo -u moja env PATH=$PATH:/${HOME}/moja/.moja/nodejs/bin`;
}else if(fs.existsSync(p.join(os.homedir(),'.moja','install-mode'))){ //npm安装方式判断
 fileDirectory = `${os.homedir()}/.moja/client`;
}else {
  process.exit(0);
}

var versionArray=[];
var versionCompare = function (currVer, promoteVer) {
  currVer = currVer || "0.0.0";
  promoteVer = promoteVer || "0.0.0";
  if (currVer == promoteVer) return false;
  var currVerArr = currVer.split(".");
  var promoteVerArr = promoteVer.split(".");
  var len = Math.max(currVerArr.length, promoteVerArr.length);
  for (var i = 0; i < len; i++) {
    var proVal = ~~promoteVerArr[i],
      curVal = ~~currVerArr[i];
    if (proVal < curVal) {
      return false;
    } else if (proVal > curVal) {
      return true;
    }
  }
  return false;
};
fs.readdir(fileDirectory, function (err, files) {
  files.forEach(function(currentValue, index, arr){
    if(currentValue.indexOf('remote-terminal-client-v') > -1 && currentValue.indexOf('.tar.gz') == -1) {
      versionArray.push(currentValue.split('-v')[1]);
    }
  });
  var lastVersion = process.argv[2]||versionArray.sort(versionCompare)[0];
  var appPath=`/${HOME}/moja/.moja/client/remote-terminal-client-v${lastVersion}/app.js`;
  var startParam = `--log-type json --merge-logs --log-date-format="YYYY-MM-DD HH:mm:ss Z" -o ${logPath}/out.log -e ${logPath}/err.log --name client-v${lastVersion}`;
  if(process.argv[3] == 'npm') { //判断是否为npm安装方式
    var appPath=`${os.homedir()}/.moja/client/remote-terminal-client-v${lastVersion}/app.js`;
    var cmd = `${os.homedir()}/.moja/client/remote-terminal-client-v${lastVersion}/node_modules/pm2/bin/pm2 start ${appPath} ${startParam}`
  }else {
    if(process.env.USER == 'moja') {
      var cmd = `pm2 start ${appPath} ${startParam}`
    }else {
      var cmd = `${envrun} ${pm2Path} start ${appPath} ${startParam}`
    }
  }
  var startApp = child_process.exec(cmd, { maxBuffer : 10000 * 1024 });
  var uout = "", uerr = "";
  startApp.stdout.on("data", (trunk) => {
    uout += trunk;
  });
  startApp.stderr.on("data", (trunk) => {
    uerr += trunk;
  });
  startApp.on("error", (error) => {
    console.error(`[(${new Date()})  start client-v${lastVersion}] exec start command with error: ${error}`);
  });
  startApp.on("exit", (code, signal) => {
    console.log(`[ + (${new Date()}) start client-v${lastVersion}] exit start application with code: ${code} ,stdout: ${uout} ,stderr: ${uerr}`);
  });
})