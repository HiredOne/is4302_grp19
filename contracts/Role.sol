pragma solidity ^0.5.17;
import "./User.sol";
import "./Permission.sol";

contract Role {
    User userContract;
    Permission permContract;
    uint256 numRoles;
    mapping(uint256 => role) rolesCreated;
    mapping(uint256 => uint256 []) rolesGivenPermission; // Roles that are given a particular permission
    mapping(address => uint256 []) rolesGrantedToUser; // Roles that are granted to a user

    struct role {
        string name;
        mapping(uint256 => uint8) assignedPermissions;
        mapping(address => uint8) assignedUsers;
        mapping(uint256 => uint8) inheritedRoles;
    }

    constructor(User users, Permission perms) public {
        userContract = users;
        permContract = perms;
    }

    modifier validRole(uint256 id) {
        require(id < numRoles, "Role does not exist");
        _;
    }

    // For creating roles
    function createRole(string memory name) public returns(uint256) {
        require(bytes(name).length != 0, "Name cannot be blank");
        role memory createdRole = role(name);
        rolesCreated[numRoles] = createdRole;
        numRoles += 1;
        return numRoles;
    }

    // For role to inherit another role
    function inheritRole(uint256 roleToInherit, uint256 inheritingRole) validRole(roleToInherit) validRole(inheritingRole) public {
        // Check that role has not already been inherited
        require(rolesCreated[inheritingRole].inheritedRoles[roleToInherit] == 0, "Role already inherited");
        userContract.adminOnly(msg.sender);

        rolesCreated[inheritingRole].inheritedRoles[roleToInherit] = 1; // Inherit
    }

    // For assigning permissions to a role
    function assignPermission(uint256 roleID, uint256 permission) validRole(roleID) public {
        // Check that permission has not already been assigned
        require(rolesCreated[roleID].assignedPermissions[roleID] == 0, "Permission already assigned to this role");
        userContract.adminOnly(msg.sender);
        permContract.validPermission(permission);
        
        rolesGivenPermission[permission].push(roleID); // Update rolesGivenPermission
        rolesCreated[roleID].assignedPermissions[permission] = 1; // Assign permission
    }

    // For removing permissions from a role
    function removePermission(uint256 roleID, uint256 permission) validRole(roleID) public {
        // Check that permission has already been assigned
        require(rolesCreated[roleID].assignedPermissions[roleID] == 1, "Role does not have this permission yet");
        userContract.adminOnly(msg.sender);
        permContract.validPermission(permission);

        // Update rolesGivenPermission
        uint256 [] memory roles = rolesGivenPermission[permission]; 
        for (uint i = 0; i < roles.length; i++) {
            if (roles[i] == roleID) {
                delete(roles[i]);
            }
        }
        rolesCreated[roleID].assignedPermissions[permission] = 0; // Remove permission
    }

    // For assigning role to a user
    function giveUserRole(address userID, uint256 roleID) validRole(roleID) public {
        // Check that role has not already been assigned
        require(rolesCreated[roleID].assignedUsers[userID] == 0, "Role has already been assigned");
        userContract.adminOnly(msg.sender);

        rolesGrantedToUser[userID][roleID] = 1; // Update rolesGrantedToUser
        rolesCreated[roleID].assignedUsers[userID] = 1; // Assign role
    }

    // For removing role assigned to a user
    function removeUserRole(address userID, uint256 roleID) validRole(roleID) public {
        require(rolesCreated[roleID].assignedUsers[userID] == 1, "User does not have this role yet");
        userContract.adminOnly(msg.sender);

        // Update rolesGrantedToUser
        uint256 [] memory roles = rolesGrantedToUser[userID];
        for (uint i = 0; i < roles.length; i++){
            if (roles[i] == roleID) {
                delete(roles[i]);
            }

        }
        rolesCreated[roleID].assignedUsers[userID] = 0; // Remove role
    }

    // Check whether user has a particular permission
    function checkUserPermission(address userID, uint256 permission) view public returns (bool) {
        // Check validity of permission
        permContract.validPermission(permission);

        uint256 [] memory roles = rolesGrantedToUser[userID];
        for (uint i = 0; i < roles.length; i++) {
            role storage r = rolesCreated[i];
            if (r.assignedPermissions[permission] == 1) {
                return true;
            }
        }
        return false;
    }

    // Getter Functions
    // Get roles that are given this particular permission
    // function getRolesGiven(uint256 permissionID) validPermission(permissionID) public returns(mapping(uint256 => uint8) memory) {
    //     return rolesGivenPermission[permissionID];
    // }

    // // Get roles that are granted to this user
    // function getRolesGranted(address userID) public returns(mapping(uint256 => uint8) memory) {
    //     return rolesGrantedToUser[userID];
    // }

    // // Get permissions that are assigned to this role
    // function getAssignedPermissions(uint256 roleID) validRole(roleID) public returns(mapping(uint256 => uint256) memory) {
    //     return rolesCreated[roleID].assignedPermissions;
    // }

    // // Get users that are assigned with this role
    // function getAssignedUsers(uint256 roleID) validRole(roleID) public returns(mapping(address => uint256) memory) {
    //     return rolesCreated[roleID].assignedUsers;
    // }
    
    // // Get roles that this role has inherited
    // function getInheritedRoles(uint256 roleID) validRole(roleID) public returns(mapping(uint256 => uint256) memory) {
    //     return rolesCreated[roleID].inheritedRoles;
    // }
}