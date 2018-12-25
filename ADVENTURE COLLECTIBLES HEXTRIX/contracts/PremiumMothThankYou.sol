pragma solidity ^0.4.21;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract PremiumMothThankYou is ERC721Token, Ownable {
    function MothThankYou() ERC721Token("PremiumMothThankYou", "PMOTH") public { }

    /**
    * @dev Mints a token to an address with a tokenURI.
    * @param _to address of the future owner of the token
    * @param _tokenURI token URI for the token
    * @param _etherAmount amount of ether user must provide to receive the premium token
    */
    function mintTo(address _to, uint256 _etherAmount, string _tokenURI) public payable {
        if(totalSupply() > 1000) revert();
        if(msg.value < _etherAmount) revert("Not enough Ether provided.");
        uint256 newTokenId = _getNextTokenId();
        _mint(_to, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);
    }

    /**
    * @dev calculates the next token ID based on totalSupply
    * @return uint256 for the next token ID
    */
    function _getNextTokenId() private view returns (uint256) {
        return totalSupply().add(1);
    }


}
