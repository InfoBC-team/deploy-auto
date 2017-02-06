var express = require('express');
var bodyParser = require('body-parser');
var sys = require('sys');
var exec = require('child_process').exec;
var app = express();
var jsonParser = bodyParser.json();
var fs = require('fs');

//deploy automático
app.post('/deploy', jsonParser, function (req, res) {

  var branch = req.body.ref.substring(11);

  function puts(error, stdout, stderr) { 
    sys.puts(stdout)
  }
  if (branch == 'sandbox' || branch == 'master'){
    console.log('Iniciando el deploy de la rama '+ branch +' - '+new Date());
    exec("cd /home/vheurope && sh deployVheurope.sh " + branch, puts);
    res.send('Iniciando el deploy de la rama '+ branch +' (resertrip) - '+new Date());
  }else {
    res.send('No se subió ningún cambio (no es la rama production o sandbox)');
  }

});

//deploy automático
app.post('/deploy-admin', jsonParser, function (req, res) {

  var branch = req.body.ref.substring(11);

  function puts(error, stdout, stderr) { 
    sys.puts(stdout)
  }
  if (branch == 'sandbox' || branch == 'production'){
    console.log('Iniciando el deploy de la rama '+ branch +' - '+new Date());
    exec("cd /home/vheurope && sh deployVheuropeAdmin.sh " + branch, puts);
    res.send('Iniciando el deploy de la rama '+ branch +' (resertrip) - '+new Date());
  }else {
    res.send('No se subió ningún cambio (no es la rama production o sandbox)');
  }

});

//Logs
app.get('/logs/:limit', function(req, res){

  fs.readFile('/home/vheurope/.pm2/logs/serverVheurope-out-0.log', 'utf-8', function(err, data) {
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


var server = app.listen(9999, function () {
  console.log("Servidor Node Js para vheurope corriendo....");
});
