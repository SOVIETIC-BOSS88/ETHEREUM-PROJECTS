pragma solidity ^0.4.18;

// @dev see https://github.com/ethereum/eips/issues/721

contract ERC721 {
    function implementsERC721() public pure returns (bool);
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) public view returns (address owner);
    function approve(address _to, uint256 _tokenId) public;
    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function transfer(address _to, uint256 _tokenId) public;
    event Transfer(address indexed from, address indexed to, uint256 indexed _tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed _tokenId);

    // Optional
    //function name() public view returns (string name);
    //function symbol() public view returns (string symbol);
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public constant returns (uint _tokenId);
    function tokenMetadata(uint256 _tokenId) public constant returns (string infoUrl);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/*
    Crypto Price Contract with FiatContract.com
*/

contract FiatContract {
  function ETH(uint _id) constant returns (uint256);
  function USD(uint _id) constant returns (uint256);
  function EUR(uint _id) constant returns (uint256);
  function GBP(uint _id) constant returns (uint256);
  function updatedAt(uint _id) constant returns (uint);
}

contract CryptoTestTokens is ERC721 {

    //This uses the FiatContract to obtain price and exchange rate of ETH/USD
    FiatContract public price;
    event NewPayment(address sender, uint256 amount);

    //This overlays SafeMath on top of the uint256 datatype
    using SafeMath for uint256;


    /*** STORAGE ***/
    address owner;

    string public standard = 'CryptoTestTokens';
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 public totalSupply;

    bool public allTestTokensAssigned = false;

    uint256 public next_tokenIdToAssign;
    uint256 public testTokensRemainingToAssign;
    uint256[] public tokenIndexArray ;

    // This is a mapping from token IDs to the address that owns them. All tokens have
    //  some valid owner address.
    //mapping (address => uint256  public addressTo_tokenId;
    mapping (uint256 => address) public _tokenIdToOwner;

    // This is a mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) public _ownedTokensIndex;

    //This is a mapping of the tokens owned by the address, using an array to
    // keep track of the different tokens that a user owns
    mapping(address => mapping(uint256 => uint256)) private _addressTo_tokenId_byIndex;

    /* This creates an array with all the balances */
    // This is a mapping from owner address to the total count of tokens that the address owns.
    //  This will be used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint256)  public _balanceOf;

    // This is a mapping from token IDs to an address that has been approved to call
    // transferFrom(). Each token can only have one approved address for transfer
    // at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public _tokenIdToApproved;

    //This is a mapping from a tokenId to a URL that may contain MetaData about the NFT
    //associated with the token
    mapping(uint256 => string) _tokenIdToURL;

    /*** EVENTS ***/
    event Assign(address indexed to, uint256 _tokenId);

    //ERC721 events
    event Approval(address indexed owner, address indexed approved, uint256 indexed _tokenId);
    event Transfer(address indexed from, address indexed to, uint256 indexed _tokenId);
    //

    /*** MODIFIERS ***/



    /*** FUNCTIONS ***/

    /* Initializes contract with initial supply tokens, name, symbol */
    function CryptoTestTokens() public {
        //balanceOf[msg.sender] = initialSupply;    // Give the creator all initial tokens
        owner = msg.sender;
        totalSupply = 10000;                         // Update total supply
        testTokensRemainingToAssign = totalSupply;
        next_tokenIdToAssign = 1;
        name = "HypeKillsTokensTest";                   // Set the name for display purposes
        symbol = "HK2T";                                // Set the symbol for display purposes
        decimals = 0;                                // Amount of decimals for display purposes

        price = FiatContract(0x2CDe56E5c8235D6360CCbb0c57Ce248Ca9C80909); // Price using this contract
    }

    //Fallback function in case someone send ETH to contract address
    function () payable {
        getTestToken();
    }

    /* Function to recover the funds on the contract and kill it */
    function kill() public {
        if (msg.sender == owner) selfdestruct(owner);
    }

    //Function to declare the implementation of ERC721 protocol
    function implementsERC721() public pure returns (bool) {
        return true;
    }

    // This returns the total number of tokens currently in existence.
    // Required for ERC-721 compliance.
    function totalSupply() public view returns (uint256)  {
        return totalSupply;
    }

    //This returns the balance of the particular address.
    // This is required for ERC-721 compliance
    function balanceOf(address _owner) public view returns (uint256 count) {
        return _balanceOf[_owner];
    }

    //This return the index of a token
    function ownedTokensIndex(uint256 _tokenId) private returns (uint256 _index) {
        return _ownedTokensIndex[_tokenId];
    }


    //This the returns the listed tokenId owned by an address. The tokens are
    //listed in an array, and by passing the address, and the index we can retrieve the tokenId
    function tokenOfOwnerByIndex(address _owner, uint256 _index) constant returns (uint _tokenId){
        return _addressTo_tokenId_byIndex[_owner][_index];
    }


    // This returns the address currently assigned ownership of a given token.
    // Required for ERC-721 compliance.
    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        _owner = _tokenIdToOwner[_tokenId];
        require(owner != address(0));
    }

    // This is checking if a given address is the current owner of a particular token.
    // _claimant the address we are validating against.
    // _tokenId id, only valid when > 0
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return _tokenIdToOwner[_tokenId] == _claimant;
    }


    // This is checking if a given address currently has transferApproval for a particular token.
    // _claimant the address we are confirming token is approved for.
    // _tokenId token id, only valid when > 0
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return _tokenIdToApproved[_tokenId] == _claimant;
    }

    // This marks an address as being approved for transferFrom(). Overwriting any previous
    // approval. Setting _approved to address(0) clears all transfer approval.
    // _approve() and transferFrom() are used only for the auctions, so no need in approve event
    // Required for ERC-721 compliance.
    function _approve(uint256 _tokenId, address _approved) internal {
        _tokenIdToApproved[_tokenId] = _approved;
    }

    // This is granting another address the right to transfer a specific token via
    // transferFrom(). This is the preferred flow for transfering NFTs to contracts.
    // _to The address to be granted transfer approval. Pass address(0) to clear all approvals.
    // _tokenId The ID of the token that can be transferred if this call succeeds.
    // Required for ERC-721 compliance.
    function approve(address _to, uint256 _tokenId) public {
        // Only an owner can grant transfer approval.
        require(_owns(msg.sender, _tokenId));

        // Register the approval (replacing any previous approval).
        _approve(_tokenId, _to);

        // Emit approval event.
        Approval(msg.sender, _to, _tokenId);
    }

    //This assigns ownership of a specific token to an address.
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        _balanceOf[_to] = _balanceOf[_to].add(1);
        // transfer ownership
        _tokenIdToOwner[_tokenId] = _to;
        // When creating new tokens _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            _balanceOf[_from] = _balanceOf[_from].sub(1);
        }
        // Emit the transfer event.
        Transfer(_from, _to, _tokenId);
    }

    // This transfers a token to another address.
    // _to The address of the recipient, can be a user or contract.
    // _tokenId The ID of the token to transfer.
    // Required for ERC-721 compliance.
    function transfer(address _to, uint256 _tokenId) public {
        if (allTestTokensAssigned == true) revert();
        if (_tokenIdToOwner[_tokenId] != msg.sender) revert();
        if (_tokenId >= 10000) revert();

        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));

        // You can only send your own tokens. Facepalm.
        require(_owns(msg.sender, _tokenId));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transfer(msg.sender, _to, _tokenId);
    }

    // This transfers a token owned by another address, for which the calling address
    // has previously been granted transfer approval by the owner.
    // _from The address that owns the token to be transfered.
    // _to The address that should take ownership of the token. Can be any address, including the caller.
    // _tokenId The ID of the token to be transferred.
    // Required for ERC-721 compliance.
    function transferFrom(address _from, address _to, uint256 _tokenId) public {
        if (allTestTokensAssigned == true) revert();
        if (_tokenId >= 10000) revert();

        // Check for approval
        require(_approvedFor(msg.sender, _tokenId));

        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));

        // You can only send your own tokens. Facepalm.
        require(_owns(_from, _tokenId));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transfer(_from, _to, _tokenId);
    }


    function setInitialOwner(address _to, uint256 _tokenId) public {
        if (msg.sender != owner) revert();
        if (allTestTokensAssigned) revert();
        if (_tokenId >= 10000) revert();
        if (_tokenIdToOwner[next_tokenIdToAssign] != 0x0) revert();
        if (_tokenIdToOwner[_tokenId] == _to) revert();

        _tokenIdToOwner[_tokenId] = _to;
        _balanceOf[_to] = _balanceOf[_to].add(1);
        Assign(_to, _tokenId);

        tokenIndexArray.push(_tokenId);

        uint256 length = balanceOf(msg.sender);
        _ownedTokensIndex[_tokenId] = length;
        _addressTo_tokenId_byIndex[msg.sender][length] = _tokenId;

        testTokensRemainingToAssign = testTokensRemainingToAssign.sub(1);
    }

    //This function determines what is the next token that should be assigned,
    //taking into account that users can get any token Id.
    function nextTokenFunc(uint256 _tokenId) internal returns (uint256 newNextTokenIdToAssign) {
        uint256 n = tokenIndexArray.length;
        for (uint256 i = 0; i < n; i++) {
            if (ownerOf(_tokenId) != 0x0) {
            uint256 newIndex;
            newIndex = ownedTokensIndex(_tokenId);
            next_tokenIdToAssign = newIndex.add(1);
            }
            else {
                next_tokenIdToAssign = next_tokenIdToAssign.add(1);
            }
        }
        return next_tokenIdToAssign;
    }


    function setInitialOwner_multipleTokens(address _to, uint256[]  _indices) public {
        if (msg.sender != owner) revert();
        uint256 n = _indices.length;
        for (uint256 i = 0; i < n; i++) {
            setInitialOwner(_to, _indices[i]);
        }
    }

    //This function sets as owners of various tokens, various addresses, unlike the previous
    //function, that only is intended for an only address
    function setInitialOwners_multipleTokens(address[] _to, uint256[]  _indices) public {
        if (msg.sender != owner) revert();
        uint256 n = _indices.length;
        for (uint256 i = 0; i < n; i++) {
            setInitialOwner(_to[i], _indices[i]);
        }
    }

    function allInitialOwnersAssigned() public {
        if (msg.sender != owner) revert();
        allTestTokensAssigned = true;
    }


    // This function returns $5.00 USD in ETH wei.
    function FiveETHUSD() public constant returns (uint256) {
        // returns $0.01 ETH wei
        uint256 ethCent = price.USD(0);
        // $0.01 * 500 = $5.00
        return ethCent * 500;
    }

    //This is to return the address of the price contract
    function PriceAddress() public constant returns (address) {
        return price;
    }

    function getTestToken() public /*payable*/ returns (string) {
        /*if (msg.value < FiveETHUSD()) revert();
        if (msg.value > FiveETHUSD()) {
            uint256 changeBack = msg.value.sub(FiveETHUSD());
            msg.sender.transfer(changeBack);

        }*/

        if (allTestTokensAssigned == true) revert();
        if (testTokensRemainingToAssign == 0) revert();
        //if (_tokenIdToOwner[next_tokenIdToAssign] != 0x0) revert();
        if (next_tokenIdToAssign > 10000) revert();

        _tokenIdToOwner[next_tokenIdToAssign] = msg.sender;
        _balanceOf[msg.sender] = _balanceOf[msg.sender].add(1);
        Assign(msg.sender, next_tokenIdToAssign);

        tokenIndexArray.push(next_tokenIdToAssign);

        uint256 length = balanceOf(msg.sender);
        _ownedTokensIndex[next_tokenIdToAssign] = length;
        _addressTo_tokenId_byIndex[msg.sender][length] = next_tokenIdToAssign;

        next_tokenIdToAssign = nextTokenFunc(next_tokenIdToAssign);
        testTokensRemainingToAssign = testTokensRemainingToAssign.sub(1);

        //NewPayment(msg.sender, msg.value);
        return "You paid $5.00 USD!!!";
    }

    function getTestTokenByTokenId(uint256 _tokenId) public /*payable*/ returns (string) {
        /*if (msg.value < FiveETHUSD()) revert();
        if (msg.value > FiveETHUSD()) {
            uint256 changeBack = msg.value.sub(FiveETHUSD());
            msg.sender.transfer(changeBack);

        }*/

        if (allTestTokensAssigned == true) revert();
        if (testTokensRemainingToAssign == 0) revert();
        if (_tokenIdToOwner[next_tokenIdToAssign] != 0x0) revert();
        if (_tokenId > 10000) revert();

        _tokenIdToOwner[_tokenId] = msg.sender;
        _balanceOf[msg.sender] = _balanceOf[msg.sender].add(1);
        Assign(msg.sender, _tokenId);

        tokenIndexArray.push(_tokenId);

        uint256 length = balanceOf(msg.sender);
        _ownedTokensIndex[next_tokenIdToAssign] = length;
        _addressTo_tokenId_byIndex[msg.sender][length] = next_tokenIdToAssign;

        testTokensRemainingToAssign = testTokensRemainingToAssign.sub(1);

        //NewPayment(msg.sender, msg.value);
        return "You paid $5.00 USD!!!";
    }

    function tokenMetadata(uint256 _tokenId) public constant returns (string infoUrl) {
        return _tokenIdToURL[_tokenId];
    }

}
