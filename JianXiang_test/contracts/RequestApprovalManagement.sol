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
        removeRoleRequest,
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
        string adminAdditionalRemarks;
        string roleName;
        string datasetIdentifier;
        uint256 roleID; 
        uint256 permissionID;
        address userID;
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
    event uploadDatasetToNewRoleRequestApproved(string datasetIdentifier, string roleName, address requestor);
    event uploadDatasetToExistingRoleRequestApproved(string datasetIdentifier, uint256 roleID, address requestor);

    event rejectRequestEvent(uint256 requestID, string adminAdditionalRemarks);

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

        } else if (requestsMapping[requestID].requestType == requestTypeEnum.removeRoleRequest) {

            removeRole(requestsMapping[requestID].roleID,requestsMapping[requestID].userID);

        } else if (requestsMapping[requestID].requestType == requestTypeEnum.addExistingDatasetToRoleRequest) {

            addExistingDatasetToRole(requestsMapping[requestID].permissionID, requestsMapping[requestID].roleID);

        } else if (requestsMapping[requestID].requestType == requestTypeEnum.removeDatasetFromRoleRequest) {

            removeDatasetFromRole(requestsMapping[requestID].permissionID, requestsMapping[requestID].roleID);

        } else if (requestsMapping[requestID].requestType == requestTypeEnum.addUserToRoleRequest) {

            addUsersToRole(requestsMapping[requestID].userID, requestsMapping[requestID].roleID);

        } else if (requestsMapping[requestID].requestType == requestTypeEnum.removeUserFromRoleRequest) {

            removeUsersFromRole(requestsMapping[requestID].userID, requestsMapping[requestID].roleID);

        } else if (requestsMapping[requestID].requestType == requestTypeEnum.uploadDatasetToNewRoleRequest) {

            uploadDatasetToNewRole(requestsMapping[requestID].datasetIdentifier, requestsMapping[requestID].roleName, requestsMapping[requestID].requesterAddress);

        } else if (requestsMapping[requestID].requestType == requestTypeEnum.uploadDatasetToExistingRoleRequest) {

            uploadDatasetToExistingRole(requestsMapping[requestID].datasetIdentifier, requestsMapping[requestID].roleID, requestsMapping[requestID].requesterAddress);

        }       

        requestsMapping[requestID].updatedDateTime = block.timestamp;
        requestsMapping[requestID].adminAddress = msg.sender;
        requestsMapping[requestID].requestStatus = statusEnum.approved;
    }

    function rejectRequest(uint256 requestID, string memory adminAdditionalRemarks) public {
        requestsMapping[requestID].adminAdditionalRemarks = adminAdditionalRemarks;
        requestsMapping[requestID].requestStatus = statusEnum.rejected;
        emit rejectRequestEvent(requestID, adminAdditionalRemarks);
    }

    // Creating Requests

    function createNewRoleRequest(string memory roleName) public {
        Request memory newRequest = Request(msg.sender, address(0), statusEnum.pending, requestTypeEnum.createNewRoleRequest, block.timestamp,block.timestamp, "", roleName, "", 0,0,address(0));
        requestsMapping[totalNumberOfRequest] = newRequest;
        totalNumberOfRequest = totalNumberOfRequest + 1;
    }

    function removeRoleRequest(uint256 roleID, address userID) public {
        Request memory newRequest = Request(msg.sender, address(0), statusEnum.pending, requestTypeEnum.removeRoleRequest, block.timestamp,block.timestamp, "", "", "", roleID,0,userID);
        requestsMapping[totalNumberOfRequest] = newRequest;
        totalNumberOfRequest = totalNumberOfRequest + 1;
    }

    function addExistingDatasetToRoleRequest(uint256 permissionID, uint256 roleID) public {
        Request memory newRequest = Request(msg.sender, address(0), statusEnum.pending, requestTypeEnum.addExistingDatasetToRoleRequest, block.timestamp,block.timestamp, "", "", "", roleID,permissionID,address(0));
        requestsMapping[totalNumberOfRequest] = newRequest;
        totalNumberOfRequest = totalNumberOfRequest + 1;
    }

    function removeDatasetFromRoleRequest(uint256 permissionID, uint256 roleID) public {
        Request memory newRequest = Request(msg.sender, address(0), statusEnum.pending, requestTypeEnum.removeDatasetFromRoleRequest, block.timestamp,block.timestamp, "", "", "", roleID, permissionID,address(0));
        requestsMapping[totalNumberOfRequest] = newRequest;
        totalNumberOfRequest = totalNumberOfRequest + 1;
    }

    function addUsersToRoleRequest(address userID, uint256 roleID) public {
        Request memory newRequest = Request(msg.sender, address(0), statusEnum.pending, requestTypeEnum.addUserToRoleRequest, block.timestamp,block.timestamp, "", "", "", roleID, 0, userID);
        requestsMapping[totalNumberOfRequest] = newRequest;
        totalNumberOfRequest = totalNumberOfRequest + 1;
    }

    function removeUsersFromRoleRequest(address userID, uint256 roleID) public {
        Request memory newRequest = Request(msg.sender, address(0), statusEnum.pending, requestTypeEnum.removeUserFromRoleRequest , block.timestamp,block.timestamp, "", "", "", roleID, 0, userID);
        requestsMapping[totalNumberOfRequest] = newRequest;
        totalNumberOfRequest = totalNumberOfRequest + 1;
    }

    function uploadDatasetToNewRoleRequest(string memory datasetIdentifier, string memory roleName) public {
        Request memory newRequest = Request(msg.sender, address(0), statusEnum.pending, requestTypeEnum.uploadDatasetToNewRoleRequest , block.timestamp,block.timestamp, "", roleName, datasetIdentifier, 0, 0, address(0));
        requestsMapping[totalNumberOfRequest] = newRequest;
        totalNumberOfRequest = totalNumberOfRequest + 1;
    }

    function uploadDatasetToExistingRoleRequest(string memory datasetIdentifier, uint256 roleID) public {
        Request memory newRequest = Request(msg.sender, address(0), statusEnum.pending, requestTypeEnum.uploadDatasetToExistingRoleRequest , block.timestamp,block.timestamp, "", "", datasetIdentifier, roleID, 0, address(0));
        requestsMapping[totalNumberOfRequest] = newRequest;
        totalNumberOfRequest = totalNumberOfRequest + 1;
    }


    // Getters

    function getRequestStatus(uint256 requestID) public view returns(requestTypeEnum) {
        return requestsMapping[requestID].requestType;
    }

    function getRequestAdminRemarks(uint256 requestID) public view returns(string memory) {
        return requestsMapping[requestID].adminAdditionalRemarks;
    }

    function getTotalNumberOfRequests() public view returns(uint256) {
        return totalNumberOfRequest;
    }



    // Helper functions
    
    function createNewRole(string memory roleName) public {
        // // Role Creation
        // roleContract.createRole(roleName);

        emit createNewRoleRequestApproved(roleName);
    }

    function removeRole(uint256 roleID, address userID) public {
        // //  Remove role
        // roleContract.removeRoleUser(roleID, userID);

        emit removeRoleRequestApproved(roleID, userID);
    }

    function addExistingDatasetToRole(uint256 permissionID, uint256 roleID) public {
        // // Give Permission to role
        // permissionContract.givePermissionRole(permissionID, roleID);
        // // Give role to permission
        // roleContract.giveRolePermission(roleID, permissionID); 

        emit addExistingDatasetToRolesRequestApproved(permissionID, roleID);
    }

    function removeDatasetFromRole(uint256 permissionID, uint256 roleID) public {
        // // Remove Permission to role
        // permissionContract.removePermissionRole(permissionID, roleID); 
        // // Remove role to permission
        // roleContract.removeRolePermission(roleID, permissionID); 
        
        emit removeDatasetFromRolesRequestApproved(permissionID, roleID);
    }

    function addUsersToRole(address userID, uint256 roleID) public {
        // // Give user to role
        // roleContract.giveRoleUser(roleID, userID);
        // // Give role to user
        // userContract.giveUserRole(userID, roleID);

        emit addUsersToRolesRequestApproved(userID, roleID);
    }

    function removeUsersFromRole(address userID, uint256 roleID) public {
        // // Remove user from role
        // roleContract.removeRoleUser(roleID, userID);
        // // Remove role from user
        // userContract.removeUserRole(userID, roleID);

        emit removeUsersFromRolesRequestApproved(userID, roleID);
    }

    function uploadDatasetToNewRole(string memory datasetIdentifier, string memory roleName, address requestor) public {
     
        // // Upload dataset
        // datasetuploaderContract.uploadDataset(datasetIdentifier, 0, roleName,requestor);

        emit uploadDatasetToNewRoleRequestApproved(datasetIdentifier, roleName, requestor);
    }

    function uploadDatasetToExistingRole(string memory datasetIdentifier, uint256 roleID, address requestor) public {

        // // Upload dataset
        // datasetuploaderContract.uploadDataset(datasetIdentifier, roleID, "",requestor); 

        emit uploadDatasetToExistingRoleRequestApproved(datasetIdentifier, roleID, requestor);
    }


}
