const User = artifacts.require("User");
const Permission = artifacts.require("Permission");
const Role = artifacts.require("Role");
const RequestApprovalManagement = artifacts.require("RequestApprovalManagement");
const DatasetUploader = artifacts.require("DatasetUploader");
const DataLineage = artifacts.require("DataLineage");
const Pointer = artifacts.require("Pointer");
const Metadata = artifacts.require("Metadata");
const QueueSystem = artifacts.require("QueueSystem");
const PriorityQueue = artifacts.require("PriorityQueue");
const QueryDataset = artifacts.require("QueryDataSet");

const BigNumber = require('bignumber.js');


module.exports = async function (deployer, network, accounts) {
    await deployer.deploy(User, "DBAdmin");
    await deployer.deploy(Permission, User.address);
    await deployer.deploy(Role, User.address, Permission.address);
    await deployer.deploy(Metadata, User.address, Role.address);
    await deployer.deploy(Pointer);
    await deployer.deploy(DataLineage);
    await deployer.deploy(DatasetUploader, User.address, Permission.address, Role.address, DataLineage.address);
    await deployer.deploy(RequestApprovalManagement, User.address, Permission.address, Role.address, DatasetUploader.address);
    await deployer.deploy(PriorityQueue);
    await deployer.deploy(QueueSystem, DataLineage.address, User.address);
    await deployer.deploy(QueryDataset, User.address, Permission.address, Role.address,QueueSystem.address);
}