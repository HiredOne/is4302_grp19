pragma solidity ^0.5.0;
import "https://github.com/willitscale/solidity-util/lib/Strings.sol";
import "./QueueSystem.sol"
import "./Permission.sol"
import "./User.sol"

contract QueryDataSet {
   using Strings for string;

   struct errorLog {
      uint256 errorLogId;
      address requestSender;
      string errorMsg;
      string datasetName;
      uint256 datetime;
      bool isRead;
   }

   struct queryCheckResult {
      bool hasPassed;
      bool isPermanentChange;
   }

   User userContract;
   Permission permissionContract;
   QueueSystem queueSystemContract;
   address _owner = msg.sender;
   uint256 currentErrorLogIdCount = 0;
   mapping(uint256 => errorLog) listOfErrorLogs;
   
   event check(string str);
   event noErrorLogsCreatedYet();
   event noMoreErrorLogsUnread();
   event readErrorLog(uint256 errorLogId, address requestSender, string errorMsg, string datasetName, uint dateTime);
   event createdErrorLog(uint256 currentErrorLogIdCount, string errorType);
   event queryPassedToQueue();



   constructor() public {
   }

   constructor(User userAddress, Permission permissionAddress, QueueSystem queueSystemAddress) public {
      userContract = userAddress;
      permissionContract = permissionAddress;
      queueSystemContract = queueSystemAddress;
   }

   // function runQuery(string memory query, string memory datasetName, string memory data, uint256 numTokens) public returns (bool) {
   function runQuery(string memory pointer, string memory query, uint256 new_id, string memory parent, uint256 numTokens) public returns (bool) {
      address reqSender = msg.sender;

      //check user has access to dataset
      if (checkAccessRights(reqSender)) {
         // check user has enough tokens
         if (checkTokens(reqSender, numTokens)) {
            // check user's query is a valid SQL query
            queryCheckResult result = checkQuery(query);
            if (result.hasPassed) {
               // pass on to queue management system
               queueSystem.createRequestEnqueue(new_id, pointer, query, parent, numTokens, reqSender, result.isPermanentChange);
               emit queryPassedToQueue();
               //
            } else {
               createErrorLog(reqSender,"Invalid SQL Query has been provided", datasetName, "Invalid Query");
            }
         } else {
            createErrorLog(reqSender,"User has not enough tokens", datasetName, "Insufficient Tokens");
         }
      } else {
         createErrorLog(reqSender,"User has no access rights to this dataset", datasetName, "No Access");
      }

      return true;
   }


   function checkQuery(string memory input) public returns (queryCheckResult) {
      string memory delimiter = " ";
      string[] memory tokens = input.split(delimiter);
      queryCheckResult memory result = queryCheckResult(false, false);

      if (tokens[0].compareToIgnoreCase("SELECT")) {
         for (uint i = 1; i< tokens.length; i++) {
            if (tokens[i].compareToIgnoreCase("FROM")) {
               result.hasPassed = true;
            }
         }
      } else if (tokens[0].compareToIgnoreCase("INSERT")) {
         if (tokens[1].compareToIgnoreCase("INTO")) {
            for (uint i = 2; i< tokens.length; i++) {
               if (tokens[i].compareToIgnoreCase("VALUES")) {
                  result.hasPassed = true;
                  result.isPermanentChange = true;
               }
            }
         }
      } else if (tokens[0].compareToIgnoreCase("UPDATE")) {
         bool checkFlag = false;
         for (uint i = 2; i< tokens.length; i++) {
            if (!checkFlag) {
               if (tokens[i].compareToIgnoreCase("SET")) {
                  checkFlag = true;
               }
            } else {
               if (tokens[i].compareToIgnoreCase("WHERE")) {
                  result.hasPassed = true;
                  result.isPermanentChange = true;
               }
            }
         }
      } else if (tokens[0].compareToIgnoreCase("DELETE")) {
         if (tokens[1].compareToIgnoreCase("FROM")) {
            result.hasPassed = true;
            result.isPermanentChange = true;
         }
      } else if (tokens[0].compareToIgnoreCase("CREATE")  tokens[0].compareToIgnoreCase("DROP")) {
         if (tokens[1].compareToIgnoreCase("DATABASE")  tokens[1].compareToIgnoreCase("TABLE")) {
            result.hasPassed = true;
            result.isPermanentChange = true;         }
      } else if (tokens[0].compareToIgnoreCase("ALTER")) {
         if (tokens[1].compareToIgnoreCase("TABLE")) {
            result.hasPassed = true;
            result.isPermanentChange = true;         
         }      
      } 
      return result;
   }

   function checkTokens(address user, uint256 numTokens) private returns (bool) {
      //shouldnt there be a method for my contract to call instead of me trying to access the mapping directly like this?
      return userContract.usersCreated[user].tokenCount >= numTokens;
   }

   function checkAccessRights(address user) private returns (bool) {
      //check if user has rights to dataset
      // return permissionContract.checkAccessRights(user);
      return true;
   }



    function createErrorLog(address requestSender, string memory errorMsg, string memory datasetName, string memory errorType) public {
      errorLog memory newErrorLog = errorLog(currentErrorLogIdCount, requestSender, errorMsg, datasetName, block.timestamp, false);
      listOfErrorLogs[currentErrorLogIdCount] = newErrorLog;
      emit createdErrorLog(currentErrorLogIdCount, errorType);
      currentErrorLogIdCount+=1;
   }

   function viewUnreadErrorLogs() public {

      if (currentErrorLogIdCount == 0) {
         emit noErrorLogsCreatedYet();
      } else {
         bool allRead = true;
         for (uint i = 0; i< currentErrorLogIdCount; i++) {
            if (!listOfErrorLogs[i].isRead) {
               allRead = false;
               emit readErrorLog(i, listOfErrorLogs[i].requestSender, listOfErrorLogs[i].errorMsg, listOfErrorLogs[i].datasetName, listOfErrorLogs[i].datetime);
               listOfErrorLogs[i].isRead = true;
            }
         }
         if (allRead) {
            emit noMoreErrorLogsUnread();
         }
      }
   }
}