// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

contract User {
    enum adminState {
        isAdmin,
        notAdmin
    }

    mapping(address => user) usersCreated;

    struct user {
        string name;
        adminState admin;
        uint256 tokenCount;
    }

    constructor(string memory name) public {
        createAdmin(name);
    }

    // Created as a function instead of modifier so that other contracts can use
    function adminOnly(address caller) public view {
        require(usersCreated[caller].admin == adminState.isAdmin);
    }

    // For creating new users
    function createUser(string memory name) public {
        // Prerequisite checks
        require(bytes(name).length != 0, "Name cannot be blank");
        require(
            bytes(usersCreated[msg.sender].name).length == 0,
            "User already has an account"
        );

        // Create User
        user memory newUser = user(name, adminState.notAdmin, 0);

        // Add to mapping
        usersCreated[msg.sender] = newUser;
    }

    // For creating new admins
    function createAdmin(string memory name) internal {
        // Prerequisite checks
        require(bytes(name).length != 0, "Name cannot be blank");
        require(
            bytes(usersCreated[msg.sender].name).length == 0,
            "User already has an account"
        );

        // Create User
        user memory newUser = user(name, adminState.isAdmin, 0);

        // Add to mapping
        usersCreated[msg.sender] = newUser;
    }

    // For deleting users
    function deleteuser(address userID) public {
        require(
            bytes(usersCreated[msg.sender].name).length != 0,
            "User doesn't exist"
        );
        adminOnly(msg.sender);
        delete usersCreated[userID];
    }

    // For issuing admin rights
    function giveAdmin(address userID) public {
        adminOnly(msg.sender);
        usersCreated[userID].admin = adminState.isAdmin;
    }

    // For removing admin rights
    function removeAdmin(address userID) public {
        adminOnly(msg.sender);
        usersCreated[userID].admin = adminState.notAdmin;
    }

    // For issuing tokens
    function giveTokens(address userID, uint256 amt) public {
        adminOnly(msg.sender);
        usersCreated[userID].tokenCount += amt;
    }

    // Deduct tokens after use
    function deductTokens(address userID, uint256 amt) public {
        adminOnly(msg.sender);
        usersCreated[userID].tokenCount -= amt;
    }

    // Getter Functions
    function getTokenBalance(address userID) public view returns (uint256) {
        return usersCreated[userID].tokenCount;
    }

    function checkAdmin(address userID) public view returns (adminState) {
        return usersCreated[userID].admin;
    }
}
