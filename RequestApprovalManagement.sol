pragma solidity ^0.5.0;
import "./User.sol";
import "./Permissions.sol";
import "./Roles.sol";
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
        addDatasetToRoleRequest,
        removeDatasetFromRoleRequest,
        addUserToRoleRequest,
        removeUserFromRoleRequest
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
        string permissionName;
        uint256 roleID; 
        uint256 permissionID;
        uint256 userID;
    }

    User userContract;
    Permissions permissionsContract;
    Roles rolesContract;   

    mapping(uint256 => Request) public requestsMapping;

    uint256 totalNumberOfRequest;

    constructor(User userAddress, Permissions permissionsAddress, Roles rolesAddress) public {
        userContract = userAddress;
        permissionsContract = permissionsAddress;
        rolesContract = rolesAddress;
        totalNumberOfRequest = 0;
    }

    // Admin functions
    function approveRequest(uint256 requestID) public {
        if (requestsMapping[requestID].requestType == requestTypeEnum.createNewRoleRequest) {

            createNewRole(requestsMapping[requestID].roleName);

        } else if (requestsMapping[requestID].requestType == requestTypeEnum.removeRoleRequest) {

            removeRole(requestsMapping[requestID].roleID,requestsMapping[requestID].userID);

        } else if (requestsMapping[requestID].requestType == requestTypeEnum.addDatasetToRoleRequest) {

            addDatasetToRoles(requestsMapping[requestID].permissionName, requestsMapping[requestID].roleID);

        } else if (requestsMapping[requestID].requestType == requestTypeEnum.removeDatasetFromRoleRequest) {

            removeDatasetFromRoles(requestsMapping[requestID].permissionID, requestsMapping[requestID].roleID);

        } else if (requestsMapping[requestID].requestType == requestTypeEnum.addUserToRoleRequest) {

            addUsersToRoles(requestsMapping[requestID].userID, requestsMapping[requestID].roleID);

        } else if (requestsMapping[requestID].requestType == requestTypeEnum.removeUserFromRoleRequest) {

            removeUsersFromRoles(requestsMapping[requestID].userID, requestsMapping[requestID].roleID);

        }

        requestsMapping[requestID].updatedDateTime = block.timestamp;
        requestsMapping[requestID].adminAddress = msg.sender;
        requestsMapping[requestID].requestStatus = statusEnum.approved;
    }

    function rejectRequest(uint256 requestID, string memory adminAdditionalRemarks) public {
        requestsMapping[requestID].adminAdditionalRemarks = adminAdditionalRemarks;
        requestsMapping[requestID].requestStatus = statusEnum.rejected;
    }

    // Creating Requests

    function createNewRoleRequest(string memory roleName) public {
        Request memory newRequest = Request(msg.sender, address(0), statusEnum.pending, requestTypeEnum.createNewRoleRequest, block.timestamp,block.timestamp, "", roleName, "", 0,0,0);
        requestsMapping[totalNumberOfRequest] = newRequest;
        totalNumberOfRequest = totalNumberOfRequest + 1;
    }

    function removeRoleRequest(uint256 roleID, uint256 userID) public {
        Request memory newRequest = Request(msg.sender, address(0), statusEnum.pending, requestTypeEnum.createNewRoleRequest, block.timestamp,block.timestamp, "", "", "", roleID,0,userID);
        requestsMapping[totalNumberOfRequest] = newRequest;
        totalNumberOfRequest = totalNumberOfRequest + 1;
    }

    function addDatasetToRolesRequest(string memory permissionName, uint256 roleID) public {
        Request memory newRequest = Request(msg.sender, address(0), statusEnum.pending, requestTypeEnum.createNewRoleRequest, block.timestamp,block.timestamp, "", "", permissionName, roleID,0,0);
        requestsMapping[totalNumberOfRequest] = newRequest;
        totalNumberOfRequest = totalNumberOfRequest + 1;
    }

    function removeDatasetFromRolesRequest(uint256 permissionID, uint256 roleID) public {
        Request memory newRequest = Request(msg.sender, address(0), statusEnum.pending, requestTypeEnum.createNewRoleRequest, block.timestamp,block.timestamp, "", "", "", roleID, permissionID,0);
        requestsMapping[totalNumberOfRequest] = newRequest;
        totalNumberOfRequest = totalNumberOfRequest + 1;
    }

    function addUsersToRolesRequest(uint256 userID, uint256 roleID) public {
        Request memory newRequest = Request(msg.sender, address(0), statusEnum.pending, requestTypeEnum.createNewRoleRequest, block.timestamp,block.timestamp, "", "", "", roleID, 0, userID);
        requestsMapping[totalNumberOfRequest] = newRequest;
        totalNumberOfRequest = totalNumberOfRequest + 1;
    }

    function removeUsersFromRolesRequest(uint256 userID, uint256 roleID) public {
        Request memory newRequest = Request(msg.sender, address(0), statusEnum.pending, requestTypeEnum.createNewRoleRequest, block.timestamp,block.timestamp, "", "", "", roleID, 0, userID);
        requestsMapping[totalNumberOfRequest] = newRequest;
        totalNumberOfRequest = totalNumberOfRequest + 1;
    }


    // Getters


    function getRequestStatus(uint256 requestID) public returns(requestTypeEnum) {
        return requestsMapping[requestID].requestType;
    }

    function getRequestAdminRemarks(uint256 requestID) public returns(string memory) {
        return requestsMapping[requestID].adminAdditionalRemarks;
    }



    // Helper functions
    
    function createNewRole(string memory roleName) public {
        // Role Creation
        rolesContract.createRole(roleName);
    }

    function removeRole(uint256 roleID, uint256 userID) public {
        //  Remove role
        rolesContract.removeRoleUser(roleID, userID);
    }

    function addDatasetToRoles(string memory permissionName, uint256 roleID) public {
         // Create Permissions
        uint256 permissionID = permissionsContract.createPermission(permissionName);
        // Give Permission to role
        permissionsContract.givePermissionRole(permissionID, roleID);
        // Give role to permission
        rolesContract.giveRolePermission(roleID, permissionID); 
    }

    function removeDatasetFromRoles(uint256 permissionID, uint256 roleID) public {
        // Remove Permission to role
        permissionsContract.removePermissionRole(permissionID, roleID); 
        // Remove role to permission
        rolesContract.removeRolePermission(roleID, permissionID); 
    }

    function addUsersToRoles(uint256 userID, uint256 roleID) public {
        // Give user to role
        rolesContract.giveRoleUser(roleID, userID);
        // Give role to user
        userContract.giveUserRole(userID, roleID);
    }

    function removeUsersFromRoles(uint256 userID, uint256 roleID) public {
        // Remove user from role
        rolesContract.removeRoleUser(roleID, userID);
        // Remove role from user
        userContract.removeUserRole(userID, roleID);
    }



}
