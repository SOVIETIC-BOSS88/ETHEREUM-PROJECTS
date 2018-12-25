
var express = require('express');
var path = require('path');
var app = express();
var api = require('./api');


app.set('port', 3001);

app.use(express.static(path.join(__dirname, '../public')));
app.use("/contracts", express.static(path.join(__dirname, '../../build/contracts')));

app.use(function(req, res, next) {
	res.header("Access-Control-Allow-Origin", "*");
	res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization");
	res.header("Access-Control-Allow-Methods", "POST, GET, OPTIONS, HEAD, DELETE, PUT, TRACE");
	next();
});

var server = app.listen(app.get('port'), function () {
  console.log('The server is running on http://localhost:' + app.get('port'));
});

app.use('/api', api);
