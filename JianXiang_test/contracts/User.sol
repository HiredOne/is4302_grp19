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

    constructor() public {
    }

    // // Modifier where function is only callable by a system admin
    // modifier adminOnly(address caller) {
    //     require(usersCreated[caller].admin == adminState.isAdmin);
    //     _;
    // }

    // For creating new users
    function createUser(string memory name) public {
        // Prerequisite checks
        require(bytes(name).length != 0, "Name cannot be blank");
        require(
            bytes(usersCreated[msg.sender].name).length != 0,
            "User already has an account"
        );

        // Create User
        user memory newUser = user(name, adminState.notAdmin, 0);

        // Add to mapping
        usersCreated[msg.sender] = newUser;
    }

    // // For deleting users
    // function deleteuser(address userID) public adminOnly(msg.sender) {
    //     require(
    //         bytes(usersCreated[msg.sender].name).length != 0,
    //         "User doesn't exist"
    //     );
    //     delete usersCreated[userID];
    // }

    // // For issuing admin rights
    // function giveAdmin(address userID) public adminOnly(msg.sender) {
    //     usersCreated[userID].admin = adminState.isAdmin;
    // }

    // // For removing admin rights
    // function removeAdmin(address userID) public adminOnly(msg.sender) {
    //     usersCreated[userID].admin = adminState.notAdmin;
    // }

    // // For issuing tokens
    // function giveTokens(
    //     address userID,
    //     uint256 amt
    // ) public adminOnly(msg.sender) {
    //     usersCreated[userID].tokenCount += amt;
    // }

    // // Deduct tokens after use
    // function deductTokens(
    //     address userID,
    //     uint256 amt
    // ) public adminOnly(msg.sender) {
    //     usersCreated[userID].tokenCount -= amt;
    // }
}
