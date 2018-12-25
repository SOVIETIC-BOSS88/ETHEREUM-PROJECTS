pragma solidity ^0.4.21;

import './ERC721.sol';
//CryptoTokens.sol Created By Suren Harutyunyan


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

contract CryptoTokens is ERC721 {

    //This overlays SafeMath on top of the uint256 datatype
    using SafeMath for uint256;


    /*** STORAGE ***/
    address owner;

    bytes32 public standard = 'CryptoTokens';
    bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    uint256 public totalSupply;

    bool public allTokensAssigned = false;

    uint256 public nextTokenIdToAssign;
    uint256 public hypeKillsTokensRemainingToAssign;
    uint256[] public tokenIndexArray ;

    // This is a mapping from token IDs to the address that owns them. All tokens have
    //  some valid owner address.
    //mapping (address => uint256  public addressTo_tokenId;
    mapping (uint256 => address) public tokenIdToOwner;

    // This is a mapping from token ID to index of the owned tokens list
    mapping(uint256 => uint256) public ownedTokensIndexMapping;

    //This is a mapping of the tokens owned by the address, using an array to
    // keep track of the different tokens that a user owns
    mapping(address => mapping(uint256 => uint256)) private addressToTokenIdByIndex;

    /* This creates an array with all the balances */
    // This is a mapping from owner address to the total count of tokens that the address owns.
    //  This will be used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint256)  public balanceOfAddress;

    // This is a mapping from token IDs to an address that has been approved to call
    // transferFrom(). Each token can only have one approved address for transfer
    // at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public tokenIdToApproved;

    //This is a mapping from a tokenId to a URL that may contain MetaData about the NFT
    //associated with the token
    mapping(uint256 => string) tokenIdToURL;


    /*** EVENTS ***/
    event Assign(address indexed to, uint256 _tokenId);

    //ERC721 events
    event Approval(address indexed owner, address indexed approved, uint256 indexed _tokenId);
    event Transfer(address indexed from, address indexed to, uint256 indexed _tokenId);


    /*** MODIFIERS ***/

    // This means that if the owner calls this function, the function is executed
    //and otherwise, an exception is thrown.
    modifier onlyOwnerOfContract {
        require(msg.sender == owner);
        _;
    }

    //This modifier is used to check if the message sender owns the token
    modifier onlyOwnerOfToken (uint256 _tokenId) {
        require(ownerOf(_tokenId) == msg.sender);
        _;
    }

    //This modifier is set to check for approval
     modifier  approvedAddress(address _claimant, uint256 _tokenId) {
        require(_approvedFor(msg.sender, _tokenId));
        _;
    }

    //This is to make sure that not all the tokens are assigned
    modifier notAllTokensAssigned {
        require(allTokensAssigned == false);
        _;
    }

    //This is to put a ceiling of 10K tokens while minting the initial supply
    modifier tenKLimit (uint256 _tokenId) {
        require(_tokenId <= 10000);
        _;
    }

    //This is to make sure that we still have a positive number of tokens remaining to assign
    modifier  tokensRemainingToAssign{
        require(hypeKillsTokensRemainingToAssign != 0 && hypeKillsTokensRemainingToAssign > 0);
        _;
    }

    //This is to make sure that the message sender is not sending the token to himself
    modifier notSelfSend (address _to, uint256 _tokenId) {
        require(ownerOf(_tokenId) != _to);
        _;
    }

    //This is to make sure that the owner is not a 0x0 address.
    //Safety checks to prevent against an unexpected 0x0 default.
    modifier notZeroAddressOwner (uint256 _tokenId) {
        require(ownerOf(_tokenId) != 0x0);
        _;
    }

    //This is to make sure that the address we are sending to is not a 0x0 address.
    //Safety checks to prevent against an unexpected 0x0 default.
    modifier notZeroAddressRecipient (address _to) {
        require(_to != 0x0);
        _;
    }

    //This is to make sure that the we mint a token that is not assigned to an address.
    modifier yesZeroAddressOwner (uint256 _tokenId) {
        require(ownerOf(_tokenId) == 0x0);
        _;
    }


    //This is to make sure that the  message sender is in fact the owner (_owns return bool)
    // You can only send your own tokens. Facepalm.
    modifier isOwner (address _claimant, uint256 _tokenId) {
        require(_owns(msg.sender, _tokenId));
        _;
    }


    /*** FUNCTIONS ***/

    /* Initializes contract with initial supply tokens, name, symbol */
    function CryptoTokens() public {
        //uint256 initialSupply;
        //balanceOfAddress[msg.sender] = initialSupply;    // Give the creator all initial tokens
        owner = msg.sender;
        totalSupply = 10000;                         // Update total supply
        hypeKillsTokensRemainingToAssign = totalSupply;
        nextTokenIdToAssign = 1;
        name = "HypeKillsTokens";                   // Set the name for display purposes
        symbol = "HKT";                                // Set the symbol for display purposes
        decimals = 0;                                // Amount of decimals for display purposes
    }

    //Fallback function in case someone send ETH to contract address
    function() public payable {}

    /* Function to recover the funds on the contract and kill it */
    function kill() public onlyOwnerOfContract {
        selfdestruct(owner);
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
        return balanceOfAddress[_owner];
    }

    //This returns the index of a token
    function ownedTokensIndex(uint256 _tokenId) private view returns (uint256 _index) {
        return ownedTokensIndexMapping[_tokenId];
    }


    //This returns the listed tokenId owned by an address. The tokens are listed in an array,
    //and by passing the address, and the index we can retrieve the tokenId
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public constant returns (uint _tokenId) {
        return addressToTokenIdByIndex[_owner][_index];
    }


    // This returns the address currently assigned ownership of a given token.
    // Required for ERC-721 compliance.
    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        require(owner != address(0x0));
        _owner = tokenIdToOwner[_tokenId];
    }


    // This is checking if a given address is the current owner of a particular token.
    // _claimant the address we are validating against.
    // _tokenId id, only valid when > 0
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return tokenIdToOwner[_tokenId] == _claimant;
    }


    // This is checking if a given address currently has transferApproval for a particular token.
    // _claimant the address we are confirming token is approved for.
    // _tokenId token id, only valid when > 0
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return tokenIdToApproved[_tokenId] == _claimant;
    }

    // This marks an address as being approved for transferFrom(). Overwriting any previous
    // approval. Setting _approved to address(0) clears all transfer approval.
    // _approve() and transferFrom() are used only for the auctions, so no need in approve event
    // Required for ERC-721 compliance.
    function _approve(uint256 _tokenId, address _approved) internal {
        tokenIdToApproved[_tokenId] = _approved;
    }

    // This is granting another address the right to transfer a specific token via
    // transferFrom(). This is the preferred flow for transfering NFTs to contracts.
    // _to The address to be granted transfer approval. Pass address(0) to clear all approvals.
    // _tokenId The ID of the token that can be transferred if this call succeeds.
    // Required for ERC-721 compliance.
    function approve(address _to, uint256 _tokenId) public onlyOwnerOfToken (_tokenId) {
        // Register the approval (replacing any previous approval).
        _approve(_tokenId, _to);

        // Emit approval event.
        emit Approval(msg.sender, _to, _tokenId);
    }

    //This assigns ownership of a specific token to an address.
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        balanceOfAddress[_to] = balanceOfAddress[_to].add(1);
        // transfer ownership
        tokenIdToOwner[_tokenId] = _to;

        // When creating new tokens _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            balanceOfAddress[_from] = balanceOfAddress[_from].sub(1);
        }

        // Emit the transfer event.
        emit Transfer(_from, _to, _tokenId);
    }

    // This transfers a token to another address.
    // _to The address of the recipient, can be a user or contract.
    // _tokenId The ID of the token to transfer.
    // Required for ERC-721 compliance.
    function transfer(address _to, uint256 _tokenId) public
    notAllTokensAssigned
    onlyOwnerOfToken (_tokenId)
    isOwner (msg.sender, _tokenId)
    tenKLimit (_tokenId)
    notZeroAddressRecipient (_to) {

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transfer(msg.sender, _to, _tokenId);
    }

    // This transfers a token owned by another address, for which the calling address
    // has previously been granted transfer approval by the owner.
    // _from The address that owns the token to be transfered.
    // _to The address that should take ownership of the token. Can be any address, including the caller.
    // _tokenId The ID of the token to be transferred.
    // Required for ERC-721 compliance.
    function transferFrom(address _from, address _to, uint256 _tokenId) public
    notAllTokensAssigned
    isOwner (msg.sender, _tokenId)
    tenKLimit (_tokenId)
    approvedAddress(msg.sender, _tokenId)
    notZeroAddressRecipient (_to) {

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transfer(_from, _to, _tokenId);
    }

    //This function sets the initial owner of token
    function setInitialOwner(address _to, uint256 _tokenId) public
    onlyOwnerOfContract
    tokensRemainingToAssign
    tenKLimit (_tokenId)
    yesZeroAddressOwner (_tokenId)
    notSelfSend (_to, _tokenId) {

        tokenIdToOwner[_tokenId] = _to;
        balanceOfAddress[_to] = balanceOfAddress[_to].add(1);
        emit Assign(_to, _tokenId);

        tokenIndexArray.push(_tokenId);
        ownedTokensIndexMapping[_tokenId] = balanceOf(_to);
        addressToTokenIdByIndex[_to][balanceOf(_to)] = _tokenId;

        //uint256 next;
        //next = nextTokenIdToAssign;
        //nextTokenIdToAssign = nextTokenIdToAssign.add(1);
        //nextTokenFunc(next);

        nextTokenFunc();
        hypeKillsTokensRemainingToAssign = hypeKillsTokensRemainingToAssign.sub(1);
    }

    /*
    //This function determines what is the next token that should be assigned,
    //taking into account that users can get any token Id.
    function nextTokenFunc(uint256 _nextTokenIdToAssign) internal returns (uint256) {
        uint256 n = tokenIndexArray.length;
        for (uint256 i = 0; i < n; i++) {
            if (ownerOf(_nextTokenIdToAssign) != 0x0) {
                nextTokenIdToAssign = ownedTokensIndex(_nextTokenIdToAssign).add(1);
                return nextTokenIdToAssign;
            }
            else {
                if (ownerOf(_nextTokenIdToAssign) != 0x0){
                    return nextTokenIdToAssign = nextTokenIdToAssign.add(1);
                }
                else {
                    return nextTokenIdToAssign;
                }
            }
        }
    }
    */

    //This function determines what is the next token that should be assigned,
    //taking into account that users can get any token Id.
    function nextTokenFunc() public
    onlyOwnerOfContract {
        uint256 numberOfTokensAssigned = tokenIndexArray.length;
        while (ownerOf(nextTokenIdToAssign) != 0x0) {
            nextTokenIdToAssign = nextTokenIdToAssign.add(1);
            numberOfTokensAssigned = numberOfTokensAssigned.sub(1);
        }
    }


    function setInitialOwner_multipleTokens(address _to, uint256[]  _indices) public
    onlyOwnerOfContract {
        uint256 n = _indices.length;
        for (uint256 i = 0; i < n; i++) {
            setInitialOwner(_to, _indices[i]);
        }
    }

    //This function sets as owners of various tokens, various addresses, unlike the previous
    //function, that only is intended for only one address
    function setInitialOwners_multipleTokens(address[] _to, uint256[]  _indices) public
    onlyOwnerOfContract {
        uint256 n = _indices.length;
        for (uint256 i = 0; i < n; i++) {
            setInitialOwner(_to[i], _indices[i]);
        }
    }

    function allInitialOwnersAssigned() public
    onlyOwnerOfContract {
        allTokensAssigned = true;
    }


    function getToken(address _to) public
    onlyOwnerOfContract
    tokensRemainingToAssign
    notAllTokensAssigned
    notZeroAddressRecipient (_to) {

        require(ownerOf(nextTokenIdToAssign) == 0x0);
        require(nextTokenIdToAssign <= 10000);

        tokenIdToOwner[nextTokenIdToAssign] = _to;
        balanceOfAddress[_to] = balanceOfAddress[_to].add(1);
        emit Assign(_to, nextTokenIdToAssign);

        tokenIndexArray.push(nextTokenIdToAssign);
        ownedTokensIndexMapping[nextTokenIdToAssign] = balanceOf(_to);
        addressToTokenIdByIndex[_to][balanceOf(_to)] = nextTokenIdToAssign;

        nextTokenFunc();
        hypeKillsTokensRemainingToAssign = hypeKillsTokensRemainingToAssign.sub(1);
    }


    function getToken_soleOwner_multipleTokens(address _to, uint256 _tokenQuantity) public
    onlyOwnerOfContract {
        uint256 n = _tokenQuantity;
        for (uint256 i = 0; i < n; i++){
            getToken(_to);
        }
    }

    function getToken_multipleOwners_multipleTokens(address[] _to, uint256[] _tokenQuantity) public
    onlyOwnerOfContract {
        uint256 n = _to.length;
        for (uint256 i = 0; i < n; i++) {
            uint256 m = _tokenQuantity[i];
            for (uint256 j = 0; j < m; j++) {
                getToken(_to[i]);
            }
        }
    }


    function getTokenByTokenId(uint256 _tokenId) public
    onlyOwnerOfContract
    notAllTokensAssigned
    tokensRemainingToAssign
    yesZeroAddressOwner (_tokenId)
    tenKLimit (_tokenId) {

        tokenIdToOwner[_tokenId] = msg.sender;
        balanceOfAddress[msg.sender] = balanceOfAddress[msg.sender].add(1);
        emit Assign(msg.sender, _tokenId);

        tokenIndexArray.push(_tokenId);

        uint256 length = balanceOf(msg.sender);
        ownedTokensIndexMapping[nextTokenIdToAssign] = length;
        addressToTokenIdByIndex[msg.sender][length] = nextTokenIdToAssign;

        tokenIndexArray.push(_tokenId);
        ownedTokensIndexMapping[_tokenId] = balanceOf(msg.sender);
        addressToTokenIdByIndex[msg.sender][balanceOf(msg.sender)] = _tokenId;

        nextTokenFunc();
        hypeKillsTokensRemainingToAssign = hypeKillsTokensRemainingToAssign.sub(1);
    }


    function tokenMetadata(uint256 _tokenId) public constant returns (string infoUrl) {
        return tokenIdToURL[_tokenId];
    }

}
