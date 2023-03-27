const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions"); //npm i truffle-assertions
const BigNumber = require('bignumber.js'); // npm install bignumber.js
var assert = require("assert");

var User = artifacts.require("../contracts/User.sol");
var Permission = artifacts.require("../contracts/Permission.sol");
var Role = artifacts.require("../contracts/Role.sol");
var Metadata = artifacts.require("../contracts/Metadata.sol");
var Pointer = artifacts.require("../contracts/Pointer.sol");
var DataLineage = artifacts.require("../contracts/DataLineage.sol");
var DatasetUploader = artifacts.require("../contracts/DatasetUploader.sol");
var RequestApprovalManagement = artifacts.require("../contracts/RequestApprovalManagement.sol");
var PriorityQueue = artifacts.require("../contracts/PriorityQueue.sol");
var QueueSystem = artifacts.require("../contracts/QueueSystem.sol");
var QueryDataset = artifacts.require("../contracts/QueryDataset.sol");


contract('IS4302 Project', function (accounts) {
    before(async () => {
        userInstance = await User.deployed();
        permissionInstance = await Permission.deployed();
        roleInstance = await Role.deployed();
        metadataInstance = await Metadata.deployed();
        pointerInstance = await Pointer.deployed();
        dataLineageInstance = await DataLineage.deployed();
        datasetUploaderInstance = await DatasetUploader.deployed();
        requestApprovalManagementInstance = await RequestApprovalManagement.deployed();
        priorityQueueInstance = await PriorityQueue.deployed();
        queueSystemInstance = await QueueSystem.deployed();
        queryDatasetInstance = await QueryDataset.deployed();
    });

    console.log("Testing IS4302 Project");

    // During Deployment, 'DBAdmin' has been created --> accounts(0)

    it("Create admin (acc1)", async () => {
        // Check Create User
        await assert.equal(1, await userInstance.getTotalNumberOfUsers());
        await userInstance.createUser("acc1" ,{ from: accounts[1] });
        await assert.equal(2, await userInstance.getTotalNumberOfUsers());    
                
        // Check Give acc1 admin rights
        await userInstance.giveAdmin(accounts[1] ,{ from: accounts[0] });
        await assert.equal(true, await userInstance.checkIsAdmin(accounts[1]));       
    });

    // acc1 created -> Admin --> accounts[1]

    it("Create user (acc2)", async () => {
        // Check Create User
        await assert.equal(2, await userInstance.getTotalNumberOfUsers());
        await userInstance.createUser("acc2" ,{ from: accounts[2] });
        await assert.equal(3, await userInstance.getTotalNumberOfUsers());    

        // Check that acc2 is normal user rights
        await assert.equal(false, await userInstance.checkIsAdmin(accounts[2]));       
    });

    // acc2 created -> User --> accounts[2]

    it("acc1 upload a dataset to a new role (role 0)", async () => {
        //Create request to upload dataset to new role
        await assert.equal(0, await requestApprovalManagementInstance.getTotalNumberOfRequests());
        // Dataset identifier: datasetIdentifier
        // Role Name: role0
        // Permission Name: permission0
        // Permission ID: 0
        await requestApprovalManagementInstance.uploadDatasetToNewRoleRequest("schema0.table0.column0", "role0", "permission0", 0 ,{ from: accounts[2] });
        await assert.equal(1, await requestApprovalManagementInstance.getTotalNumberOfRequests());
        // Admin account approve request
        let requestApproved = await requestApprovalManagementInstance.approveRequest(0, { from: accounts[1] });

        // Check if new role is created and new permissions is created

        truffleAssert.eventEmitted(requestApproved, "uploadDatasetToNewRoleRequestApproved");
    });


 
  


   

})