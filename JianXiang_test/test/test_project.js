const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions"); //npm i truffle-assertions
const BigNumber = require('bignumber.js'); // npm install bignumber.js
var assert = require("assert");

var User = artifacts.require("../contracts/User.sol");
var Permission = artifacts.require("../contracts/Permission.sol");
var Role = artifacts.require("../contracts/Role.sol");
var RequestApprovalManagement = artifacts.require("../contracts/RequestApprovalManagement.sol");



contract('IS4302 Project', function (accounts) {
    before(async () => {
        userInstance = await User.deployed();
        permissionInstance = await Permission.deployed();
        roleInstance = await Role.deployed();
        requestApprovalManagementInstance = await RequestApprovalManagement.deployed();
    });

    console.log("Testing IS4302 Project");

    it("Test Create Request to upload dataset", async () => {
        

    });


 
    it("Test Create New Role", async () => {
        // An account create new role request
        // Account 2 create finance role
        await assert.equal(0, await requestApprovalManagementInstance.getTotalNumberOfRequests());
        await requestApprovalManagementInstance.createNewRoleRequest("finance", { from: accounts[2] });
        await assert.equal(1, await requestApprovalManagementInstance.getTotalNumberOfRequests());
        // Admin account approve request
        let requestApproved = await requestApprovalManagementInstance.approveRequest(0, { from: accounts[1] });
        // Check role contract if this role is created

        
        truffleAssert.eventEmitted(requestApproved, "createNewRoleRequestApproved");

    });

    it("Test Add Dataset (Permission) to Role", async () => {
        // An account create Add Dataset to role request
        await assert.equal(1, await requestApprovalManagementInstance.getTotalNumberOfRequests());
        await requestApprovalManagementInstance.addDatasetToRoleRequest(0, 0,  { from: accounts[2] });
        await assert.equal(2, await requestApprovalManagementInstance.getTotalNumberOfRequests());
        // Admin account approve request
        let requestApproved = await requestApprovalManagementInstance.approveRequest(1, { from: accounts[1] });
        // Check Permission contract if this dataset is created

        truffleAssert.eventEmitted(requestApproved, "addDatasetToRolesRequestApproved");
        
    });

    it("Test Add Users to Role", async () => {
       // An account create Add User to role request
        await assert.equal(2, await requestApprovalManagementInstance.getTotalNumberOfRequests());
        await requestApprovalManagementInstance.addUsersToRoleRequest(accounts[2], 0,  { from: accounts[2] });
        await assert.equal(3, await requestApprovalManagementInstance.getTotalNumberOfRequests());
        // Admin account approve request
        let requestApproved = await requestApprovalManagementInstance.approveRequest(2, { from: accounts[1] });
        // Check Role contract if this user is added

        truffleAssert.eventEmitted(requestApproved, "addUsersToRolesRequestApproved");
    });


    it("Test Reject Request", async () => {
        // An account create a request
        await assert.equal(3, await requestApprovalManagementInstance.getTotalNumberOfRequests());
        await requestApprovalManagementInstance.createNewRoleRequest("business", { from: accounts[2] });
        await assert.equal(4, await requestApprovalManagementInstance.getTotalNumberOfRequests());

        // Admin account reject request
        let requestRejected = await requestApprovalManagementInstance.rejectRequest(3, "Do not have permission to create this role", { from: accounts[1] });
        // await assert.equal("Do not have permission to create this role", await requestApprovalManagementInstance.getRequestAdminRemarks(6), "Request not rejected and admin remarks not updated");
     
        truffleAssert.eventEmitted(requestRejected, "rejectRequestEvent");
    });



    //  // At the end of all other testings, we can test the remove 
    //  it("Test Remove Dataset from Role", async () => {
    //     // An account create Remove Dataset from Role request
    //     await assert.equal(4, await requestApprovalManagementInstance.getTotalNumberOfRequests());
    //     await requestApprovalManagementInstance.removeDatasetFromRoleRequest(0, 0, { from: accounts[2] });
    //     await assert.equal(5, await requestApprovalManagementInstance.getTotalNumberOfRequests());
    //     // Admin account approve request
    //     let requestApproved = await requestApprovalManagementInstance.approveRequest(4, { from: accounts[1] });
    //     // Check Role contract if this permission is removed

    //     truffleAssert.eventEmitted(requestApproved, "removeDatasetFromRolesRequestApproved");
    //  });
 
    //  it("Test Remove User from Role", async () => {
    //     // An account create Remove User from Role request
    //     await assert.equal(5, await requestApprovalManagementInstance.getTotalNumberOfRequests());
    //     await requestApprovalManagementInstance.removeUsersFromRoleRequest(accounts[2], 0, { from: accounts[2] });
    //     await assert.equal(6, await requestApprovalManagementInstance.getTotalNumberOfRequests());
    //     // Admin account approve request
    //     let requestApproved = await requestApprovalManagementInstance.approveRequest(5, { from: accounts[1] });
    //     // Check Role contract if this user is removed

    //     truffleAssert.eventEmitted(requestApproved, "removeUsersFromRolesRequestApproved");
    //  });

    //  it("Test Remove Role", async () => {
    //     // An account create Remove Role request
    //     await assert.equal(6, await requestApprovalManagementInstance.getTotalNumberOfRequests());
    //     await requestApprovalManagementInstance.removeRoleRequest(0, accounts[2], { from: accounts[2] });
    //     await assert.equal(7, await requestApprovalManagementInstance.getTotalNumberOfRequests());
    //     // Admin account approve request
    //     let requestApproved = await requestApprovalManagementInstance.approveRequest(6, { from: accounts[1] });
    //     // Check Role contract if this role has been removed

    //     truffleAssert.eventEmitted(requestApproved, "removeRoleRequestApproved");
    //  });

})