/**
 * contract.js
 * Stripe Payments. Created by Suren Harutyunyan.
 *
 * This file defines the main contact we will use for the HypeKills token.
 */

'use strict';
const config = require('../config');
const express = require('express');

const router = express.Router();
const bodyParser = require('body-parser');
router.use(bodyParser.json());
router.use(bodyParser.urlencoded({ extended: true }));

const stripe = require('stripe')(config.stripe.secretKey);
stripe.setApiVersion(config.stripe.apiVersion);

var Web3 = require('web3');
const infuraApiKey = (config.infura.infuraApiKey);

//Set a provider (HttpProvider)
if (typeof web3 !== 'undefined') {
  var web3 = new Web3(web3.currentProvider);
} else {
  // set the provider you want from Web3.providers
   var web3 = new Web3(new Web3.providers.HttpProvider('https://ropsten.infura.io/'+infuraApiKey));
}
console.log(web3.isConnected());


const EthereumTx = require('ethereumjs-tx');
var accountAddressHex = (config.metamaskAccount.metamaskAddressHex);
var accountAddressPrivateKey  = (config.metamaskAccount.metamaskAddressPrivateKey);
var privateKey = new Buffer(accountAddressPrivateKey, 'hex');

var count = web3.eth.getTransactionCount(accountAddressHex, 'pending');

var contractAddress = (config.solidityContract.contractAddress);
var contractAbiArray = (config.solidityContract.contractABI);
var contractInstance = web3.eth.contract(contractAbiArray).at(contractAddress);
var contractInstanceName = contractInstance.name;
var contractInstanceERC721  = contractInstance.implementsERC721;

const testSendAccount= "0xe41c9b37918bb35e7b71a29b6b91fc6a9dad69a5";

const gasPrice = web3.eth.gasPrice;
const gasPriceHex = web3.toHex(gasPrice);
const gasLimitHex = web3.toHex(3000000);
//const tokenTransferAmount = 1;

//myLoop();
/*
(function sendTokenLoop (i) {
  setTimeout(function () {
    var rawTransaction = {
    "from": accountAddressHex,
    "nonce": web3.toHex(count++),
    "gasPrice": gasPriceHex,
    "gasLimit": gasLimitHex,
    "to": contractAddress,
    "value": "0x0",
    "data": contractInstance.setInitialOwner.getData(testSendAccount, contractInstance.nextTokenIdToAssign().toNumber(), {from: accountAddressHex}),            "chainId": 0x03 //Ropsten id is 3, replace with 1 for main
    };
    var tx = new EthereumTx(rawTransaction);
    tx.sign(privateKey);
    var serializedTx = tx.serialize();
    web3.eth.sendRawTransaction('0x' + serializedTx.toString('hex'), function(err, hash) {
      if (!err) { console.log('contract creation tx: ' + hash); }
      else {console.log(err); return;}          //  your code here
    });
    if (i--) sendTokenLoop(i);      //  decrement i and call myLoop again if i > 0
  }, 60000)
})(2);
*/

//Here we send the tokens using the setInitialOwner function of the contract. We pass an address and
//the contract internal value nextTokenIdToAssign to the function, which will set the owner of the token.
//The quantityOfTokens variable we pass to the sendTokenLoop function is the number of times, we will
//have to loop to send the tokens.
function sendTokenLoop (quantityOfTokens) {           //  create a loop function
  var index = 0;
  setTimeout(function () {    //  call a 60s setTimeout when the loop is called

    var rawTransaction = {
     "from": accountAddressHex,
     "nonce": web3.toHex(count++),
     "gasPrice": gasPriceHex,
     "gasLimit": gasLimitHex,
     "to": contractAddress,
     "value": "0x0",
     "data": contractInstance.setInitialOwner.getData(testSendAccount, contractInstance.nextTokenIdToAssign().toNumber(), {from: accountAddressHex}),
     "chainId": 0x03 //Ropsten id is 3, replace with 1 for main
    };

    var tx = new EthereumTx(rawTransaction);
    tx.sign(privateKey);
    var serializedTx = tx.serialize();
    web3.eth.sendRawTransaction('0x' + serializedTx.toString('hex'), function(err, hash) {
      if (!err) {
        console.log('contract creation tx: ' + hash);
        /*
        web3.eth.getTransactionReceipt(hash, function (err, res) {
          if (!err) {
            if (res.status == '0x1') { sendTokenLoop(quantityOfTokens); }
            else { console.log(err); return; }
          }
          else{ console.log(err); return; }
        });
        */
      }
      else { console.log(err); return; }
    });                               //  Here we have our code to be looped
    quantityOfTokens--;                     // We decrement the counter
    if (quantityOfTokens > index) {      //  if the quantity > index, call the loop function
      sendTokenLoop();             //  ..  again which will trigger another
    }                        //  ..  setTimeout()

  }, 60000)
}

