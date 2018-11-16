const fs = require("fs");
const os = require("os");
const child_process = require("child_process");
var HOME="";
if(os.platform() == 'linux') {
  HOME='home'
}
if(os.platform() == 'darwin'){
  HOME='Users'
}
const logPath="/var/tmp/client-logs";
const fileDirectory = `/${HOME}/moja/.moja/client`;
const pm2Path=`/${HOME}/moja/.moja/nodejs/bin/pm2`;
const envrun = `sudo -u moja env PATH=$PATH:/${HOME}/moja/.moja/nodejs/bin`;

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

  if(process.env.USER == 'moja') {
    var cmd = `pm2 start ${appPath} --log-type json --merge-logs --log-date-format="YYYY-MM-DD HH:mm:ss Z" -o ${logPath}/out.log -e ${logPath}/err.log --name client-v${lastVersion}`
  }else {
    var cmd = `${envrun} ${pm2Path} start ${appPath} --log-type json --merge-logs --log-date-format="YYYY-MM-DD HH:mm:ss Z" -o ${logPath}/out.log -e ${logPath}/err.log --name client-v${lastVersion}`
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
  startApp.on("close", (code, signal) => {
    console.log(`[ + (${new Date()}) start client-v${lastVersion}] close start application with code: ${code} ,stdout: ${uout} ,stderr: ${uerr}`);
  })
})