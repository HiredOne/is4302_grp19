pragma solidity ^0.5.17;
import "./User.sol";
import "./Permission.sol";

contract Role is User, Permission {
    User userContract;
    Permission permContract;
    uint256 numRoles;
    mapping(uint256 => role) rolesCreated;
    mapping(uint256 => mapping(uint256 => uint8)) rolesGivenPermission; // Roles that are given a particular permission
    mapping(address => mapping(uint256 => uint8)) rolesGrantedToUser; // Roles that are granted to a user

    struct role {
        string name;
        mapping(uint256 => uint256) assignedPermissions;
        mapping(address => uint256) assignedUsers;
        mapping(uint256 => uint256) inheritedRoles;
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
    function createRole(string memory name) public {
        require(bytes(name).length != 0, "Name cannot be blank");
        role memory createdRole = role(name);
        rolesCreated[numRoles] = createdRole;
        numRoles += 1;
    }

    // For role to inherit another role
    function inheritRole(uint256 roleToInherit, uint256 inheritingRole) validRole(roleToInherit) validRole(inhertingRole) adminOnly(msg.sender) public {
        // Check that role has not already been inherited
        require(rolesCreated[inheritingRole].inheritedRoles[roleToInherit] == 0, "Role already inherited");

        rolesCreated[inheritingRole].inheritedRoles[roleToInherit] = 1; // Inherit
    }

    // For assigning permissions to a role
    function assignPermission(uint256 roleID, uint256 permission) adminOnly(msg.sender) validRole(roleID) validPermission(permission) public {
        // Check that permission has not already been assigned
        require(rolesGivenPermission[permission][roleID] == 0, "Permission already assigned to this role");
        
        rolesGivenPermission[permission][roleID] = 1; // Update rolesGivenPermission
        rolesCreated[roleID].assignedPermissions[permission] = 1; // Assign permission
    }

    // For removing permissions from a role
    function removePermission(uint256 roleID, uint256 permission) adminOnly(msg.sender) validRole(roleID) validPermission(permission) public {
        // Check that permission has already been assigned
        require(rolesGivenPermission[permission][roleID] == 1, "Role does not have this permission yet");

        rolesGivenPermission[permission][roleID] = 0; // Update rolesGivenPermission
        rolesCreated[roleID].assignedPermissions[permission] = 0; // Remove permission
    }

    // For assigning role to a user
    function giveUserRole(address userID, uint256 role) adminOnly(msg.sender) validRole(role) public {
        // Check that role has not already been assigned
        require(rolesGrantedToUser[userID][role] == 0, "Role has already been assigned");

        rolesGrantedToUser[userID][role] = 1; // Update rolesGrantedToUser
        rolesCreated[role].assignedUsers[userID] = 1; // Assign role
    }

    // For removing role assigned to a user
    function removeUserRole(address userID, uint256 role) adminOnly(msg.sender) validRole(role) public {
        require(rolesGrantedToUser[userID][role] == 1, "User does not have this role yet");

        rolesGrantedToUser[userID][role] = 0; // Update rolesGrantedToUser
        rolesCreated[role].assignedUsers[userID] = 0; // Remove role
    }

    // Get roles that are given this particular permission
    function getRolesGiven(uint256 permissionID) validPermission(permission) returns(mapping(uint256 => mapping(uint256 => uint8))) {
        return rolesGivenPermission[permissionID];
    }

    // Get roles that are granted to this user
    function getRolesGranted(address userID) returns(mapping(address => mapping(uint256 => uint8))) {
        return rolesGrantedToUser[userID];
    }

    // Get permissions that are assigned to this role
    function getAssignedPermissions(uint256 roleID) validRole(roleID) returns(mapping(uint256 => uint256)) {
        return rolesCreated[roleID].assignedPermissions;
    }

    // Get users that are assigned with this role
    function getAssignedUsers(uint256 roleID) validRole(roleID) returns(mapping(address => uint256)) {
        return rolesCreated[roleID].assignedUsers;
    }
    
    // Get roles that this role has inherited
    function getInheritedRoles(uint256 roleID) validRole(roleID) returns(mapping(uint256 => uint256)) {
        return rolesCreated[roleID].inheritedRoles;
    }
}