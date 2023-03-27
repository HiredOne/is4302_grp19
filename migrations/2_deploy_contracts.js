const User = artifacts.require("User");
const Permission = artifacts.require("Permission");
const Role = artifacts.require("Role");

module.exports = (deployer, network, accounts) => {
    deployer.deploy(User, String("DBAdmin")).then(function() {
        return deployer.deploy(Permission, User.address);
    }).then(function() {
        return deployer.deploy(Role, User.address, Permission.address);
    });
}