const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions"); //npm i truffle-assertions
const BigNumber = require('bignumber.js'); // npm install bignumber.js
var assert = require("assert");

var User = artifacts.require("../contracts/User.sol");
var Permissions = artifacts.require("../contracts/Permissions.sol");
var Roles = artifacts.require("../contracts/Roles.sol");
var RequestApprovalManagement = artifacts.require("../contracts/RequestApprovalManagement.sol");



contract('IS4302 Project', function (accounts) {
    before(async () => {
        userInstance = await User.deployed();
        permissionsInstance = await Permissions.deployed();
        rolesInstance = await Roles.deployed();
        requestApprovalManagementInstance = await RequestApprovalManagement.deployed();
    });

    console.log("Testing IS4302 Project");

    it("Test Create New Role", async () => {
        // An account create new role request

        // Admin account approve request
    });

    it("Test Add Dataset to Role", async () => {
        // An account create Add Dataset to role request

        // Admin account approve request

    });

    it("Test Add Users to Roles", async () => {
       // An account create Add User to role request

        // Admin account approve request

    });


    it("Test Remove Role", async () => {
       // An account create Remove Role request

        // Admin account approve request

    });

    it("Test Remove Dataset from Role", async () => {
       // An account create Remove Dataset from Role request

        // Admin account approve request

    });

    it("Test Remove User from Role", async () => {
       // An account create Remove User from Role request

        // Admin account approve request

    });

    it("Test Reject Request", async () => {
        // An account create a request
 
         // Admin account reject request
 
     });

})