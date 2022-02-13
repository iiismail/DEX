const Dex = artifacts.require("Dex")
const tokens = artifacts.require("tokens")
const truffleAssert = require('truffle-assertions');

contract.skip ("Dex", accounts => {
    it("should only be possible for owner to add tokens", async () => {  
        let dex = await Dex.deployed()
        let link = await tokens.deployed()
        await truffleAssert.passes(
            dex.addToken(link.address, web3.utils.fromUtf8("LINK"), {from:accounts[0]})
        )
        await truffleAssert.reverts(
            dex.addToken(link.address, web3.utils.fromUtf8("LINK"), {from:accounts[1]})
        )
    })

    it("should handle deposits correctly", async () => {  
        let dex = await Dex.deployed()
        let link = await tokens.deployed()
        await link.approve(dex.address, 500)
        await dex.deposit(web3.utils.fromUtf8("LINK"), 500)
        let balance = await dex.balances(accounts[0], web3.utils.fromUtf8("LINK"))
        assert.equal(balance.toNumber(), 500)
        
    })

    it("should handle withdrawals correctly", async () => {  
        let dex = await Dex.deployed()
        let link = await tokens.deployed()
        await truffleAssert.passes(
            dex.withdraw(web3.utils.fromUtf8("LINK"), 100)
        )
        await truffleAssert.reverts(
            dex.withdraw(web3.utils.fromUtf8("LINK"), 2000) 
        )
    })


})

