pragma solidity ^0.5.0;

import "./User.sol";
import "./Permission.sol";
import "./Role.sol";
import "./Metadata.sol";
import "./Pointer.sol";
import "./DataLineage.sol";


contract DatasetUploader {
    using Strings for string;

    User userContract;
    Permission permissionContract;
    Role roleContract;   
    Metadata metadataContract;
    Pointer pointerContract;
    DataLineage dataLineageContract;
    
    address public contractDeployer;
    uint256 private rewardAmount = 1;

    event datasetUploaded(string datasetIdentifier, uint256 roleID, address requestor);

    constructor(address dataLineageAddress) public {
        dataLineage = DataLineage(dataLineageAddress);
        contractDeployer =  msg.sender;
    }

    //This function is called by the user to upload a dataset, a new permission will be created and tagged to the new role created
    function uploadDatasetToNewRole(string memory datasetIdentifier, string memory roleName, string memory pointer, address requestor, string memory permissionName) public {
        permissionContract.addPermission(permissionName);
        roleContract.createRole(roleName); //Can this return the roleID? 
        roleContract.assignPermission(roleContract.numRoles, permissionName); //Is permission identified by name or ID? 
        dataLineageContract.addDataset(datasetIdentifier, roleContract.numRoles, pointer, requestor);

        userContract.giveTokens(requestor, rewardAmount); //Where are the tokens coming from? Should it not be a transfer?
        emit datasetUploaded(datasetIdentifier, roleContract.numRoles, requestor);
    }

    //This function is called by the user to upload a dataset, a permission will be created and tagged to the an exisitng role
    function uploadDatasetToExistingRole(string memory datasetIdentifier, uint256 roleID, string memory pointer, address requestor, string memory permissionName) public {
        permissionContract.addPermission(permissionName);
        roleContract.assignPermission(roleID, permissionName); //Is permission identified by name or ID? -JESTER
        dataLineageContract.addDataset(datasetIdentifier, roleID, pointer, requestor);
        
        userContract.giveTokens(requestor, rewardAmount);
        emit datasetUploaded(datasetIdentifier, roleContract.numRoles, requestor);
    }

}
