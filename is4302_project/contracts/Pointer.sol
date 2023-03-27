pragma solidity ^0.5.0;

contract Pointer {
    //This is a dummy contract to simulate an actual pointer.
    struct pointer {
        string name;
    }

    mapping(uint256 => pointer) points;
    uint256 numOfPointers = 0;

    function addPointer(string memory name) public {
        points[numOfPointers] = pointer(name);
        numOfPointers++;
    }

    function getName(uint256 id) public view returns(string memory) {
        return points[id].name;
    }
}