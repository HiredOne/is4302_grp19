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

    it("Acc1 upload a dataset to a new role", async () => {
        await assert.equal(0, await requestApprovalManagementInstance.getTotalNumberOfRequests());
        await requestApprovalManagementInstance.uploadDatasetToNewRoleRequest("schema1.table1.column1", "role0", "dataset1" ,{ from: accounts[2] });
        await assert.equal(1, await requestApprovalManagementInstance.getTotalNumberOfRequests());
        // Admin account approve request
        let requestApproved = await requestApprovalManagementInstance.approveRequest(0, { from: accounts[1] });

        // Check if new role is created and new permissions is created

        truffleAssert.eventEmitted(requestApproved, "uploadDatasetToNewRoleRequestApproved");
    });


 
    it("Create a new role1", async () => {
        // An account create new role request
        // Account 2 create role1
        await assert.equal(1, await requestApprovalManagementInstance.getTotalNumberOfRequests());
        await requestApprovalManagementInstance.createNewRoleRequest("role1", { from: accounts[2] });
        await assert.equal(2, await requestApprovalManagementInstance.getTotalNumberOfRequests());
        // Admin account approve request
        let requestApproved = await requestApprovalManagementInstance.approveRequest(1, { from: accounts[1] });
        
        // Check role contract if this role is created

        
        truffleAssert.eventEmitted(requestApproved, "createNewRoleRequestApproved");

    });

    it("Add permission0 to role1", async () => {
        // acc2 create Add per,ission0 to role1 request
        await assert.equal(2, await requestApprovalManagementInstance.getTotalNumberOfRequests());
        await requestApprovalManagementInstance.addExistingDatasetToRoleRequest(0, 1,  { from: accounts[2] });
        await assert.equal(3, await requestApprovalManagementInstance.getTotalNumberOfRequests());
        // Admin account approve request
        let requestApproved = await requestApprovalManagementInstance.approveRequest(2, { from: accounts[1] });
        
        // Check Permission contract if this dataset is created

        truffleAssert.eventEmitted(requestApproved, "addExistingDatasetToRolesRequestApproved");
        
    });

    it("Add acc2 to role1", async () => {
       // acc2 create request to add acc2 to role1
        await assert.equal(3, await requestApprovalManagementInstance.getTotalNumberOfRequests());
        await requestApprovalManagementInstance.addUsersToRoleRequest(accounts[2], 1,  { from: accounts[2] });
        await assert.equal(4, await requestApprovalManagementInstance.getTotalNumberOfRequests());
        // Admin account approve request
        let requestApproved = await requestApprovalManagementInstance.approveRequest(3, { from: accounts[1] });
        
        // Check Role contract if this user is added

        truffleAssert.eventEmitted(requestApproved, "addUsersToRolesRequestApproved");
    });


   

})