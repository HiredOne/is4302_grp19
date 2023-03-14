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

    // Assuming account[1] is admin
 
    it("Test Create New Role", async () => {
        // An account create new role request
        // Account 2 create finance role
        await requestApprovalManagementInstance.createNewRoleRequest("finance", { from: accounts[2] });
        // Admin account approve request
        await requestApprovalManagementInstance.approveRequest(0, { from: accounts[1] });
        // Check role contract if this role is created

    });

    it("Test Add Dataset to Role", async () => {
        // An account create Add Dataset to role request
        await requestApprovalManagementInstance.addDatasetToRolesRequest("bank account", 0,  { from: accounts[2] });
        // Admin account approve request
        await requestApprovalManagementInstance.approveRequest(1, { from: accounts[1] });
        // Check Permissions contract if this dataset is created

    });

    it("Test Add Users to Roles", async () => {
       // An account create Add User to role request
        await requestApprovalManagementInstance.addUsersToRolesRequest(1, 0,  { from: accounts[2] });
        // Admin account approve request
        await requestApprovalManagementInstance.approveRequest(2, { from: accounts[1] });
        // Check Roles contract if this user is added

    });


    it("Test Reject Request", async () => {
        // An account create a request
        await requestApprovalManagementInstance.createNewRoleRequest("business", { from: accounts[2] });
        // Admin account reject request
        await requestApprovalManagementInstance.rejectRequest(3, "Do not have permission to create this role", { from: accounts[1] });
        await assert.equal("Do not have permission to create this role", await requestApprovalManagementInstance.getRequestAdminRemarks(6), "Request not rejected and admin remarks not updated");
     });



     // At the end of all other testings, we can test the remove 
     it("Test Remove Dataset from Role", async () => {
        // An account create Remove Dataset from Role request
        await requestApprovalManagementInstance.removeDatasetFromRolesRequest(0, 0, { from: accounts[2] });
        // Admin account approve request
        await requestApprovalManagementInstance.approveRequest(4, { from: accounts[1] });
        // Check Roles contract if this permissions is removed

     });
 
     it("Test Remove User from Role", async () => {
        // An account create Remove User from Role request
        await requestApprovalManagementInstance.removeUsersFromRolesRequest(1, 0, { from: accounts[2] });
        // Admin account approve request
        await requestApprovalManagementInstance.approveRequest(5, { from: accounts[1] });
        // Check Roles contract if this user is removed

     });

     it("Test Remove Role", async () => {
        // An account create Remove Role request
        await requestApprovalManagementInstance.removeRoleRequest(0, 1, { from: accounts[2] });
        // Admin account approve request
        await requestApprovalManagementInstance.approveRequest(6, { from: accounts[1] });
        // Check Roles contract if this role has been removed

     });

})