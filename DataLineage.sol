pragma solidity ^0.5.0;

import "./Pointer.sol";
import "./Strings.sol";


contract DataLineage {
    using Strings for string;
    address _owner = msg.sender;

    struct dataset {
        string id;
        string pointer;
        address requestor;
        string query;
        string lineage;
        string parent;
        string children;
    }

    mapping(string => dataset) datasets;

    event addDataset(string id);
    event addChildren(string parent, string children);

    //Call this for perm changes to datasets
    function changeExistingDataset(string memory new_id, string memory pointer, address requestor, string memory query, string memory parent) public {
        string memory _lineage = datasets[parent].lineage;
        _lineage = _lineage.concat("; ").concat(query);
        dataset memory newDataset = dataset(new_id, pointer, requestor, query, _lineage, parent, "");
        datasets[new_id] = newDataset;
        emit addDataset(new_id);
        addChild(parent, new_id);
    }

    //Call this for new datasets.
    function addNewDataset(string memory id, string memory pointer, address requestor) public {
        dataset memory newDataset = dataset(id, pointer, requestor, id, id, "", "");
        datasets[id] = newDataset;
        emit addDataset(id);
    }

    //Adds the children dataset to its parent's children list
    function addChild(string memory parent, string memory child) internal {
        datasets[parent].children = datasets[parent].children.concat("; ").concat(child);
        emit addChildren(parent, child);
    }

    function getLineage(string memory id) public view returns(string memory) {
        return datasets[id].lineage;
    }

    function getParent(string memory id) public view returns(string memory) {
        return datasets[id].parent;
    }

    function getChildren(string memory id) public view returns(string memory) {
        return datasets[id].children;
    }
}