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
        assert.equal(1, await userInstance.getTotalNumberOfUsers(), "DBAdmin not created.");
        await userInstance.createUser("acc1" ,{ from: accounts[1] });
        assert.equal(2, await userInstance.getTotalNumberOfUsers(), "Acc1 creation failed.");
                
        // Check Give acc1 admin rights
        await userInstance.giveAdmin(accounts[1] ,{ from: accounts[0] });
        assert.equal(true, await userInstance.checkIsAdmin(accounts[1]), "Acc1 not given admin rights.");
    });

    // acc1 created -> Admin --> accounts[1]

    it("Create user (acc2)", async () => {
        // Check Create User
        await userInstance.createUser("acc2" ,{ from: accounts[2] });
        assert.equal(3, await userInstance.getTotalNumberOfUsers(), "Acc2 creation failed.");

        // Check that acc2 is normal user rights
        assert.equal(false, await userInstance.checkIsAdmin(accounts[2]), "Acc2 is supposed to be a normal user.");       
    });

    // acc2 created -> User --> accounts[2]

    it("acc2 upload a dataset to a new role (role 0)", async () => {
        assert.equal(0, await requestApprovalManagementInstance.getTotalNumberOfRequests(), "Empty system has requests.");
        
        // Create request to upload dataset to new role
        // Dataset identifier: datasetIdentifier
        // Role Name: role0
        // Permission Name: permission0
        // Permission ID: 0
        await requestApprovalManagementInstance.uploadDatasetToNewRoleRequest("schema0.table0.column0", "role0", "permission0", 0 ,{ from: accounts[2] });
        assert.equal(1, await requestApprovalManagementInstance.getTotalNumberOfRequests(), "Request not created successfully.");
        
        // Check that currently have no roles and permissions created yet
        assert.equal(0, await roleInstance.getNumRoles(), "Empty system has roles.");
        assert.equal(0, await permissionInstance.getNumPermissions(), "Empty system has permissions.");
        
        // Admin account approve request
        let requestApproved = await requestApprovalManagementInstance.approveRequest(0, { from: accounts[1] });

        // Check that request has been approved successfully
        truffleAssert.eventEmitted(requestApproved, "uploadDatasetToNewRoleRequestApproved", null, "Request not approved.");

        // Check if new role is created, new permissions is created and tokens issued successfully.
        assert.equal(1, await roleInstance.getNumRoles(), 'Role creation failed.');
        assert.equal(1, await permissionInstance.getNumPermissions(), 'Permission creation failed.');
        assert.equal(1, await userInstance.getTokenBalance(accounts[2]), "Token issuance failed");
    });

    // role0 created together with a new dataset (new permissions)

    it("Submit request to create a new role (role1)", async () => {
        // Create request to upload dataset to new role
        // Role Name: role1
        await requestApprovalManagementInstance.createNewRoleRequest("role1",{ from: accounts[2] });
        assert.equal(2, await requestApprovalManagementInstance.getTotalNumberOfRequests(), 'Role1 creation request not created.');
        
        // Check that currently have only 1 role that was previously created
        assert.equal(1, await roleInstance.getNumRoles());
        
        // Admin account approve request
        let requestApproved = await requestApprovalManagementInstance.approveRequest(1, { from: accounts[1] });

        // Check that request has been approved successfully
        truffleAssert.eventEmitted(requestApproved, "createNewRoleRequestApproved", null, message="Request not approved.");

        // Check if new role is created 
        assert.equal(2, await roleInstance.getNumRoles(), "Role1 creation failed.");
    });

    // role1 created

    it("Submit request to add permission0 to role1", async () => {   
        // Create request to upload dataset to new role
        // Permission ID: 0
        // Role ID: 1
        await requestApprovalManagementInstance.addExistingDatasetToRoleRequest(0, 1,{ from: accounts[1] });
        assert.equal(3, await requestApprovalManagementInstance.getTotalNumberOfRequests(), "Request to permision0 to role1 not created successfully.");
        
        // Check that currently only (role0) is given permission to (permission0)
        assert.equal(1, await roleInstance.numRolesGivenToPermission(0), "More than 1 role has access to permission0.");
        
        // Admin account approve request
        let requestApproved = await requestApprovalManagementInstance.approveRequest(2, { from: accounts[1] });

        // Check that request has been approved successfully
        truffleAssert.eventEmitted(requestApproved, "addExistingDatasetToRolesRequestApproved", null, message='Request to add permission0 to role1 not approved.');

        // Check that currently both (role0) and (role1) is given permission to (permission0)
        assert.equal(2, await roleInstance.numRolesGivenToPermission(0), "Role1 not given access to permission0.");
    });

    // (permission0) added to (role1)

    it("Add acc2 to role1", async () => {
        // Create request to upload dataset to new role
        // User address: accounts[2]
        // Role ID: 1
        await requestApprovalManagementInstance.addUsersToRoleRequest(accounts[2], 1,{ from: accounts[1] });
        assert.equal(4, await requestApprovalManagementInstance.getTotalNumberOfRequests(), "Request to add acc2 to role1 not successfully created.");
        
        // Check that currently there are no users is added to (role1)
        assert.equal(0, await roleInstance.numRolesGrantedToUser(accounts[2]), "role1 prematurely added to acc2.");
        
        // Admin account approve request
        let requestApproved = await requestApprovalManagementInstance.approveRequest(3, { from: accounts[1] });
        // Check that request has been approved successfully
        truffleAssert.eventEmitted(requestApproved, "addUsersToRolesRequestApproved", null, message='Request to add acc2 to role1 not approved.');
        // Check that currently both (acc2) is added to (role1)
        
        assert.equal(1, await roleInstance.numRolesGrantedToUser(accounts[2]), "role1 not added to acc2.");
        // console.log(await roleInstance.numRolesGrantedToUser(accounts[2]));
    });

    it("Acc1 add metadata for permission0", async () => {
        // Verify Metadata system is empty
        assert.equal(0, await metadataInstance.getNumDSetsCreated(), "Empty system has dataset records.");
        assert.equal(0, await metadataInstance.getNumCatsCreated(), "Empty system has categories created.");
        assert.equal(0, await metadataInstance.getNumTagsCreated(), "Empty system has tags created.");
        
        // Create category and tag (admin only)
        // Category Name: "test-cat"
        // Tag Name: "test-tag"
        let catID = await metadataInstance.addCategory("test-cat", { from: accounts[1] });
        let tagID = await metadataInstance.addTag("test-tag", { from: accounts[1] });
        var tags = [];
        tags.push(tagID);
        var ts = new Date().getTime();
        assert.equal(1, await metadataInstance.getNumCatsCreated(), "test-cat creation failed.");
        assert.equal(1, await metadataInstance.getNumTagsCreated(), "test-tag creation failed.");

        // Add metadata
        await metadataInstance.addMetadata("schema0.table0.column0", "test-title", "test-desc", catID, tags, ts.toString(), "acc1", 0, { from: accounts[1] });
        let metadata = await metadataInstance.getMetadata("schema0.table0.column0");
        assert.notEqual('', metadata, "Metadata upload failed");

        assert.equal(1, await userInstance.getTokenBalance(account[1]), "Tokens not issued for update");

    });
  


   

});