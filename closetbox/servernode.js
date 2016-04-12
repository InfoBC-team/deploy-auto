var express = require('express');
var bodyParser = require('body-parser');
var sys = require('sys');
var exec = require('child_process').exec;
var app = express();
var jsonParser = bodyParser.json();
var fs = require('fs');

//listar versiones del target
app.get('/deploy/listTarget/:project', function(req, res){

  var command = 'ls -lh /home/orlando/'+req.params.project+'/target  | grep -v "^d" > listTarget.txt';

  child = exec(command,
    function (error, stdout, stderr) {
    // nodejs error
    if (error !== null) {
      console.log('exec error: ' + error);
    }
    else {
      fs.readFile('/home/orlando/listTarget.txt', 'utf-8', function(err, data) {
        if (err) throw err;
        var lines = data.trim().split('\n');
        var content = '';
        var totalLines = lines.length;
        for (var i = 0; i < lines.length; i++) {
          content = content + lines[i].replace(' ','&nbsp;') + "<br>";
          totalLines --;
        };
        res.send(content);
      });
    }
  });
});

//full deploy auto git
app.post('/deploy/', jsonParser, function (req, res) {

  var branch = req.body.ref.substring(11);
  var repository = req.body.repository.name;
  
  function puts(error, stdout, stderr) { 
    sys.puts(stdout)
  }
  console.log('Starting auto deploy ready - branch '+branch+' - repository '+repository+' - date '+new Date());
  if (branch == 'sandbox' || branch == 'production'){
    exec("cd /home/orlando && sh deploy.sh full "+branch+" "+repository, puts);
    res.send('deploy completed');
  }else {
    res.send('No changes found, wrong branch');
    console.log('No changes found, wrong branch');
  }

});

//deploy manual 
app.get('/deploy/:repository/:version/:env', function(req, res){

  var version = req.params.version;
  var repository = req.params.repository;
  var env = req.params.env;

  function puts(error, stdout, stderr) { 
    sys.puts(stdout)
  }
  console.log('Starting deploy manual - repository '+repository+' - enviroment '+env+' - version '+ version +' - date '+new Date());
  exec("cd /home/orlando && sh deploy.sh single "+repository+" "+version+" "+env, puts);
  res.send('deploy proccesing');

});

//deploy manual whith war
app.get('/deploy-war/:repository/:env', function(req, res){

  var repository = req.params.repository;
  var env = req.params.env;

  function puts(error, stdout, stderr) { 
    sys.puts(stdout)
  }
  console.log('Starting deploy manual - repository '+repository+' - enviroment '+env+ ' - date '+new Date());
  exec("cd /home/orlando && sh deploy.sh singleWar "+repository+" "+env, puts);

  var link = ''

  if(repository == 'closetbox-admin' && env == 'production'){
    link = 'https://console.run.pivotal.io/organizations/1203cf5c-d81d-424b-bbb4-b6b7d886c0ff/spaces/f9ed4882-3b06-4b56-a267-9be9b817ba14/applications/3df2bf37-66c3-4f37-bb0c-9033d51a2352/tailing_logs'
  }else if(repository == 'closetbox-admin' && env == 'sandbox'){
    link = 'https://console.run.pivotal.io/organizations/1203cf5c-d81d-424b-bbb4-b6b7d886c0ff/spaces/f9ed4882-3b06-4b56-a267-9be9b817ba14/applications/3ea0e368-2e03-435d-b2b6-2bf5c300ea45/tailing_logs'
  }else if(repository == 'closetbox-api' && env == 'production'){
    link = 'https://console.run.pivotal.io/organizations/1203cf5c-d81d-424b-bbb4-b6b7d886c0ff/spaces/f9ed4882-3b06-4b56-a267-9be9b817ba14/applications/9f067632-4aed-4b0e-b92c-5f2b4e80ce52/tailing_logs'
  }else if(repository == 'closetbox-api' && env == 'sandbox'){
    link = 'https://console.run.pivotal.io/organizations/1203cf5c-d81d-424b-bbb4-b6b7d886c0ff/spaces/f9ed4882-3b06-4b56-a267-9be9b817ba14/applications/77a1ea1f-c1a9-4fae-9eeb-4f25003681a5/tailing_logs'
  }else{
    link = '#'
  }

  res.send('Procensando el deploy.... </br> Para más detalle revisar los logs en <a target="_blank" href="'+link+'">Ir al enlace</>');

});

//Logs
app.get('/deploy/logs/:limit', function(req, res){

  fs.readFile('/home/orlando/.pm2/logs/servernode-out-0.log', 'utf-8', function(err, data) {
    if (err) throw err;

    var linesData = data.trim().split('\n');

    
    var content = '';
    var totalLines = linesData.length-req.params.limit;
    for (var i = 0; i < req.params.limit; i++) {
      content = content + linesData[totalLines] + "<br>";
      totalLines ++;
    };
    res.send(content);
  });
});

//cflogs
app.get('/deploy/cflogs/:project', function(req, res){

  var command = 'cd /home/orlando && cf logs '+req.params.project+' --recent > logsRecent.txt';

  child = exec(command,
    function (error, stdout, stderr) {
    // nodejs error
    if (error !== null) {
      console.log('exec error: ' + error);
    }
    else {
      fs.readFile('/home/orlando/logsRecent.txt', 'utf-8', function(err, data) {
        if (err) throw err;
        var lines = data.trim().split('\n');
        var content = '';
        var totalLines = lines.length;
        for (var i = 0; i < lines.length; i++) {
          content = content + lines[i] + "<br>";
          totalLines --;
        };
        res.send(content);
      });
    }
  });
});

var server = app.listen(9090, function () {

  var host = server.address().address;
  var port = server.address().port;

  console.log("Servidor Node Js corriendo....");
});
