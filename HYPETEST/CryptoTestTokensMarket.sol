pragma solidity 0.4.18;

import './CryptoTestTokens.sol'

contract CryptoTestTokensMarket is CryptoTestTokens {
    
    using SafeMath for uint256;
    
    /*** STORAGE ***/
    
    struct Offer {
        bool isForSale;
        uint256 _tokenId;
        address seller;
        uint256 minValue;       // in ether
        address onlySellTo;     // specify to sell only to a specific person
    }

    struct Bid {
        bool hasBid;
        uint256 _tokenId;
        address bidder;
        uint256 value;
    }

    // A record of testTokens that are offered for sale at a specific minimum value, and perhaps to a specific person
    mapping (uint256 => Offer) public testTokensOfferedForSale;

    // A record of the highest testToken bid
    mapping (uint256 => Bid) public testTokenBids;

    mapping (address => uint256)  public pendingWithdrawals;


    /*** EVENTS ***/
    
    event Assign(address indexed to, uint256 _tokenId);
    event TestTokenTransfer(address indexed from, address indexed to, uint256 _tokenId);
    event TestTokenOffered(uint256 indexed _tokenId, uint256 minValue, address indexed toAddress);
    event TestTokenBidEntered(uint256 indexed _tokenId, uint256 value, address indexed fromAddress);
    event TestTokenBidWithdrawn(uint256 indexed _tokenId, uint256 value, address indexed fromAddress);
    event TestTokenBought(uint256 indexed _tokenId, uint256 value, address indexed fromAddress, address indexed toAddress);
    event TestTokenNoLongerForSale(uint256 indexed _tokenId);
    
    /*** FUNCTIONS ***/

    // Transfer ownership of a testToken to another user without requiring payment
    function transferTestToken(address _to, uint256 _tokenId) public {
        if (!allTestTokensAssigned) revert();
        if (_tokenIdToOwner[_tokenId] != msg.sender) revert();
        if (_tokenId >= 10000) revert();
        if (testTokensOfferedForSale[_tokenId].isForSale) {
            testTokenNoLongerForSale(_tokenId);
        }
        _tokenIdToOwner[_tokenId] = _to;
        balanceOf[msg.sender]== balanceOf[msg.sender].sub(1);
        balanceOf[_to]== balanceOf[_to].add(1);
        Transfer(msg.sender, _to, 1);
        TestTokenTransfer(msg.sender, _to, _tokenId);
        // Check for the case where there is a bid from the new owner and refund it.
        // Any other bid can stay in place.
        Bid storage bid = testTokenBids[_tokenId];
        if (bid.bidder == _to) {
            // Kill bid and refund value
            pendingWithdrawals[_to] == pendingWithdrawals[_to].add(bid.value);
            testTokenBids[_tokenId] = Bid(false, _tokenId, 0x0, 0);
        }
    }

    function testTokenNoLongerForSale(uint256 _tokenId) public {
        if (!allTestTokensAssigned) revert();
        if (_tokenIdToOwner[_tokenId] != msg.sender) revert();
        if (_tokenId >= 10000) revert();
        testTokensOfferedForSale[_tokenId] = Offer(false, _tokenId, msg.sender, 0, 0x0);
        TestTokenNoLongerForSale(_tokenId);
    }

    function offerTestTokenForSale(uint256 _tokenId, uint256 minSalePriceInWei) public {
        if (!allTestTokensAssigned) revert();
        if (_tokenIdToOwner[_tokenId] != msg.sender) revert();
        if (_tokenId >= 10000) revert();
        testTokensOfferedForSale[_tokenId] = Offer(true, _tokenId, msg.sender, minSalePriceInWei, 0x0);
        TestTokenOffered(_tokenId, minSalePriceInWei, 0x0);
    }

    function offerTestTokenForSaleToAddress(uint256 _tokenId, uint256 minSalePriceInWei, address toAddress)
    public {
        if (!allTestTokensAssigned) revert();
        if (_tokenIdToOwner[_tokenId] != msg.sender) revert();
        if (_tokenId >= 10000) revert();
        testTokensOfferedForSale[_tokenId] = Offer(true, _tokenId, msg.sender, minSalePriceInWei, toAddress);
        TestTokenOffered(_tokenId, minSalePriceInWei, toAddress);
    }

    function buyTestToken(uint256 _tokenId) public payable {
        if (!allTestTokensAssigned) revert();
        Offer storage offer = testTokensOfferedForSale[_tokenId];
        if (_tokenId >= 10000) revert();
        if (!offer.isForSale) revert();                // testToken not actually for sale
        if (offer.onlySellTo != 0x0 && offer.onlySellTo != msg.sender) revert();  // testToken not supposed to be sold to this user
        if (msg.value < offer.minValue) revert();      // Didn't send enough ETH
        if (offer.seller != _tokenIdToOwner[_tokenId]) revert(); // Seller no longer owner of testToken

        address seller = offer.seller;

        _tokenIdToOwner[_tokenId] = msg.sender;
        balanceOf[seller]== balanceOf[seller].sub(1);
        balanceOf[msg.sender]== balanceOf[msg.sender].add(1);
        Transfer(seller, msg.sender, 1);

        testTokenNoLongerForSale(_tokenId);
        pendingWithdrawals[seller]== pendingWithdrawals[seller].add(msg.value);
        TestTokenBought(_tokenId, msg.value, seller, msg.sender);

        // Check for the case where there is a bid from the new owner and refund it.
        // Any other bid can stay in place.
        Bid storage bid = testTokenBids[_tokenId];
        if (bid.bidder == msg.sender) {
            // Kill bid and refund value
            pendingWithdrawals[msg.sender]== pendingWithdrawals[msg.sender].add(bid.value);
            testTokenBids[_tokenId] = Bid(false, _tokenId, 0x0, 0);
        }
    }

    function withdraw() public  {
        if (!allTestTokensAssigned) revert();
        uint256 amount = pendingWithdrawals[msg.sender];
        // Remember to zero the pending refund before
        // sending to prevent re-entrancy attacks
        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    function enterBidForTestToken(uint256 _tokenId) public payable {
        if (_tokenId >= 10000) revert();
        if (!allTestTokensAssigned) revert();                
        if (_tokenIdToOwner[_tokenId] == 0x0) revert();
        if (_tokenIdToOwner[_tokenId] == msg.sender) revert();
        if (msg.value == 0) revert();
        Bid storage existing = testTokenBids[_tokenId];
        if (msg.value <= existing.value) revert();
        if (existing.value > 0) {
            // Refund the failing bid
            pendingWithdrawals[existing.bidder]== pendingWithdrawals[existing.bidder].add(existing.value);
        }
        testTokenBids[_tokenId] = Bid(true, _tokenId, msg.sender, msg.value);
        TestTokenBidEntered(_tokenId, msg.value, msg.sender);
    }

    function acceptBidForTestToken(uint256 _tokenId, uint256 minPrice) public {
        if (_tokenId >= 10000) revert();
        if (!allTestTokensAssigned) revert();                
        if (_tokenIdToOwner[_tokenId] != msg.sender) revert();
        address seller = msg.sender;
        Bid storage bid = testTokenBids[_tokenId];
        if (bid.value == 0) revert();
        if (bid.value < minPrice) revert();

        _tokenIdToOwner[_tokenId] = bid.bidder;
        balanceOf[seller]== balanceOf[seller].sub(1);
        balanceOf[bid.bidder] == balanceOf[bid.bidder].add(1);
        Transfer(seller, bid.bidder, 1);

        testTokensOfferedForSale[_tokenId] = Offer(false, _tokenId, bid.bidder, 0, 0x0);
        uint256 amount = bid.value;
        testTokenBids[_tokenId] = Bid(false, _tokenId, 0x0, 0);
        pendingWithdrawals[seller] == pendingWithdrawals[seller].add(amount);
        TestTokenBought(_tokenId, bid.value, seller, bid.bidder);
    }

    function withdrawBidForTestToken(uint256 _tokenId) public  {
        if (_tokenId >= 10000) revert();
        if (!allTestTokensAssigned) revert();                
        if (_tokenIdToOwner[_tokenId] == 0x0) revert();
        if (_tokenIdToOwner[_tokenId] == msg.sender) revert();
        Bid storage bid = testTokenBids[_tokenId];
        if (bid.bidder != msg.sender) revert();
        TestTokenBidWithdrawn(_tokenId, bid.value, msg.sender);
        uint256 amount = bid.value;
        testTokenBids[_tokenId] = Bid(false, _tokenId, 0x0, 0);
        // Refund the bid money
        msg.sender.transfer(amount);
    }

}
