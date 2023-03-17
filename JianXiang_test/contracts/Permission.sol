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

    // modifier validPermission(uint256 permissionID) {
    //     require(permissionID < numPermissions, "Permission does not exist");
    //     _;
    // }

    // // For creating permissions
    // function createPermission(string memory name) adminOnly(msg.sender) public {
    //     require(bytes(name).length != 0, "Name cannot be blank");
    //     permission memory perm = permission(name);
    //     permissionsCreated[numPermissions] = perm;
    //     numPermissions += 1;
    // }
}