const MothThankYou = artifacts.require("MothThankYou");


contact('MothThankYou', async (accounts) => {

  /*
  it("mint token", async () => {
    let instance = await AliceInWonderland.deployed();

    let tokenUri = "http://alicetoken.com/api/token/1";
    let mintResult = await instance.mintTo(accounts[0], tokenUri);

    let totalSupply = await instance.totalSupply.call();
    assert.equal(1, totalSupply.valueOf(), "Total supply is 1");

    let balanceOf0 = await instance.balanceOf(accounts[0]);
    assert.equal(1, balanceOf0.valueOf(), "Balance of 0th account is 1");

    let tokensOfOut = await instance.tokenOfOwnerByIndex(accounts[0], 0);
    let tokens = tokensOfOut.valueOf();
    let tokenId = tokens[0];

    assert.equal(1, tokenId, "Token ID is 1");

    let ownerOf1 = await instance.ownerOf(tokenId);
    assert.equal(accounts[0], ownerOf1.valueOf(), "0th account is owner of token ID 1");


    let metadata = await instance.tokenURI.call(tokenId);
    assert.equal(tokenUri, metadata.valueOf(), "Metadata is correct");
    */
  });

});
