pragma solidity ^0.5.0;

// import "hardhat/console.sol";

contract RequestApprovalManagement {
    enum statusEnum {
        pending,
        approved,
        rejected
    }

    struct CreateNewRoleRequest {
        address requesterAddress;
        address adminAddress;
        statusEnum requestStatus;
        uint256 creationDateTime;
        uint256 updatedDateTime;
        string adminAdditionalRemarks;
    }

    struct RemoveRoleRequest {
        address requesterAddress;
        address adminAddress;
        statusEnum requestStatus;
        uint256 creationDateTime;
        uint256 updatedDateTime;
        string adminAdditionalRemarks;
    }

    struct AddDatasetToRoleRequest {
        address requesterAddress;
        address adminAddress;
        statusEnum requestStatus;
        uint256 creationDateTime;
        uint256 updatedDateTime;
        string adminAdditionalRemarks;
    }

    struct RemoveDatasetFromRoleRequest {
        address requesterAddress;
        address adminAddress;
        statusEnum requestStatus;
        uint256 creationDateTime;
        uint256 updatedDateTime;
        string adminAdditionalRemarks;
    }

    struct AddUserToRoleRequest {
        address requesterAddress;
        address adminAddress;
        statusEnum requestStatus;
        uint256 creationDateTime;
        uint256 updatedDateTime;
        string adminAdditionalRemarks;
    }

    struct RemoveUserFromRoleRequest {
        address requesterAddress;
        address adminAddress;
        statusEnum requestStatus;
        uint256 creationDateTime;
        uint256 updatedDateTime;
        string adminAdditionalRemarks;
    }

    mapping(uint256 => CreateNewRoleRequest) public createNewRoleRequestMapping;
    mapping(uint256 => RemoveRoleRequest) public removeRoleRequestMapping;
    mapping(uint256 => AddDatasetToRoleRequest) public addDatasetToRoleRequestMapping;
    mapping(uint256 => RemoveDatasetFromRoleRequest) public removeDatasetFromRoleRequestMapping;
    mapping(uint256 => AddUserToRoleRequest) public addUserToRoleRequestMapping;
    mapping(uint256 => RemoveUserFromRoleRequest) public removeUserFromRoleRequestMapping;

    uint256 totalNumberOfRequest;

    constructor() public {}

    // Admin functions
    function approveRequest(uint256 requestId) public {

        if (createNewRoleRequestMapping[requestId].requesterAddress != address(0)) {

        } else if (removeRoleRequestMapping[requestId].requesterAddress != address(0)) {

        } else if (addDatasetToRoleRequestMapping[requestId].requesterAddress != address(0)) {

        } else if (removeDatasetFromRoleRequestMapping[requestId].requesterAddress != address(0)) {

        } else if (addUserToRoleRequestMapping[requestId].requesterAddress != address(0)) {

        } else if (removeUserFromRoleRequestMapping[requestId].requesterAddress != address(0)) {

        }
    }

    function rejectRequest(uint256 requestId, string memory adminAdditionalRemarks) public {

        if (createNewRoleRequestMapping[requestId].requesterAddress != address(0)) {
            createNewRoleRequestMapping[requestId].adminAdditionalRemarks = adminAdditionalRemarks;
            createNewRoleRequestMapping[requestId].requestStatus = statusEnum.rejected;

        } else if (removeRoleRequestMapping[requestId].requesterAddress != address(0)) {
            removeRoleRequestMapping[requestId].adminAdditionalRemarks = adminAdditionalRemarks;
            removeRoleRequestMapping[requestId].requestStatus = statusEnum.rejected;

        } else if (addDatasetToRoleRequestMapping[requestId].requesterAddress != address(0)) {
            addDatasetToRoleRequestMapping[requestId].adminAdditionalRemarks = adminAdditionalRemarks;
            addDatasetToRoleRequestMapping[requestId].requestStatus = statusEnum.rejected;

        } else if (removeDatasetFromRoleRequestMapping[requestId].requesterAddress != address(0)) {
            removeDatasetFromRoleRequestMapping[requestId].adminAdditionalRemarks = adminAdditionalRemarks;
            removeDatasetFromRoleRequestMapping[requestId].requestStatus = statusEnum.rejected;

        } else if (addUserToRoleRequestMapping[requestId].requesterAddress != address(0)) {
            addUserToRoleRequestMapping[requestId].adminAdditionalRemarks = adminAdditionalRemarks;
            addUserToRoleRequestMapping[requestId].requestStatus = statusEnum.rejected;

        } else if (removeUserFromRoleRequestMapping[requestId].requesterAddress != address(0)) {
            removeUserFromRoleRequestMapping[requestId].adminAdditionalRemarks = adminAdditionalRemarks;
            removeUserFromRoleRequestMapping[requestId].requestStatus = statusEnum.rejected;

        }
    }

    // User functions
    function createNewRole(string memory roleName) public {
        // Role Creation

        // Create Permissions

        // Give Permission to role

        // Give role to permission

        // Give user role
    }

    function removeRole(uint256 roleId) public {
        //  Remove role


    }

    function addDatasetToRoles(string memory datasetName) public {
        // Create Permissions

        // Give Permission to role

        // Give role to permission
    }

    function removeDatasetFromRoles(string memory datasetName) public {
        // Remove permissions
        
        // Remove Permission to role

        // Remove role to permission

    }

    function addUsersToRoles(uint256 userId, uint256 roleId) public {
        // Give user role
    }

    function removeUsersFromRoles(uint256 userId, uint256 roleId) public {
        // Remove user from role

    }
}
