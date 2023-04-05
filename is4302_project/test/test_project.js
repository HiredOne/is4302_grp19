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

var ts = new Date().getTime(); // Fixing the timestamp for global use

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

    it("1) Create admin (acc1)", async () => {
        // Check Create User
        assert.equal(1, await userInstance.getTotalNumberOfUsers(), "DBAdmin not created.");
        await userInstance.createUser("acc1" ,{ from: accounts[1] });
        assert.equal(2, await userInstance.getTotalNumberOfUsers(), "Acc1 creation failed.");
                
        // Check Give acc1 admin rights
        await userInstance.giveAdmin(accounts[1] ,{ from: accounts[0] });
        assert.equal(true, await userInstance.checkIsAdmin(accounts[1]), "Acc1 not given admin rights.");
    });

    // acc1 created -> Admin --> accounts[1]

    it("2) Create user (acc2)", async () => {
        // Check Create User
        await userInstance.createUser("acc2" ,{ from: accounts[2] });
        assert.equal(3, await userInstance.getTotalNumberOfUsers(), "Acc2 creation failed.");

        // Check that acc2 is normal user rights
        assert.equal(false, await userInstance.checkIsAdmin(accounts[2]), "Acc2 is supposed to be a normal user.");       
    });

    // acc2 created -> User --> accounts[2]

    it("3) acc2 upload a dataset to a new role (role 0)", async () => {
        assert.equal(0, await requestApprovalManagementInstance.getTotalNumberOfRequests(), "Empty system has requests.");
        
        // Create request to upload dataset to new role
        // Dataset identifier: datasetIdentifier
        // Role Name: role0
        // Permission Name: permission0
        // Permission ID: 0
        await requestApprovalManagementInstance.uploadDatasetToNewRoleRequest("schema0.table0", "role0", "permission0",{ from: accounts[2] });
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

    it("4) Submit request to create a new role (role1)", async () => {
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

    it("5) Submit request to add permission0 to role1", async () => {   
        // Create request to upload dataset to new role
        // Permission ID: 0
        // Role ID: 1
        await requestApprovalManagementInstance.addExistingDatasetToRoleRequest(0, 1,{ from: accounts[1] });
        assert.equal(3, await requestApprovalManagementInstance.getTotalNumberOfRequests(), "Request to permision0 to role1 not created successfully.");
        
        // Check that currently only (role0) is given permission to (permission0)
        assert.equal(1, await roleInstance.numRolesGivenToPermission(0), "More than 1 role has access to permission0.");
        
        // Admin account approve request
        let requestApproved = await requestApprovalManagementInstance.approveRequest(2, { from: accounts[0] });

        // Check that request has been approved successfully
        truffleAssert.eventEmitted(requestApproved, "addExistingDatasetToRolesRequestApproved", null, message='Request to add permission0 to role1 not approved.');

        // Check that currently both (role0) and (role1) is given permission to (permission0)
        assert.equal(2, await roleInstance.numRolesGivenToPermission(0), "Role1 not given access to permission0.");
    });

    // (permission0) added to (role1)

    it("6) Add acc1 and acc2 to role1", async () => {
        // Create request to add acc1 to role1
        // User address: accounts[1]
        // Role ID: 1
        await requestApprovalManagementInstance.addUsersToRoleRequest(accounts[1], 1,{ from: accounts[1] });
        assert.equal(4, await requestApprovalManagementInstance.getTotalNumberOfRequests(), "Request to add acc1 to role1 not successfully created.");
        
        // Check that currently there are no users is added to (role1)
        assert.equal(0, await roleInstance.numRolesGrantedToUser(accounts[1]), "role1 prematurely added to acc1.");
        
        // Admin account approve request
        let requestApproved = await requestApprovalManagementInstance.approveRequest(3, { from: accounts[0] });
        // Check that request has been approved successfully
        truffleAssert.eventEmitted(requestApproved, "addUsersToRolesRequestApproved", null, message='Request to add acc1 to role1 not approved.');
        // Check that currently both (acc1) is added to (role1)
        assert.equal(1, await roleInstance.numRolesGrantedToUser(accounts[1]), "role1 not added to acc2.");

        await requestApprovalManagementInstance.addUsersToRoleRequest(accounts[2], 1,{ from: accounts[2] });
        await requestApprovalManagementInstance.approveRequest(4, { from: accounts[0] });
        assert.equal(1, await roleInstance.numRolesGrantedToUser(accounts[2]), "role1 not added to acc2.");

    });

    it("7) Acc1 add metadata for permission0", async () => {
        // Verify Metadata system is empty
        assert.equal(0, await metadataInstance.getNumDSetsCreated(), "Empty system has dataset records.");
        assert.equal(0, await metadataInstance.getNumCatsCreated(), "Empty system has categories created.");
        assert.equal(0, await metadataInstance.getNumTagsCreated(), "Empty system has tags created.");
        
        // Create category and tag (admin only)
        // Category Name: "test-cat"
        // Tag Name: "test-tag"
        // We use .call to get the results of these calls first for local use
        let catID = await metadataInstance.addCategory.call("test-cat", { from: accounts[1] }); 
        let tagID = await metadataInstance.addTag.call("test-tag", { from: accounts[1] }); 
        
        // Then we run the function normally so that the outcome is global
        await metadataInstance.addCategory("test-cat", { from: accounts[1] }); 
        await metadataInstance.addTag("test-tag", { from: accounts[1] });
        let tags = [tagID];
        assert.equal(1, await metadataInstance.getNumCatsCreated(), "test-cat creation failed.");
        assert.equal(1, await metadataInstance.getNumTagsCreated(), "test-tag creation failed.");
        
        // Add metadata
        await metadataInstance.addMetadata("schema0.table0", "test-title", "test-desc", catID, tags, ts.toString(), "acc1", 0, { from: accounts[1] });
        let metadata = await metadataInstance.getMetadata("schema0.table0");
        assert.notEqual('', metadata, "Metadata upload failed");
        assert.equal(1, await userInstance.getTokenBalance(accounts[1]), "Tokens not issued for update");

    });

    it("8) Submitting non-permanent Query", async () => {
        // Create query, then submit for verification
        let query = "SELECT column0 FROM schema0.table0";
        let datasetName = "schema0.table0";
        // We use .call to get the results of these calls first for local use
        let outcome = await queryDatasetInstance.runQuery.call(datasetName, query, datasetName, "nil", 0, 0, { from: accounts[1] })
        await queryDatasetInstance.runQuery(datasetName, query, "0", "nil", 0, 0, { from: accounts[1] })
        assert.equal(true, outcome, 'Query verification failed.');
        assert.equal(1, await queueSystemInstance.getQueueLength(), 'Query not enqueued.');
    });

    it("9) Test priority", async () =>{
        // To test priority, we will create a second query with priority 0 (0 tokens)
        // Then we will create a third query with priority 1 (1 token)
        // Note that query3 should come to the head of the queue 
        // because the first 2 queries have a priority of 0. 
        
        // Create query, then submit for verification
        let query2 = "SELECT column1 FROM schema0.table0";
        let query3 = "SELECT column2 FROM schema0.table0"; // This query we prioritise
        let datasetName1 = "schema0.table0";
        await queryDatasetInstance.runQuery(datasetName1, query2, datasetName1, "nil", 0, 0, { from: accounts[1] });
        assert.equal(2, await queueSystemInstance.getQueueLength(), 'Second Query not enqueued.');
        await queryDatasetInstance.runQuery(datasetName1, query3, datasetName1, "nil", 1, 0, { from: accounts[1] }); // Here we use 1 token to prioritise the third query
        assert.equal(3, await queueSystemInstance.getQueueLength(), 'Third Query not enqueued.');
        assert.equal(0, await userInstance.getTokenBalance(accounts[1]), 'Tokens not deducted.'); // Verify deduction of tokens after use

        let outcome = await queueSystemInstance.pop(); // The first query should now be query 3.
        truffleAssert.eventEmitted(outcome, 'queryExecuted', {
            query : "SELECT column2 FROM schema0.table0"
        }, 'Query not prioritised');
        assert.equal(2, await queueSystemInstance.getQueueLength(), "Query not deleted after execution.");
    });

    it("10) Submitting a permanent query", async () => {
        let datasetName1 = "schema0.table0";
        let permQuery = "DELETE FROM schema0.table0"; // Query that makes a permanent change to the system
        await queryDatasetInstance.runQuery(datasetName1, permQuery, datasetName1, "nil", 1, 0, { from: accounts[2] }); // Here we use 1 token to prioritise the query
        assert.equal(3, await queueSystemInstance.getQueueLength(), 'Permanent Query not enqueued.');
        assert.equal(0, await userInstance.getTokenBalance(accounts[2]), 'Tokens not deducted.'); // Verify deduction of tokens after use
        await queueSystemInstance.pop();
        let lineage1 = "DELETE FROM schema0.table0; ";
        assert.equal(lineage1, await dataLineageInstance.getLineage(datasetName1), "Incorrect data lineage returned for schema0.table0.");

        // We'll add another query to show the full lineage if there is a child table
        permQuery = "CREATE TABLE schema0.table1 AS SELECT * FROM schema0.table0"; // Query that makes a permanent change to the system
        datasetName2 = "schema0.table1";
        await queryDatasetInstance.runQuery(datasetName2, permQuery, datasetName2, datasetName1, 0, 0, { from: accounts[2] }); // Here we use 1 token to prioritise the query
        
        // As we are out of tokens, we have to empty the queue in order to get the permanent query to run
        await queueSystemInstance.pop();
        await queueSystemInstance.pop();
        await queueSystemInstance.pop();
        assert.equal("DELETE FROM schema0.table0; CREATE TABLE schema0.table1 AS SELECT * FROM schema0.table0; ", 
        await dataLineageInstance.getLineage(datasetName2), "Incorrect data lineage returned for schema0.table1.");
    });

    it("11) Search metadata and show data lineage", async () => {
        // To search, we will use the search functions in the metadata contract,
        // then pass the results to data lineage in order to fetch the full lineage
        let lineage1 = "DELETE FROM schema0.table0; ";
        let metadata1 = "Title: test-title; Description: test-desc; Category: test-cat; Tags: test-tag,; Date Updated: ".concat(ts.toString()).concat("; Owner: acc1");
        let catID = await metadataInstance.getCategoryID.call('test-cat');
        let tagID = await metadataInstance.getTagID.call('test-tag');
        const res = await metadataInstance.searchByTag.call(catID, [tagID]);
        for (let i = 0; i < res.length; i++) {
            ele = res[i];
            let name = await metadataInstance.getMetadataName.call(ele);
            assert.equal(lineage1, await dataLineageInstance.getLineage(name));
            assert.equal(metadata1, await metadataInstance.getMetadata(name))
        }
    });
});