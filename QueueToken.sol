pragma solidity ^0.5.0;
import "./ERC20.sol";


contract QueueToken {
    ERC20 erc20Contract;
    uint256 supplyLimit; 
    address owner;
    

    constructor() public {
        ERC20 e = new ERC20();
        erc20Contract = e;
        owner = msg.sender;
        supplyLimit = 100000; // what is the limit we are setting???
    }
    /**
    * @dev Function to give DT to the recipient for a given wei amount
    * @param recipient address of the recipient that wants to buy the DT
    * @param weiAmt uint256 amount indicating the amount of wei that was passed
    * @return A uint256 representing the amount of DT bought by the msg.sender.
    */

    function getCredit(address recipient, uint256 weiAmt)
        public
        returns (uint256)
    {
        uint256 amt = weiAmt / (1000000000000000000/100); // how much are we issuing for db upload???
        erc20Contract.mint(recipient, amt);
        return amt; 
    }

    function checkCredit(address ad) public view returns (uint256) {
        uint256 credit = erc20Contract.balanceOf(ad);
        return credit; 
    }

    function transferCredit(address sender, address reciepient, uint256 amt) public {
        // Transfers from tx.origin to receipient
        erc20Contract.transferFrom(sender, reciepient, amt);
    }
}
