pragma solidity ^0.5.0;
import "./Strings.sol";
import "./QueueSystem.sol";
import "./Permission.sol";
import "./User.sol";
import "./Role.sol";

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

   bool hasPassed;
   bool isPermanentChange;

   User userContract;
   Permission permissionContract;
   QueueSystem queueSystemContract;
   Role roleContract;   
   address _owner = msg.sender;
   uint256 currentErrorLogIdCount = 0;
   mapping(uint256 => errorLog) listOfErrorLogs;
   
   event check(string str);
   event noErrorLogsCreatedYet();
   event noMoreErrorLogsUnread();
   event readErrorLog(uint256 errorLogId, address requestSender, string errorMsg, string datasetName, uint dateTime);
   event createdErrorLog(uint256 currentErrorLogIdCount, string errorType);
   event queryPassedToQueue();


   constructor(User userAddress, Permission permissionAddress, Role roleAddress, QueueSystem queueSystemAddress) public {
      userContract = userAddress;
      permissionContract = permissionAddress;
      roleContract = roleAddress;
      queueSystemContract = queueSystemAddress;
   }

   function runQuery(string memory pointer, string memory query, string memory new_id, string memory parent, uint256 numTokens, uint256 permissionId) public returns (bool) {
      address reqSender = msg.sender;

      //check user has access to dataset
      if (checkAccessRights(reqSender,permissionId)) {
         // check user has enough tokens
         if (checkTokens(reqSender, numTokens)) {
            // check user's query is a valid SQL query
            checkQuery(query);
            if (hasPassed) {
               // pass on to queue management system
               queueSystemContract.createRequestEnqueue(new_id, pointer, query, parent, numTokens, reqSender, isPermanentChange);
               emit queryPassedToQueue();
               //
            } else {
               createErrorLog(reqSender,"Invalid SQL Query has been provided", pointer, "Invalid Query");
            }
         } else {
            createErrorLog(reqSender,"User has not enough tokens", pointer, "Insufficient Tokens");
         }
      } else {
         createErrorLog(reqSender,"User has no access rights to this dataset", pointer, "No Access");
      }

      return true;
   }


   function checkQuery(string memory input) public {
      string memory delimiter = " ";
      string[] memory tokens = input.split(delimiter);

      hasPassed = false;
      isPermanentChange = false;

      if (tokens[0].compareToIgnoreCase("SELECT")) {
         for (uint i = 1; i< tokens.length; i++) {
            if (tokens[i].compareToIgnoreCase("FROM")) {
               hasPassed = true;
            }
         }
      } else if (tokens[0].compareToIgnoreCase("INSERT")) {
         if (tokens[1].compareToIgnoreCase("INTO")) {
            for (uint i = 2; i< tokens.length; i++) {
               if (tokens[i].compareToIgnoreCase("VALUES")) {
                  hasPassed = true;
                  isPermanentChange = true;
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
                  hasPassed = true;
                  isPermanentChange = true;
               }
            }
         }
      } else if (tokens[0].compareToIgnoreCase("DELETE")) {
         if (tokens[1].compareToIgnoreCase("FROM")) {
            hasPassed = true;
            isPermanentChange = true;
         }
      } else if (tokens[0].compareToIgnoreCase("CREATE") || tokens[0].compareToIgnoreCase("DROP")) {
         if (tokens[1].compareToIgnoreCase("DATABASE") || tokens[1].compareToIgnoreCase("TABLE")) {
            hasPassed = true;
            isPermanentChange = true;         }
      } else if (tokens[0].compareToIgnoreCase("ALTER")) {
         if (tokens[1].compareToIgnoreCase("TABLE")) {
            hasPassed = true;
            isPermanentChange = true;         
         }      
      } 
   }

   function checkTokens(address user, uint256 numTokens) private view returns (bool) {
      //shouldnt there be a method for my contract to call instead of me trying to access the mapping directly like this?
      return userContract.getTokenBalance(user) >= numTokens;
   }

   function checkAccessRights(address user, uint256 permissionId) private view returns (bool) {
      //check if user has rights to dataset
      return roleContract.checkUserPermission(user, permissionId);
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