const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions"); // npm install truffle-assertions
const BigNumber = require("bignumber.js"); // npm install bignumber.js
var assert = require("assert");

var User = artifacts.require("../contracts/User.sol");

contract("User", function (accounts) {
    before(async () => {
        userInstance = await User.deployed();
    });

    console.log("Testing User Contract");

    it("Check DBAdmin created", async() => {
        const adState = await userInstance.checkAdmin({from: accounts[0]}, accounts[0]);
        console.log("1 ran");
        assert(adState == userInstance.adminState.isAdmin, "DBAdmin not created.")
    });
});