//Here we send the tokens with the getToken_soleOwner_multipleTokens funciton of the contracts
//to which we pass an address and quantity. The quantity will determine the number of times the contracts
//will have to loop to send the tokens.
function getTokenLoop (quantityOfTokens) {           //  create a loop function
  var index = 0;
  setTimeout(function () {    //  call a 60s setTimeout when the loop is called

    var rawTransaction = {
     "from": accountAddressHex,
     "nonce": web3.toHex(count++),
     "gasPrice": gasPriceHex,
     "gasLimit": gasLimitHex,
     "to": contractAddress,
     "value": "0x0",
     "data": contractInstance.getToken_soleOwner_multipleTokens.getData(testSendAccount, quantityOfTokens, {from: accountAddressHex}),
     "chainId": 0x03 //Ropsten id is 3, replace with 1 for main
    };

    var tx = new EthereumTx(rawTransaction);
    tx.sign(privateKey);
    var serializedTx = tx.serialize();
    web3.eth.sendRawTransaction('0x' + serializedTx.toString('hex'), function(err, hash) {
      if (!err) {
        console.log('contract creation tx: ' + hash);
        /*
        web3.eth.getTransactionReceipt(hash, function (err, res) {
          if (!err) {
            if (res.status == '0x1') { sendTokenLoop(quantityOfTokens); }
            else { console.log(err); return; }
          }
          else{ console.log(err); return; }
        });
        */
      }
      else { console.log(err); return; }
    });
  }, 60000)
}


// Render the main app HTML.
router.get('/', (req, res) => {
  res.render('index.html');
});

// Post the user inputted receipt number and address
router.post('/tokens', async (req, res, next) => {
  var inputReceiptNumber, metamaskAddress;
  try {
    //Here we get the 2 user inputted values
    inputReceiptNumber = await req.body.inputReceiptNumber;
    metamaskAddress = await req.body.metamaskAddress

    //Here we will store our entire list of charges
    var chargeDetails = [];
    var hasMore = true;
    var lastCharge;
    var index = 0;
    while(hasMore) {
      //console.log("Fetching a page after charge id '" + lastCharge + "'");
      var page = await stripe.charges.list({ limit: 100, starting_after: lastCharge});
      page.data.forEach(function(charge) {
        chargeDetails.push({id: charge.id, amount: charge.amount, description: charge.description, receiptNumber: charge.receipt_number});
        lastCharge = charge.id;
      });
      hasMore = page.has_more;
      console.log("Already got " + chargeDetails.length + " charges in this account...");
    }
    console.log("Done with listing all charges");


    //THIS ENTRY IS FOR TEST PURPOSES ONLY --- CHANGE REQUIRED --- ELIMINATION
    var entry2 = "1972-8931";

    //PLACEHOLDER RECEIVER ADDRESS FOR TEST PURPOSES ONLY --- CHANGE REQUIRED -- ELIMINATION
    var sampleAddress = "0xe41c9b37918bb35e7b71a29b6b91fc6a9dad69a5";


    var descriptionUpdate = "Tokens sent";
    var chargeDetailsLength = chargeDetails.length;

    for (var i = chargeDetailsLength; i--;) {
      if (chargeDetails[i].receiptNumber === entry2 &&
      chargeDetails[i].description !== descriptionUpdate &&
      web3.isAddress(sampleAddress) === true) {

        //THIS PRICE IS FOR TEST PURPOSES ONLY --- CHANGE REQUIRED --- MODIFICATION
        var price = 1000; // Stripe works with base 100, so 100 is 1 dollar/euro.

        //We also save the exact amount the customer paid with the valid receipt number paid.
        var amountPaid = chargeDetails[i].amount;

        //Here we get the quantity of tokens the customer bought and send them.
        var quantity = amountPaid/price;
        getTokenLoop(quantity);

        var chargeId = chargeDetails[i].id;
        stripe.charges.update(chargeId,
        {
          description: descriptionUpdate
        }, function(err, charge) {
          if(!err) { console.log(charge.description); }
          else { console.log(err); return; }
        });
        return;
      }
      else { console.log('Not found'); }
    }


  } catch (err) {
    res.send("error");
  }
});

module.exports = router;
//module.exports.sendTokenLoop = sendTokenLoop;
