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
        
        // Check that currently have no roles and permissions created yet
        await assert.equal(0, await roleInstance.getNumRoles());
        await assert.equal(0, await permissionInstance.getNumPermissions());
        
        // Admin account approve request
        let requestApproved = await requestApprovalManagementInstance.approveRequest(0, { from: accounts[1] });

        // Check that request has been approved successfully
        truffleAssert.eventEmitted(requestApproved, "uploadDatasetToNewRoleRequestApproved");

        // Check if new role is created and new permissions is created
        await assert.equal(1, await roleInstance.getNumRoles());
        await assert.equal(1, await permissionInstance.getNumPermissions());
    });

    // role0 created together with a new dataset (new permissions)

    it("Submit request to create a new role (role1)", async () => {
        //Create request to upload dataset to new role
        await assert.equal(1, await requestApprovalManagementInstance.getTotalNumberOfRequests());
        // Role Name: role1
        await requestApprovalManagementInstance.createNewRoleRequest("role1",{ from: accounts[2] });
        await assert.equal(2, await requestApprovalManagementInstance.getTotalNumberOfRequests());
        
        // Check that currently have only 1 role that was previously created
        await assert.equal(1, await roleInstance.getNumRoles());
        
        // Admin account approve request
        let requestApproved = await requestApprovalManagementInstance.approveRequest(1, { from: accounts[1] });

        // Check that request has been approved successfully
        truffleAssert.eventEmitted(requestApproved, "createNewRoleRequestApproved");

        // Check if new role is created 
        await assert.equal(2, await roleInstance.getNumRoles());
    });

    // role1 created

    it("Submit request to add permission0 to role1", async () => {
        //Create request to upload dataset to new role
        await assert.equal(2, await requestApprovalManagementInstance.getTotalNumberOfRequests());
        // Permission ID: 0
        // Role ID: 1
        await requestApprovalManagementInstance.addExistingDatasetToRoleRequest(0, 1,{ from: accounts[1] });
        await assert.equal(3, await requestApprovalManagementInstance.getTotalNumberOfRequests());
        
        // Check that currently only (role0) is given permission to (permission0)
        await assert.equal(1, await roleInstance.numRolesGivenToPermission(0));
        
        // Admin account approve request
        let requestApproved = await requestApprovalManagementInstance.approveRequest(2, { from: accounts[1] });

        // Check that request has been approved successfully
        truffleAssert.eventEmitted(requestApproved, "addExistingDatasetToRolesRequestApproved");

        // Check that currently both (role0) and (role1) is given permission to (permission0)
        await assert.equal(2, await roleInstance.numRolesGivenToPermission(0));
    });

    // (permission0) added to (role1)

    it("Add acc2 to role1", async () => {
        //Create request to upload dataset to new role
        await assert.equal(3, await requestApprovalManagementInstance.getTotalNumberOfRequests());
        // User address: accounts[2]
        // Role ID: 1
        await requestApprovalManagementInstance.addUsersToRoleRequest(accounts[2], 1,{ from: accounts[1] });
        await assert.equal(4, await requestApprovalManagementInstance.getTotalNumberOfRequests());
        
        // Check that currently there are no users is added to (role1)
        await assert.equal(0, await roleInstance.numRolesGrantedToUser(accounts[2]));
        console.log(await roleInstance.numRolesGrantedToUser(accounts[2]));
        
        // Admin account approve request
        let requestApproved = await requestApprovalManagementInstance.approveRequest(3, { from: accounts[1] });

        // Check that request has been approved successfully
        truffleAssert.eventEmitted(requestApproved, "addUsersToRolesRequestApproved");

        // Check that currently both (acc2) is added to (role1)
        
        ///// Will uncomment the following line of code to perform checks ///////
        // await assert.equal(1, await roleInstance.numRolesGivenToPermission(accounts[2]));
        console.log(await roleInstance.numRolesGrantedToUser(accounts[2]));
    });
 
  


   

})