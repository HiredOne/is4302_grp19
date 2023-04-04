pragma solidity ^0.5.0;

import "./User.sol";
import "./Permission.sol";
import "./Role.sol";
import "./DataLineage.sol";


contract DatasetUploader {
    using Strings for string;

    User userContract;
    Permission permissionContract;
    Role roleContract;   
    DataLineage dataLineageContract;
    
    address public contractDeployer;
    uint256 private rewardAmount = 1;

    event datasetUploaded(string datasetIdentifier, address requestor);

    constructor(User userAddress, Permission permissionAddress, Role roleAddress, DataLineage dataLineageAddress) public {
        userContract = userAddress;
        permissionContract = permissionAddress;
        roleContract = roleAddress;
        dataLineageContract = dataLineageAddress;
        contractDeployer =  msg.sender;
    }

    // This function is called by the user to upload a dataset, a new permission will be created and tagged to the new role created
    function uploadDatasetToNewRole(string memory datasetIdentifier, string memory roleName, string memory pointer, address requestor, string memory permissionName) public { 
        uint256 newPermissionID = permissionContract.createPermission(permissionName);
        uint256 roleID = roleContract.createRole(roleName); // Can this return the roleID? 
        roleContract.assignPermission(roleID, newPermissionID); 
        dataLineageContract.addNewDataset(datasetIdentifier, pointer, requestor);

        userContract.giveTokens(requestor, rewardAmount); // Where are the tokens coming from? Should it not be a transfer?
        emit datasetUploaded(datasetIdentifier, requestor);
    }

    // This function is called by the user to upload a dataset, a permission will be created and tagged to the an exisitng role
    function uploadDatasetToExistingRole(string memory datasetIdentifier, uint256 roleID, string memory pointer, address requestor, string memory permissionName, uint256 permissionID) public { 
        require(roleContract.checkUserPermission(requestor, permissionID) == true, "You do not have the appropriate permissions to upload a new dataset");
        uint256 newPermissionID = permissionContract.createPermission(permissionName);
        roleContract.assignPermission(roleID, newPermissionID); 
        dataLineageContract.addNewDataset(datasetIdentifier, pointer, requestor);
        
        userContract.giveTokens(requestor, rewardAmount);
        emit datasetUploaded(datasetIdentifier, requestor);
    }

}
