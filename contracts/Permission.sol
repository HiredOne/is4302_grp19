pragma solidity ^0.5.17;
import "./User.sol";

contract Permission {
    User userContract;
    uint256 numPermissions = 0;
    mapping(uint256 => permission) permissionsCreated;

    struct permission{
        string name;
    }

    constructor(User users) public {
        userContract = users;
    }

    // Created as a function for use in other contracts
    function validPermission(uint256 permissionID) public view {
        require(permissionID < numPermissions, "Permission does not exist");
    }

    // For creating permissions
    function createPermission(string memory name) public {
        require(bytes(name).length != 0, "Name cannot be blank");
        userContract.adminOnly(msg.sender);
        permission memory perm = permission(name);
        permissionsCreated[numPermissions] = perm;
        numPermissions += 1;
    }
}