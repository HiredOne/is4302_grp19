pragma solidity ^0.5.0;

// Self-Abstraction
import "./PriorityQueue.sol";

// Upstream
import "./User.sol";

// Downstream 
import "./DataLineage.sol";


contract QueueSystem {
    using PriorityQueue for PriorityQueue.Data;
    PriorityQueue.Data public PQdata; 

    // will be admin when deployed
    address owner;   

    // number of querys every in queue (incl deleted ones) to prevent Overridding when popped
    uint256 numQueue = 0; 

    DataLineage DLContract;
    User UserContract;

    // include the address of the admin in the constructor 
    constructor(DataLineage _dataLineage, User _user) public {
        owner = msg.sender;
        PQdata.init();
        DLContract = _dataLineage;
        UserContract = _user;
    }

    struct Request {
        string new_id; // dataset ID
        string pointer;
        string query;
        string parent;
        uint256 numTokens;
        address reqSender;
        bool isPermChange;
    }

    // Kwy will be the unique Node ID
    mapping(uint256 => Request) queryIDtoRequest;

    event queryExecuted(string query);

    // only the admin can run the functions
    // modifier ownerOnly() {
    //     require(owner == msg.sender);
    //     _;
    // }

    // main functions      
    // will be called by QueryDataset after validation
    // number of tokens will be manually inputted by user (msg.value)
    // note: no way to obtain position in queue because heap is unsorted
    function createRequestEnqueue(string memory _new_id, string memory _pointer, string memory _query, string memory _parent, uint256 _numTokens, address _reqSender, bool _isPermChange) public {
        UserContract.adminOnly(msg.sender);
        // queue insertion returns a node
        uint256 numberInQueue = PQdata.insert(_numTokens).id; 
        Request memory request = Request(_new_id,_pointer, _query, _parent, _numTokens, _reqSender, _isPermChange);

        // key: nodeID, value: request
        queryIDtoRequest[numberInQueue] = request;
        
        // take payment from user -- checking that token balance is valid done in QueryDataset
        acceptPayment(_reqSender, _numTokens);
    }  


    // Token functions -- only applicable to PQ
    function acceptPayment(address reqSender, uint256 numTokens) private {
        UserContract.deductTokens(reqSender, numTokens);
    }

    function returnPayment(uint256 requestId) private {
        // return tokens to user 
        address reciepient = queryIDtoRequest[requestId].reqSender;
        uint256 payment = queryIDtoRequest[requestId].numTokens;
        UserContract.giveTokens(reciepient, payment);

        // remove from mapping
        deleteRecords(requestId);
        
    }

    // Queue Functions
    function withdraw(uint requestId) public {
        require(keccak256(abi.encodePacked(queryIDtoRequest[requestId].new_id)) != keccak256(abi.encodePacked("")), "Query does not exist");
        // remove from queue
        PQdata.extractById(requestId);
        // return tokens to user and delete from Queue memory
        returnPayment(requestId);
    }

    // PQ will be run manually -- every pop will be clicked by the admin to release the next task
    // require only admin can pop
    function pop() public {
        UserContract.adminOnly(msg.sender);
        uint256 popped = PQdata.extractMax().id ; 
        Request memory request = queryIDtoRequest[popped];

        // check if query belongs to a permernant change. if True, pass to data lineage, else do nothing
        bool isPermChange = request.isPermChange;
        if (isPermChange) {
            DLContract.changeExistingDataset(request.new_id, request.pointer, request.reqSender, request.query, request.parent);
        }

        // remove from Request mappings
        deleteRecords(popped);
        emit queryExecuted(request.query);
    }

    // Getters
    function getQueueLength() public view returns (uint256) {
        return PQdata.size();
    }

    // returns the next stage of pipeline by calling checkQuery
    // delete from all mappings once request is passed (if permentant change)
    function deleteRecords(uint256 requestId) public {
        delete queryIDtoRequest[requestId];
    }
}