var contract = null;
var abi = null;
var contractAddress = "0xde48ce5d990293d22dc7da091e8aa8728f3203a2"; //contract address on main net
var account = null;


function init() {

    // Is there is an injected web3 instance?
    if (typeof web3 !== 'undefined') {
        web3 = new Web3(web3.currentProvider);
        console.log("Injected web3 instance");
    } else {
      // If no injected web3 instance is detected, fallback to Ganache.
      var web3Provider = new web3.providers.HttpProvider('http://127.0.0.1:7545');
      web3 = new Web3(web3Provider);

      //Here we create the link to download MetaMask if not MetaMask is undetected
      var metamaskURL = "https://chrome.google.com/webstore/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn";
      var metamaskLink = "<a style='text-decoration: none; border-bottom: 1px solid #8bacb9; color: #8bacb9;' target= '_blank' href=' " + metamaskURL + " ' >Chrome Web Store</a> ";

      // Update the note about metamask
      var metamaskElement = document.getElementById('metamask');
      var metamaskNoMetamaskElement = document.getElementById('metamask').getElementsByClassName("status noMetamask")[0];
      metamaskNoMetamaskElement.querySelector('.note').innerHTML =
      'To download Metamask, head to the ' + metamaskLink +
      '. Once downloaded create an account and store the seed phrase. After, you can retrieve your token.';

      document.getElementById('getTokenButton').style.visibility='hidden';
      metamaskElement.style.visibility = 'visible';
      metamaskElement.style.opacity = 1;
      metamaskNoMetamaskElement.style.display = "flex";
    }

    // Check the connection
    if(!web3.isConnected()) {
      console.error("Not connected");
    }

   loadABI().then(a => {
        contract = web3.eth.contract(abi).at(contractAddress);
        console.log("Loaded contract...");

        getTokens();
   });
}

function loadABI() {
    return new Promise(function(resolve, reject) {
        fetch("/contracts/MothThankYou.json")
        .then(r => r.json())
        .then(json => {
            abi = json.abi;
            resolve(abi);
        });
    });
}


function mint() {
    var account = web3.eth.accounts[0];

    const randomQuantity = (min, max) => {
      min = Math.ceil(min);
      max = Math.floor(max);
      return Math.floor(Math.random() * (max - min + 1)) + min;
    };
    const quantity = randomQuantity(1, 6);
    var tokenURI = "https://www.wrestlemojis.com/api/" + quantity;

    var tokenImages = ["MothforkyeahToken_Logos", "MothThumb1Token_Logos",
                       "MothforkyouToken_Logos", "MothThumb2Token_Logos",
                       "MothLetsplayToken_Logos", "MothThumb3Token_Logos"];


    this.contract.mintTo(account, tokenURI,  {from: account, gas : 250000 }, (err, result) => {

        if(result){

          //Here we create the confirmation URL and construct the links
          //var confirmationURL = "https://ropsten.etherscan.io/tx/" + result;
          var confirmationURL = "https://etherscan.io/tx/" + result;
          var confirmationLink = "<a style='text-decoration: none; border-bottom: 1px solid #8bacb9; color: #8bacb9;' target= '_blank' href=' " + confirmationURL + " ' >transaction</a> ";

          // Update the note about the token
          var confirmationElement = document.getElementById('confirmation');
          var confirmationSuccessElement = document.getElementById('confirmation').getElementsByClassName("status success")[0];
          confirmationElement.querySelector('.note').innerHTML =
          'We just sent it to your address, please look at your ' + confirmationLink + '.';

          // Here we show the consfirmation message
          confirmationElement.style.opacity = 1;
          confirmationElement.style.visibility = 'visible';
          confirmationSuccessElement.style.display = "flex";
          confirmationSuccessElement.style.width = 'auto';
          confirmationSuccessElement.style.height = 'auto';
          confirmationSuccessElement.style.margin = 'auto';
          confirmationSuccessElement.style.background = '#777f91 url(/images/sanslogos/'+tokenImages[quantity-1]+'.png) no-repeat';
          confirmationSucessElement.style.backgroundSize = '120px 140px';

        }

        else {
          //Here we show the error message
          var confirmationElement = document.getElementById('confirmation');
          var confirmationErrorElement = document.getElementById('confirmation').getElementsByClassName("status error")[0];
          console.log(confirmationErrorElement);

          confirmationElement.style.opacity = 1;
          confirmationElement.style.visibility = 'visible';
          confirmationErrorElement.style.display = "flex";
          confirmationErrorElement.style.width = 'auto';
          confirmationErrorElement.style.height = 'auto';
          confirmationErrorElement.style.margin = 'auto';
        }
        console.log(err ? err : result);

    });

    // Here we hide the button after minting the token.
    document.getElementById('getTokenButton').style.visibility='hidden';
}

function getTokens() {
    var account = web3.eth.accounts[0];

    this.contract.tokenOfOwnerByIndex.call(account, 0, (err, result) => {
        if(err) {
            console.log(err);
            return;
        }

         console.log(result.valueOf());
    });
}


window.onload = function () {
    init();
}
