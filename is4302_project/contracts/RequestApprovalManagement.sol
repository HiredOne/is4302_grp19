pragma solidity ^0.5.0;

import "./User.sol";
import "./Permission.sol";
import "./Role.sol";
import "./DatasetUploader.sol";

// import "hardhat/console.sol";

contract RequestApprovalManagement {
    enum statusEnum {
        pending,
        approved,
        rejected
    }

    enum requestTypeEnum {
        createNewRoleRequest,
        addExistingDatasetToRoleRequest,
        removeDatasetFromRoleRequest,
        addUserToRoleRequest,
        removeUserFromRoleRequest,
        uploadDatasetToNewRoleRequest,
        uploadDatasetToExistingRoleRequest
    }

    struct Request {
        address requesterAddress;
        address adminAddress;
        statusEnum requestStatus;
        requestTypeEnum requestType;
        uint256 creationDateTime;
        uint256 updatedDateTime;
        string roleName;
        string datasetIdentifier;
        uint256 roleID; 
        uint256 permissionID;
        address userID;
        string permissionName;
    }

    User userContract;
    Permission permissionContract;
    Role roleContract;   
    DatasetUploader datasetuploaderContract;  

    mapping(uint256 => Request) public requestsMapping;

    uint256 totalNumberOfRequest;

    event createNewRoleRequestApproved(string roleName);
    event removeRoleRequestApproved(uint256 roleID, address userID);
    event addExistingDatasetToRolesRequestApproved(uint256 permissionID, uint256 roleID);
    event removeDatasetFromRolesRequestApproved(uint256 permissionID, uint256 roleID);
    event addUsersToRolesRequestApproved(address userID, uint256 roleID);
    event removeUsersFromRolesRequestApproved(address userID, uint256 roleID);
    event uploadDatasetToNewRoleRequestApproved(string datasetIdentifier, string roleName, string pointer, address requestor, string permissionName);
    event uploadDatasetToExistingRoleRequestApproved(string datasetIdentifier, uint256 roleID, string pointer, address requestor, string permissionName);

    event rejectRequestEvent(uint256 requestID);

    string latestPointerGenerated;

    constructor(User userAddress, Permission permissionAddress, Role roleAddress, DatasetUploader datasetUploaderAddress) public {
        userContract = userAddress;
        permissionContract = permissionAddress;
        roleContract = roleAddress;
        datasetuploaderContract = datasetUploaderAddress;
        totalNumberOfRequest = 0;
    }

    // Admin functions
    function approveRequest(uint256 requestID) public {
        if (requestsMapping[requestID].requestType == requestTypeEnum.createNewRoleRequest) {

            createNewRole(requestsMapping[requestID].roleName);

        } else if (requestsMapping[requestID].requestType == requestTypeEnum.addExistingDatasetToRoleRequest) {

            addExistingDatasetToRole(requestsMapping[requestID].permissionID, requestsMapping[requestID].roleID);

        } else if (requestsMapping[requestID].requestType == requestTypeEnum.removeDatasetFromRoleRequest) {

            removeDatasetFromRole(requestsMapping[requestID].permissionID, requestsMapping[requestID].roleID);

        } else if (requestsMapping[requestID].requestType == requestTypeEnum.addUserToRoleRequest) {

            addUsersToRole(requestsMapping[requestID].userID, requestsMapping[requestID].roleID);

        } else if (requestsMapping[requestID].requestType == requestTypeEnum.removeUserFromRoleRequest) {

            removeUsersFromRole(requestsMapping[requestID].userID, requestsMapping[requestID].roleID);

        } else if (requestsMapping[requestID].requestType == requestTypeEnum.uploadDatasetToNewRoleRequest) {

            uploadDatasetToNewRole(requestsMapping[requestID].datasetIdentifier, requestsMapping[requestID].roleName, requestsMapping[requestID].requesterAddress, requestsMapping[requestID].permissionName);

        } else if (requestsMapping[requestID].requestType == requestTypeEnum.uploadDatasetToExistingRoleRequest) {

            uploadDatasetToExistingRole(requestsMapping[requestID].datasetIdentifier, requestsMapping[requestID].roleID, requestsMapping[requestID].requesterAddress, requestsMapping[requestID].permissionName, requestsMapping[requestID].permissionID);

        }       

        requestsMapping[requestID].updatedDateTime = block.timestamp;
        requestsMapping[requestID].adminAddress = msg.sender;
        requestsMapping[requestID].requestStatus = statusEnum.approved;
    }

    function rejectRequest(uint256 requestID) public {
        requestsMapping[requestID].requestStatus = statusEnum.rejected;
        emit rejectRequestEvent(requestID);
    }

    // Creating Requests

    function createNewRoleRequest(string memory roleName) public {
        Request memory newRequest = Request(msg.sender, address(0), statusEnum.pending, requestTypeEnum.createNewRoleRequest, block.timestamp,block.timestamp, roleName, "", 0,0,address(0), "");
        requestsMapping[totalNumberOfRequest] = newRequest;
        totalNumberOfRequest = totalNumberOfRequest + 1;
    }

    function addExistingDatasetToRoleRequest(uint256 permissionID, uint256 roleID) public {
        Request memory newRequest = Request(msg.sender, address(0), statusEnum.pending, requestTypeEnum.addExistingDatasetToRoleRequest, block.timestamp,block.timestamp, "", "", roleID,permissionID,address(0), "");
        requestsMapping[totalNumberOfRequest] = newRequest;
        totalNumberOfRequest = totalNumberOfRequest + 1;
    }

    function removeDatasetFromRoleRequest(uint256 permissionID, uint256 roleID) public {
        Request memory newRequest = Request(msg.sender, address(0), statusEnum.pending, requestTypeEnum.removeDatasetFromRoleRequest, block.timestamp,block.timestamp, "", "", roleID, permissionID,address(0), "");
        requestsMapping[totalNumberOfRequest] = newRequest;
        totalNumberOfRequest = totalNumberOfRequest + 1;
    }

    function addUsersToRoleRequest(address userID, uint256 roleID) public {
        Request memory newRequest = Request(msg.sender, address(0), statusEnum.pending, requestTypeEnum.addUserToRoleRequest, block.timestamp,block.timestamp, "", "", roleID, 0, userID, "");
        requestsMapping[totalNumberOfRequest] = newRequest;
        totalNumberOfRequest = totalNumberOfRequest + 1;
    }

    function removeUsersFromRoleRequest(address userID, uint256 roleID) public {
        Request memory newRequest = Request(msg.sender, address(0), statusEnum.pending, requestTypeEnum.removeUserFromRoleRequest , block.timestamp,block.timestamp, "", "", roleID, 0, userID, "");
        requestsMapping[totalNumberOfRequest] = newRequest;
        totalNumberOfRequest = totalNumberOfRequest + 1;
    }

    function uploadDatasetToNewRoleRequest(string memory datasetIdentifier, string memory roleName, string memory permissionName) public {
        Request memory newRequest = Request(msg.sender, address(0), statusEnum.pending, requestTypeEnum.uploadDatasetToNewRoleRequest , block.timestamp,block.timestamp, roleName, datasetIdentifier, 0, 0, address(0), permissionName);
        requestsMapping[totalNumberOfRequest] = newRequest;
        totalNumberOfRequest = totalNumberOfRequest + 1;
    }

    function uploadDatasetToExistingRoleRequest(string memory datasetIdentifier, uint256 roleID, string memory permissionName, uint256 permissionID) public {
        Request memory newRequest = Request(msg.sender, address(0), statusEnum.pending, requestTypeEnum.uploadDatasetToExistingRoleRequest , block.timestamp,block.timestamp, "", datasetIdentifier, roleID, permissionID, address(0), permissionName);
        requestsMapping[totalNumberOfRequest] = newRequest;
        totalNumberOfRequest = totalNumberOfRequest + 1;
    }


    // Getters

    function getRequestStatus(uint256 requestID) public view returns(requestTypeEnum) {
        return requestsMapping[requestID].requestType;
    }

    function getTotalNumberOfRequests() public view returns(uint256) {
        return totalNumberOfRequest;
    }

    function getLatestPointerGenerated() public view returns(string memory) {
        return latestPointerGenerated;
    }



    // Helper functions
    
    function createNewRole(string memory roleName) public {
        // Role Creation
        roleContract.createRole(roleName);

        emit createNewRoleRequestApproved(roleName);
    }

    function addExistingDatasetToRole(uint256 permissionID, uint256 roleID) public {

        roleContract.assignPermission(roleID, permissionID);

        emit addExistingDatasetToRolesRequestApproved(permissionID, roleID);
    }

    function removeDatasetFromRole(uint256 permissionID, uint256 roleID) public {
      
        roleContract.removePermission(roleID, permissionID); 
             
        emit removeDatasetFromRolesRequestApproved(permissionID, roleID);
    }

    function addUsersToRole(address userID, uint256 roleID) public {

        roleContract.giveUserRole(userID, roleID);

        emit addUsersToRolesRequestApproved(userID, roleID);
    }

    function removeUsersFromRole(address userID, uint256 roleID) public {

        roleContract.removeUserRole(userID, roleID);

        emit removeUsersFromRolesRequestApproved(userID, roleID);
    }

    function uploadDatasetToNewRole(string memory datasetIdentifier, string memory roleName, address requestor, string memory permissionName) public{
     
        //  This pointer is a simulation --> This by right links to external DB
        //  We are now simulating it by generating a random string of length 10
        string memory pointer = randomString(10);

        latestPointerGenerated = pointer;

        // Upload dataset
        datasetuploaderContract.uploadDatasetToNewRole(datasetIdentifier,roleName, pointer, requestor, permissionName);

        emit uploadDatasetToNewRoleRequestApproved(datasetIdentifier, roleName, pointer, requestor, permissionName);
    }

    function uploadDatasetToExistingRole(string memory datasetIdentifier, uint256 roleID, address requestor, string memory permissionName, uint256 permissionID) public{
        
        //  This pointer is a simulation --> This by right links to external DB
        //  We are now simulating it by generating a random string of length 10
        string memory pointer = randomString(10);

        latestPointerGenerated = pointer;

        // Upload dataset
        datasetuploaderContract.uploadDatasetToExistingRole(datasetIdentifier, roleID, pointer, requestor, permissionName,permissionID); 

        emit uploadDatasetToExistingRoleRequestApproved(datasetIdentifier, roleID, pointer, requestor, permissionName);
    }




    // Random String Generator
    string public letters = "abcdefghijklmnopqrstuvwxyz";
    // I needed to add this to the random function to generate a different random number
    uint counter =1;

    // size is length of word
    function randomString(uint size) public returns(string memory){
        bytes memory randomWord=new bytes(size);
        // since we have 26 letters
        bytes memory chars = new bytes(26);
        chars="abcdefghijklmnopqrstuvwxyz";
        for (uint i=0;i<size;i++){
            uint randomNumber=random(26);
            // Index access for string is not possible
            randomWord[i]=chars[randomNumber];
        }
        return string(randomWord);
    }

    function random(uint number) public returns(uint){
        counter++;
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender,counter))) % number;
    }


}
