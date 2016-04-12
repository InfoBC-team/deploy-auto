var express = require('express');
var bodyParser = require('body-parser');
var sys = require('sys');
var exec = require('child_process').exec;
var app = express();
var jsonParser = bodyParser.json();
var fs = require('fs');

//deploy 
app.post('/deploy', jsonParser, function (req, res) {

  var branch = req.body.ref.substring(11);

  function puts(error, stdout, stderr) { 
    sys.puts(stdout)
  }
  if (branch == 'testing' || branch == 'production'){
    console.log('Starting deploy to '+ branch +' - date '+new Date());
    exec("cd /home/voyhoy && sh deployAWS.sh " + branch, puts);
    res.send('Starting deploy to '+ branch +' (voyhoy) - date '+new Date());
  }else {
    res.send('No changes found (voyhoy)');
  }

});

//deploy to pivotal
app.get('/deploy-piv/:branch', function(req, res){

  var branch = req.params.branch;
  if (branch == "branch" || branch == "") {
    console.log('wrong branch');
    res.send('wrong branch');
  } else{
    function puts(error, stdout, stderr) { 
      sys.puts(stdout)
    }
    console.log('Iniciando el deploy a pivotal de la rama '+ branch +' - '+new Date());
    exec("cd /home/voyhoy && sh deployPIV.sh "+branch, puts);
    res.send('Processing deploy');
  };

});

//deploy manual 
app.get('/deploy/:branch', function(req, res){

  var branch = req.params.branch;
  if (branch == "branch" || branch == "") {
    console.log('wrong branch');
    res.send('wrong branch');
  } else{
    function puts(error, stdout, stderr) { 
      sys.puts(stdout)
    }
    console.log('Starting deploy manual - branch '+ branch +' - date '+new Date());
    exec("cd /home/voyhoy && sh deployManualAWS.sh "+branch, puts);
    res.send('Processing deploy');
  };

});

//Logs
app.get('/logs/:limit', function(req, res){

  fs.readFile('/home/voyhoy/.pm2/logs/serverVoyhoy-out-0.log', 'utf-8', function(err, data) {
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

//full deploy auto git - voyhoy admin
app.post('/deploy-admin/', jsonParser, function (req, res) {

  var branch = req.body.ref.substring(11);
  var repository = req.body.repository.name;
  
  function puts(error, stdout, stderr) { 
    sys.puts(stdout)
  }
  console.log('Starting auto deploy - branch '+branch+' - repository '+repository+' - date '+new Date());
  if (branch == 'sandbox' || branch == 'production'){
    exec("cd /home/voyhoy && sh deployAdmin.sh full "+branch+" "+repository, puts);
    res.send('Deploy completed');
  }else {
    res.send('No changes found, wrong branch');
    console.log('No changes found, wrong branch');
  }

});

var server = app.listen(5000, function () {
  console.log("Servidor Node Js corriendo....");
});
