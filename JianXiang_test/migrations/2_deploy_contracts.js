const User = artifacts.require("User");
const Permission = artifacts.require("Permission");
const Role = artifacts.require("Role");
const RequestApprovalManagement = artifacts.require("RequestApprovalManagement");
const DatasetUploader = artifacts.require("DatasetUploader");

const BigNumber = require('bignumber.js');



module.exports = async function (deployer, network, accounts) {
    await deployer.deploy(User);
    await deployer.deploy(Permission, User.address);
    await deployer.deploy(DatasetUploader);
    await deployer.deploy(Role, User.address, Permission.address);
    await deployer.deploy(RequestApprovalManagement, User.address, Permission.address, Role.address, DatasetUploader.address);
}