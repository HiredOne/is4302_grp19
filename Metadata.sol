pragma solidity ^0.5.0;

import "./Strings.sol";
import "./User.sol";
import "./Role.sol";

contract Metadata {
    using Strings for string;
    User userContract;
    Role roleContract;

    constructor(User userAddress, Role roleAddress) public {
        userContract = userAddress;
        roleContract = roleAddress;
    }

    struct metadata {
        string title;
        string desc;
        uint256 category;
        uint256 [] _tags;
        string dateUpdated;
        string owner;
    }
    uint256 numOfDatasets = 0;
    uint256 numOfCategories = 0;
    uint256 numOfTags = 0;
    //maps dataset name to metadata
    mapping(string => metadata) metadatas;
    //maps name to id
    mapping(string => uint256) nameToID;
    //maps id to name
    mapping(uint256 => string) idToName;
    //maps name to category
    mapping(string => uint256) catToID;
    //maps category to name
    mapping(uint256 => string) idToCat;
    //maps tag to id
    mapping(string => uint256) tagToID;
    //maps id to tag
    mapping(uint256 => string) idToTag;
    //Maps by category only
    mapping(uint256 => uint256 []) catList;
    //Maps by tag only
    mapping(uint256 => uint256 []) tagList;
    //Maps by category then tag
    mapping(uint256 => mapping(uint256 => uint256 [])) searchList;
    //Mapping of category/tag/both to dataset id to index
    mapping(string => mapping(uint256 => uint256)) indexes;
    //mapping for search functions
    mapping(uint8 => uint256 []) searchResults;

    event metadataAdded(string name, string title, string desc, uint256 category, uint256 [] tags, string dateUpdated, string owner);
    event searchResult(uint256 [] result);
    event categoryAdded(string name);
    event tagAdded(string name);

    function addCategory(string memory category) public returns (uint256) {
        //Admin only
        require(userContract.checkAdmin(msg.sender) == userContract.adminState.isAdmin, "Admin only");
        numOfCategories++;
        catToID[category] = numOfCategories;
        idToCat[numOfCategories] = category;
        emit categoryAdded(category);
    }

    function addTag(string memory tag) public returns (uint256) {
        //Admin only
        require(userContract.checkAdmin(msg.sender) == userContract.adminState.isAdmin, "Admin only");
        numOfTags++;
        tagToID[tag] = numOfTags;
        idToTag[numOfTags] = tag;
        emit tagAdded(tag);
    }

    function getCategoryID(string memory category) public view returns (uint256) {
        return catToID[category];
    }

    function getTagID(string memory tag) public view returns (uint256) {
        return tagToID[tag];
    }

    function getMetadataName(uint256 id) public view returns (string memory) {
        return idToName[id];
    }

    //Overwrites current metadata for the dataset
    function addMetadata(string memory name, string memory title, string memory desc, uint256 category, uint256 [] memory tags, string memory dateUpdated, string memory owner, uint256 permissionID) public {
        require(roleContract.checkUserPermission(msg.sender, permissionID), "Permission required to add metadata");
        require(category <= numOfCategories, "Invalid Category");
        bool isNew = false;
        if (nameToID[name] == 0) {
            numOfDatasets++;
            idToName[numOfDatasets] = name;
            nameToID[name] = numOfDatasets;
            isNew = true;
        }
        metadata memory newMetadata = metadata(title, desc, category, tags, dateUpdated, owner);
        metadatas[name] = newMetadata;
        uint256 id = nameToID[name];
        uint256 index;
        string memory cat = idToCat[category];
        if (!isNew) {
            //0 means deleted, index starts from 1 so index - 1 is the actual position
            index = indexes[cat][id];
            catList[category][index - 1] = 0;
        }
        catList[category].push(id);
        index = catList[category].length;
        indexes[cat][id] = index;
        if (tags.length > 0) {
            for (uint8 i = 0; i < tags.length; i++) {
                        uint256 t = tags[i];
                        string memory tagStr = idToTag[t];
                        if (!isNew) {
                            //0 means deleted, index starts from 1 so index - 1 is the actual position
                            index = indexes[tagStr][id];
                            tagList[t][index - 1] = 0;
                            index = indexes[cat.concat(tagStr)][id];
                            searchList[category][t][index - 1] = 0;
                        }
                        tagList[t].push(id);
                        index = tagList[t].length;
                        indexes[tagStr][id] = index;
                        searchList[category][t].push(id);
                        index = searchList[category][t].length;
                        indexes[cat.concat(tagStr)][id] = index;
            }
        }
        emit metadataAdded(name, title, desc, category, tags, dateUpdated, owner);
    }

    function getMetadata(string memory name) public view returns (string memory) {
        //print metadata
        metadata memory md = metadatas[name];
        string memory toReturn = "";
        toReturn = toReturn.concat("Title: ").concat(md.title).concat("; ");
        toReturn = toReturn.concat("Description: ").concat(md.desc).concat("; ");
        toReturn = toReturn.concat("Category: ").concat(idToCat[md.category]).concat("; ");
        toReturn = toReturn.concat("Tags: ");
        for (uint8 i = 0; i < md._tags.length; i++) {
            uint256 t = md._tags[i];
            toReturn = toReturn.concat(idToTag[t]).concat(",");
        }
        toReturn = toReturn.concat("; ");
        toReturn = toReturn.concat("Date Updated: ").concat(md.dateUpdated).concat("; ");
        toReturn = toReturn.concat("Owner: ").concat(md.owner);
        return toReturn;
    }

    //Search function for metadata, category = 0 means search for tag only.
    function searchByTag(uint256 category, uint256 [] memory tags) public returns (uint256 [] memory) {
        require(category <= numOfCategories, "Invalid Category");
        require(tags.length > 0, "At least one tag is needed to search");
        delete searchResults[0];
        if (category == 0) {
            for (uint8 i = 0; i < tags.length; i++) {
                uint256 t = tags[i];
                for (uint256 j = 0; j < tagList[t].length; j++) {
                    searchResults[0].push(tagList[t][j]);
                }
            }
        } else {
            for (uint8 i = 0; i < tags.length; i++) {
                uint256 t = tags[i];
                for (uint256 j = 0; j < tagList[t].length; j++) {
                    searchResults[0].push(searchList[category][t][j]);
                }
            }
        }
        emit searchResult(searchResults[0]);
        return searchResults[0];
    }

    //search by category only
    function searchCat(uint256 category) public returns (uint256 [] memory) {
        require(category > 0, "Invalid Category");
        require(category <= numOfCategories, "Invalid Category");
        emit searchResult(catList[category]);
        return catList[category];
    }

}
