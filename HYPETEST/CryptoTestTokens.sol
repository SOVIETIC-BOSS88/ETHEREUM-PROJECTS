pragma solidity ^0.4.18;

import './ERC721.sol'
import './FiatContract.sol'
import './SafeMath.sol'
import './CryptoTestTokenOracleContract.sol'

contract CryptoTestTokens is ERC721, FiatContract, CryptoTestTokenOracleContract {
    
    //This uses the FiatContract to obtain price and exchange rate of ETH/USD
    FiatContract public price;
    event NewPayment(address sender, uint256 amount);
    
    
    //This overlays SafeMath on top of the uint256 datatype
    using SafeMath for uint256;
    
    //This act as storage for our weather conditions
    string public weatherConds = "clear";
    string public value = "clear";
    event LogWeatherUpdated(string weather);
    event LogNewOraclizeQuery(string description);

    function OracleContract() payable public {
        updatePrice();
    }


    /*** STORAGE ***/
    address owner;

    string public standard = 'CryptoTestTokens';
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 public totalSupply;
    
    bool public allTestTokensAssigned = false;
    
    uint256 public next_tokenIdToAssign = 1;
    uint256 public testTokensRemainingToAssign = 0;
    
    // This is a mapping from token IDs to the address that owns them. All tokens have
    //  some valid owner address.
    //mapping (address => uint256  public addressTo_tokenId;
    mapping (uint256 => address) public _tokenIdToOwner;
    

    /* This creates an array with all the balances */
    // This is a mapping from owner address to the total count of tokens that the address owns.
    //  This will be used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint256)  public balanceOf;
    
    // This is a mapping from token IDs to an address that has been approved to call
    // transferFrom(). Each token can only have one approved address for transfer
    // at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public _tokenIdToApproved;
    

    /*** EVENTS ***/
    event Assign(address indexed to, uint256 _tokenId);
    
    //ERC721 events
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    //
    
    
    /*** FUNCTIONS ***/
    
    /* Initializes contract with initial supply tokens to the creator of the contract */
    function CryptoTestTokensMarket() public {
        //balanceOf[msg.sender] = initialSupply;    // Give the creator all initial tokens
        owner = msg.sender;
        totalSupply = 10000;                         // Update total supply
        testTokensRemainingToAssign = totalSupply;
        name = "CRYPTOTestTOKENS";                   // Set the name for display purposes
        symbol = "ϾST";                              // Set the symbol for display purposes
        decimals = 0;                                // Amount of decimals for display purposes
        
        price = FiatContract(0x2CDe56E5c8235D6360CCbb0c57Ce248Ca9C80909); // Price using this contract
    }
    
    /* Function to recover the funds on the contract */
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
        return balanceOf[_owner];
    }
    
    // This returns the address currently assigned ownership of a given token.
    // Required for ERC-721 compliance.
    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        _owner = _tokenIdToOwner[_tokenId];
        require(owner != address(0));
    }
    
    // This is checking if a given address is the current owner of a particular Snow.
    // _claimant the address we are validating against.
    // _tokenId id, only valid when > 0
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return _tokenIdToOwner[_tokenId] == _claimant;
    }
    
    
    // This is checking if a given address currently has transferApproval for a particular token.
    // _claimant the address we are confirming snow is approved for.
    // _tokenId snow id, only valid when > 0
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
        balanceOf[_to] == balanceOf[_to].add(_tokenId);
        // transfer ownership
        _tokenIdToOwner[_tokenId] = _to;
        // When creating new tokens _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            balanceOf[_from] == balanceOf[_from].sub(_tokenId);
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
    
    
    function setInitialOwner(address _to, uint256 _tokenId) private {
        if (msg.sender != owner) revert();
        if (allTestTokensAssigned) revert();
        if (_tokenId >= 10000) revert();
        if (_tokenIdToOwner[_tokenId] != _to) {
            if (_tokenIdToOwner[_tokenId] != 0x0) {
                balanceOf[_tokenIdToOwner[_tokenId]] == 
                balanceOf[_tokenIdToOwner[_tokenId]].sub(_tokenId);
            } else {
                next_tokenIdToAssign == next_tokenIdToAssign.add(1);
                testTokensRemainingToAssign == testTokensRemainingToAssign.sub(1);
            }
            _tokenIdToOwner[_tokenId] = _to;
            balanceOf[_to]== balanceOf[_to].add(1);
            Assign(_to, _tokenId);
        }
    }

    function setInitialOwners(address[] addresses, uint256[]  indices) private {
        if (msg.sender != owner) revert();
        uint256 n = addresses.length;
        for (uint256 i = 0; i < n; i++) {
            setInitialOwner(addresses[i], indices[i]);
            next_tokenIdToAssign == next_tokenIdToAssign.add(1);
            testTokensRemainingToAssign == testTokensRemainingToAssign.sub(1);
        }
    }

    function allInitialOwnersAssigned() public {
        if (msg.sender != owner) revert();
        allTestTokensAssigned = true;
    }
    
    
    // This function returns $1.00 USD in ETH wei.
    function FiveETHUSD() constant returns (uint256) {
        // returns $0.01 ETH wei
        uint256 ethCent = price.USD(0);
        // $0.01 * 100 = $1.00
        return ethCent * 100;
    }
    
    //This is to return the address of the price contract
    function PriceAddress() constant returns (address) {
        return price;
    }

    function getTestToken() external payable returns (string) {
        require(msg.value==FiveETHUSD());
        if (allTestTokensAssigned == true) revert();
        if (testTokensRemainingToAssign == 0) revert();
        if (_tokenIdToOwner[next_tokenIdToAssign] != 0x0) revert();
        if (next_tokenIdToAssign >= 10000) revert();
        
        LogWeatherUpdated(weatherConds);
        if (keccak256(weatherConds) != keccak256(value)) revert();
        
        _tokenIdToOwner[next_tokenIdToAssign] = msg.sender;
        balanceOf[msg.sender] == balanceOf[msg.sender].add(next_tokenIdToAssign);
        next_tokenIdToAssign == next_tokenIdToAssign.add(1);
        testTokensRemainingToAssign == testTokensRemainingToAssign.sub(1);
        Assign(msg.sender, next_tokenIdToAssign);
        NewPayment(msg.sender, msg.value);
        return "You paid $1.00 USD!!!";
    }

}
