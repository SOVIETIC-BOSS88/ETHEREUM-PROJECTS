pragma solidity ^0.4.18;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract CryptoTestTokenOracleContract is usingOraclize {

    string public weatherConds;
    string public value = "clear";
    event LogWeatherUpdated(string weather);
    event LogNewOraclizeQuery(string description);

    function OracleContract() payable public{
        updatePrice();
    }

    function __callback(bytes32 myid, string result) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        weatherConds = result;
        
        if (keccak256(weatherConds) == keccak256(value)) {
        LogWeatherUpdated(value);
        updatePrice();
        }
        else { 
            LogWeatherUpdated(weatherConds);
           updatePrice();
           }
    }

    function updatePrice() payable  public{
        if (oraclize_getPrice("URL") > this.balance) {
            LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            oraclize_query((60*60), "URL", "json(http://api.wunderground.com/api/372544fa0648f181/conditions/q/NY/New_York.json).current_observation.icon");
        }
    }
}
