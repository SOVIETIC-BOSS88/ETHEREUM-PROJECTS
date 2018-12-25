var stripe = require("stripe")("sk_test_BQokikJOvBiI2HlWgH4olfQ2");



var express = require('express');
var bodyParser = require('body-parser');
var app     = express();


app.post('/app.js', function(req, res) {
  res.send('You sent the name "' + req.body.name + '".');
});

app.listen(8080, function() {
  console.log('Server running at http://127.0.0.1:8080/');
});

// Token is created using Checkout or Elements!
// Get the payment token ID submitted by the form:
var token = request.body.stripeToken; // Using Express

// Charge the user's card:
stripe.charges.create({
  amount: 999,
  currency: "usd",
  description: "Example charge",
  source: token,
}, function(err, charge) {
  // asynchronously called
  if(!err){
    console.log(charge)
  }
  console.log(err)
});
