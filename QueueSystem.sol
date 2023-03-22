pragma solidity ^0.5.0;

// Self-Abstraction
import "./QueueToken.sol";
import "./PriorityQueue.sol";

// Upstream
import "./User.sol";
import "./Pointer.sol";

// Downstream
import "./DataLineage.sol";
import "./Metadata.sol";
// import "./DatasetUploader.sol";

contract QueueSystem {
    using PriorityQueue for PriorityQueue.Data;
    PriorityQueue.Data public PQdata; 

    address owner;   
    QueueToken QT;

    // tokenless queue for people to upload new tokens into their database. Have first priority when running
    // Will issue token here? 
    DatasetUploader[] createQueue; // update when DatasetUploader is in
    
    MetaData MDContract;
    DataLineage DLContract;

    constructor(MetaData _metadata, PriorityQueue _priorityQueue, DataLineage _dataLineage, QueueToken _QT) public {
        owner = msg.sender;
        PQdata.init(); 
        MDcontract = _metadata;
        DLContract = _dataLineage;
        QT = _QT;

    }

    struct Request {
        string query;
        string datasetName;
        string data;
        bool isPermChange;
        address reqSender;
        uint256 numTokens;
    }

    mapping(uint256 => Metadata) queryIDtoMetadata;
    mapping(uint256 => Request) queryIDtoRequest;


    // main functions      
    // will be called by QueryDataset after validation
    // number of tokens will be manually inputted by user (msg.value)
    // note: no way to obtain position in queue because heap is unsorted
    function createRequestEnqueue(string memory _query, string memory _datasetName, string memory _data, uint256 _numTokens, bool _isPermChange, address _reqSender) public {
        uint256 numberInQueue = PQdata.size(); 
        Request request = Request(_query, _datasetName, _data, _isPermChange, _reqSender, _numTokens);

        queryIDtoMetadata[numberInQueue] = metadata;
        queryIDtoRequest[numberInQueue] = request;
        
        PQdata.insert(_numTokens);

        // take payment from user -- checking that token balance is valid done in QueryDataset
        acceptPayment(_reqSender, _numTokens);
    }  

    // some regular function to queue the dataset upload
    // update when DatasetUploader ready
    function createDatasetUpload(string memory _query, string memory _datasetName, string memory _data, uint256 numTokens, bool _isPermChange) {

    }


    // Token functions -- only applicable to PQ (uploadDataset Queue dont need tokens)
    function acceptPayment(address reqSender) private payable {
        QT.transferCredit(reqSender, owner, numTokens);
    }

    function returnPayment(uint256 requestId) private payable {
        // return tokens to user 
        address reciepient = queryIDtoRequest[requestId].reqSender;
        uint256 payment = queryIDtoRequest[requestId].numTokens;
        QT.transferCredit(owner, reciepient, paymemt);

        // remove from Queue
        deleteRecords(requestId);
        
    }

    // Queue Functions
    // insert (actually a helper function, will be called in createRequest())
    function insert(int128 priority) public returns(Heap.Node){
        return data.insert(priority);
    }

    function withdraw(uint requestId) public {
        require(queryIDtoRequest[requestId] != 0, "Query does not exist");
        // remove from queue
        PQdata.extractById(requestId);
        // return tokens to user and delete from Queue memory
        returnPayment(requestId);
    }

    // PQ will be run manually -- every pop will be clicked by the admin to release the next task
    // assuming only one running thread, only one query (from either queue/ heap) will run at a time
    function pop() public returns (QueryForm queryForm) {
        if (createQueue.length == 0 ) { // PQ will only run when PQ empty
            uint256 popped = PQdata.extractMax(); 
            Request request = queryIDtoRequest[popped];

            // check if query belongs to a permernant change. if True, pass to data lineage, else do nothing
            bool isPermChange = request.isPermChange;
            if (isPermChange) {
                Request poppedRequest = queryIDtoRequest[popped];
                // supposed to get Pointer from QueryDataset ..?
                DLContract.changeExistingDataset(string new_id, uint256 pointer, address requestor, request.query, string memory parent);
            }
        } else { // run the create database query first -- pass to DatasetUploader
            // do something here HEREE
            DLContract.addNewDataset(id, pointer, requestor);
        }

        // remove from queue
        deleteRecords(popped);
    }

    // Getters
    function getQueueLength() public returns (uint256) {
        return PQdata.size();
    }

    // returns the next stage of pipeline by calling checkQuery
    // delete from all mappings once request is passed (if permentant change)
    function deleteRecords(uint256 requestId) public {
        delete queryIDtoMetadata[requestId];
        delete queryIDtoRequest[requestId];

    }
}
