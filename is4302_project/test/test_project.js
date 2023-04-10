const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions"); //npm i truffle-assertions
const BigNumber = require('bignumber.js'); // npm install bignumber.js
var assert = require("assert");

var User = artifacts.require("../contracts/User.sol");
var Permission = artifacts.require("../contracts/Permission.sol");
var Role = artifacts.require("../contracts/Role.sol");
var Metadata = artifacts.require("../contracts/Metadata.sol");
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
        dataLineageInstance = await DataLineage.deployed();
        datasetUploaderInstance = await DatasetUploader.deployed();
        requestApprovalManagementInstance = await RequestApprovalManagement.deployed();
        priorityQueueInstance = await PriorityQueue.deployed();
        queueSystemInstance = await QueueSystem.deployed();
        queryDatasetInstance = await QueryDataset.deployed();
    });

    console.log("Testing IS4302 Project");

    // During Deployment, 'DBAdmin' has been created --> accounts(0)

    it("1) Create user (acc1)", async () => {

        /*
            b) Create user (acc1)
        */

        // Check Create User
        assert.equal(1, await userInstance.getTotalNumberOfUsers(), "DBAdmin not created.");
        await userInstance.createUser("acc1" ,{ from: accounts[1] });
        assert.equal(2, await userInstance.getTotalNumberOfUsers(), "acc1 creation failed.");

        // Check that acc1 is normal user rights
        assert.equal(false, await userInstance.checkIsAdmin(accounts[1]), "acc1 is supposed to be a normal user.");       
    });

    // acc1 created -> User --> accounts[1]

    it("2) Create admin (acc2)", async () => {

        // Description
        /*
            a) Create user (acc2)
            b) Give user admin rights
        */

        // Test
        // Check Create User
        await userInstance.createUser("acc2" ,{ from: accounts[2] });
        assert.equal(3, await userInstance.getTotalNumberOfUsers(), "acc2 creation failed.");
                
        // Check Give acc2 admin rights
        await userInstance.giveAdmin(accounts[2] ,{ from: accounts[0] });
        assert.equal(true, await userInstance.checkIsAdmin(accounts[2]), "acc2 not given admin rights.");
    });

    // acc2 created -> Admin --> accounts[2]

    it("3) acc1 upload a dataset to a new role (role 0)", async () => {

        /*
            a) Submit new request to upload a dataset 
            b) Approve request
            c) Upload dataset
            d) Record dataset upload in DataLineage
            e) Create (permission0) for this dataset 
            f) Create (role0) 
            g) Assign (permission0) to (role0) 
        */

        assert.equal(0, await requestApprovalManagementInstance.getTotalNumberOfRequests(), "Empty system has requests.");
        
        // Create request to upload dataset to new role
        // Dataset identifier: datasetIdentifier
        // Role Name: role0
        // Permission Name: permission0
        // Permission ID: 0
        await requestApprovalManagementInstance.uploadDatasetToNewRoleRequest("schema0.table0", "role0", "permission0",{ from: accounts[1] });
        assert.equal(1, await requestApprovalManagementInstance.getTotalNumberOfRequests(), "Request not created successfully.");
        
        // Check that currently have no roles and permissions created yet
        assert.equal(0, await roleInstance.getNumRoles(), "Empty system has roles.");
        assert.equal(0, await permissionInstance.getNumPermissions(), "Empty system has permissions.");
        
        // Admin account approve request
        let requestApproved = await requestApprovalManagementInstance.approveRequest(0, { from: accounts[2] });

        // Check that request has been approved successfully
        truffleAssert.eventEmitted(requestApproved, "uploadDatasetToNewRoleRequestApproved", null, "Request not approved.");

        // Check if new role is created, new permissions is created and tokens issued successfully.
        assert.equal(1, await roleInstance.getNumRoles(), 'Role creation failed.');
        assert.equal(1, await permissionInstance.getNumPermissions(), 'Permission creation failed.');
        assert.equal(1, await userInstance.getTokenBalance(accounts[1]), "Token issuance failed");

        // Check if this process has been recorded in data lineage
        let pointerGenerated = await requestApprovalManagementInstance.getLatestPointerGenerated();
        let pointerStoredInLineage = await dataLineageInstance.getPointer('schema0.table0');
        assert.equal(pointerGenerated, pointerStoredInLineage, "Data upload did not get recorded in Datalineage");

    });

    // role0 created together with a new dataset (new permissions)

    it("4) Create a new role (role1)", async () => {

        /*
            a) Submit request new request to create new role
            b) Approve request
            c) Create role (role1)
        */

        // Create request to upload dataset to new role
        // Role Name: role1
        await requestApprovalManagementInstance.createNewRoleRequest("role1",{ from: accounts[1] });
        assert.equal(2, await requestApprovalManagementInstance.getTotalNumberOfRequests(), 'Role1 creation request not created.');
        
        // Check that currently have only 1 role that was previously created
        assert.equal(1, await roleInstance.getNumRoles());
        
        // Admin account approve request
        let requestApproved = await requestApprovalManagementInstance.approveRequest(1, { from: accounts[2] });

        // Check that request has been approved successfully
        truffleAssert.eventEmitted(requestApproved, "createNewRoleRequestApproved", null, message="Request not approved.");

        // Check if new role is created 
        assert.equal(2, await roleInstance.getNumRoles(), "Role1 creation failed.");
    });

    // role1 created

    it("5) Add permission0 to role1", async () => {   

        /*
            a) Submit request new request to add permission to role
            b) Approve request
            c) Assign (permission0) to (role1)
        */

        // Create request to upload dataset to new role
        // Permission ID: 0
        // Role ID: 1
        await requestApprovalManagementInstance.addExistingDatasetToRoleRequest(0, 1,{ from: accounts[2] });
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

    it("6) Add acc2 and acc1 to role1", async () => {

        /*
            a) Submit request new request to add user to role
            b) Approve request
            c) Assign role (role1) to user (acc2) and (acc1)
        */

        // Create request to add acc2 to role1
        // User address: accounts[2]
        // Role ID: 1
        await requestApprovalManagementInstance.addUsersToRoleRequest(accounts[2], 1,{ from: accounts[2] });
        assert.equal(4, await requestApprovalManagementInstance.getTotalNumberOfRequests(), "Request to add acc2 to role1 not successfully created.");
        
        // Check that currently there are no users is added to (role1)
        assert.equal(0, await roleInstance.numRolesGrantedToUser(accounts[2]), "role1 prematurely added to acc2.");
        
        // Admin account approve request
        let requestApproved = await requestApprovalManagementInstance.approveRequest(3, { from: accounts[0] });
        // Check that request has been approved successfully
        truffleAssert.eventEmitted(requestApproved, "addUsersToRolesRequestApproved", null, message='Request to add acc2 to role1 not approved.');
        // Check that currently both (acc2) is added to (role1)
        assert.equal(1, await roleInstance.numRolesGrantedToUser(accounts[2]), "role1 not added to acc1.");

        await requestApprovalManagementInstance.addUsersToRoleRequest(accounts[1], 1,{ from: accounts[1] });
        await requestApprovalManagementInstance.approveRequest(4, { from: accounts[0] });
        assert.equal(1, await roleInstance.numRolesGrantedToUser(accounts[1]), "role1 not added to acc1.");

    });

    /*
        == USERS ==
        acc2 -> Admin
        acc1 -> Normal user

        == ROLE ==
        role1

        == Dataset (PERMISSION) ==
        permission0
    */

    it("7) acc2 add metadata for permission0", async () => {

        /*
            a) Create new metadata category (test-cat) and tag (test-tag)
            b) Include new metadata category and tag inside the metadata to be
            added to permission0
            c) Verify metadata upload is successful
        */

        // Verify Metadata system is empty
        assert.equal(0, await metadataInstance.getNumDSetsCreated(), "Empty system has dataset records.");
        assert.equal(0, await metadataInstance.getNumCatsCreated(), "Empty system has categories created.");
        assert.equal(0, await metadataInstance.getNumTagsCreated(), "Empty system has tags created.");
        
        // Create category and tag (admin only)
        // Category Name: "test-cat"
        // Tag Name: "test-tag"
        // We use .call to get the results of these calls first for local use
        let catID = await metadataInstance.addCategory.call("test-cat", { from: accounts[2] }); 
        let tagID = await metadataInstance.addTag.call("test-tag", { from: accounts[2] }); 
        
        // Then we run the function normally so that the outcome is global
        await metadataInstance.addCategory("test-cat", { from: accounts[2] }); 
        await metadataInstance.addTag("test-tag", { from: accounts[2] });
        let tags = [tagID];
        assert.equal(1, await metadataInstance.getNumCatsCreated(), "test-cat creation failed.");
        assert.equal(1, await metadataInstance.getNumTagsCreated(), "test-tag creation failed.");
        
        // Add metadata
        // Object Name: "schema0.table0"
        // Title: "test-title"
        // Description: "test-desc"
        // Category ID: 1
        // Tags ID Array: [1]
        // Timestamp: Retrieved from global variable ts defined above
        // Owner: acc2
        // Permission ID: 0
        await metadataInstance.addMetadata("schema0.table0", "test-title", "test-desc", catID, tags, ts.toString(), "acc2", 0, { from: accounts[2] });
        let metadata = await metadataInstance.getMetadata("schema0.table0");
        assert.notEqual('', metadata, "Metadata upload failed");
        assert.equal(1, await userInstance.getTokenBalance(accounts[2]), "Tokens not issued for update");

    });

    // (acc2) receives one token

    it("8) Submitting non-permanent Query", async () => {

        /* 
            a) Create query
            b) Submit query for verification
            c) Enqueue query
        */

        // Query: "SELECT column0 FROM schema0.table0"
        // Dataset Name: "schema0.table0"
        let query = "SELECT column0 FROM schema0.table0";
        let datasetName = "schema0.table0";
        // We use .call to get the results of these calls first for local use
        let outcome = await queryDatasetInstance.runQuery.call(datasetName, query, datasetName, "nil", 0, 0, { from: accounts[2] })
        await queryDatasetInstance.runQuery(datasetName, query, "0", "nil", 0, 0, { from: accounts[2] })
        assert.equal(true, outcome, 'Query verification failed.');
        assert.equal(1, await queueSystemInstance.getQueueLength(), 'Query not enqueued.');
    });

    /*
        Query submitted to (queueSystem)
        QueueSystem length == 1
    */

    it("9) Test priority", async () =>{
       
        /*
            a) Create a second query with priority 1 (1 token)
            c) Verify that query2 comes to the head of the queue since the 
            first query has a priority of 0
        */

        // Create queries, then submit for verification
        // Query2: "SELECT column1 FROM schema0.table0"
        // Dataset Name: "schema0.table0"
        let query2 = "SELECT column1 FROM schema0.table0";
        let datasetName1 = "schema0.table0";
        await queryDatasetInstance.runQuery(datasetName1, query2, datasetName1, "nil", 1, 0, { from: accounts[1] });
        assert.equal(2, await queueSystemInstance.getQueueLength(), 'Second Query not enqueued.');
        assert.equal(0, await userInstance.getTokenBalance(accounts[1]), 'Tokens not deducted.'); // Verify deduction of tokens after use

        let outcome = await queueSystemInstance.pop(); // The first query should now be query2.
        truffleAssert.eventEmitted(outcome, 'queryExecuted', {
            query : "SELECT column1 FROM schema0.table0"
        }, 'Query not prioritised');
        assert.equal(1, await queueSystemInstance.getQueueLength(), "Query not deleted after execution.");

        // Empty previous queries
        await queueSystemInstance.pop();
    });

    /*
        Query2 submitted to (queueSystem)
        Query2 popped from queueSystem
        QueueSystem length == 1
    */

    it("10) Submitting a permanent query", async () => {
        
        /*
            a) Create 2 permanent queries
            b) Enqueue first permanent query with 1 token
            c) Enqueue second permanent query with 0 tokens
            d) Execute first permanent query
            e) Verify data lineage after execution of first query
            f) Execute second permanent query
            g) Verify data lineage after execution of second query
        */
                
        // Create permanent queries
        // Dataset Name 1: "schema0.table0"
        // Dataset Name 2: "schema0.table1"
        // Permanent Query 1: "DELETE FROM schema0.table0"
        // Permanent Query 2: "CREATE TABLE schema0.table1 AS SELECT * FROM schema0.table0"
        let datasetName1 = "schema0.table0"; 
        let permQuery = "DELETE FROM schema0.table0"; // First query
        let datasetName2 = "schema0.table1";
        let permQuery2 = "CREATE TABLE schema0.table1 AS SELECT * FROM schema0.table0"; // Second query

        // Enqueue queries
        await queryDatasetInstance.runQuery(datasetName1, permQuery, datasetName1, "nil", 1, 0, { from: accounts[2] }); // Prioritise with 1 token
        assert.equal(1, await queueSystemInstance.getQueueLength(), 'First Query not enqueued.');
        await queryDatasetInstance.runQuery(datasetName2, permQuery2, datasetName2, datasetName1, 0, 0, { from: accounts[1] });
        assert.equal(2, await queueSystemInstance.getQueueLength(), 'Second Query not enqueued.');

        // Execute first query
        assert.equal(0, await userInstance.getTokenBalance(accounts[2]), 'Tokens not deducted.'); // Verify deduction of tokens after use
        await queueSystemInstance.pop();
        // Verify data lineage after execution of first query
        let lineage1 = "DELETE FROM schema0.table0; ";
        assert.equal(lineage1, await dataLineageInstance.getLineage(datasetName1), "Incorrect data lineage returned for schema0.table0.");

        // Execute second query
        await queryDatasetInstance.runQuery(datasetName2, permQuery2, datasetName2, datasetName1, 0, 0, { from: accounts[1] });
        await queueSystemInstance.pop();
        // Verify data lineage after execution of second query
        let lineage2 = "DELETE FROM schema0.table0; CREATE TABLE schema0.table1 AS SELECT * FROM schema0.table0; "
        assert.equal(lineage2, await dataLineageInstance.getLineage(datasetName2), "Incorrect data lineage returned for schema0.table1.");
    });

    /*
        Lineage of schema0.table0: "DELETE FROM schema0.table0; "
        Lineage of schema0.table1: "DELETE FROM schema0.table0; CREATE TABLE schema0.table1 AS SELECT * FROM schema0.table0; "
    */

    it("11) Search metadata and show data lineage", async () => {

        /*
            a) Get test-cat and test-tag IDs
            b) Search using test-cat and test-tag IDs
            c) Pass search results obtained to data lineage in order to fetch
            the full data lineage
            d) Pass search results obtained to metadata, in order to fetch the
            result's metadata
        */

        let lineage1 = "DELETE FROM schema0.table0; ";
        let metadata1 = "Title: test-title; Description: test-desc; Category: test-cat; Tags: test-tag,; Date Updated: ".concat(ts.toString()).concat("; Owner: acc2");
        
        // Get test-cat and test-tag IDs
        let catID = await metadataInstance.getCategoryID.call('test-cat');
        let tagID = await metadataInstance.getTagID.call('test-tag');

        // Search using category id and tag id obtained
        var res = await metadataInstance.searchByTag.call(catID, [tagID]);
        assert.equal(1, res.length, 'Incorrect number of search results returned');
        let ele = res[0];
        let name = await metadataInstance.getMetadataName.call(ele);

        // Obtain lineage and metadata using search results obtained
        assert.equal(lineage1, await dataLineageInstance.getLineage(name), 'Incorrect lineage returned');
        assert.equal(metadata1, await metadataInstance.getMetadata(name), ' Incorrect metadata returned');
    });
});