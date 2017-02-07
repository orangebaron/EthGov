pragma solidity ^0.4.8;

contract OrangeGov_Template {
    address public currentContract;
    address main;
    function changeMain(address newMain){
        if (msg.sender==main){
            main=newMain;
        }
    }
    function changeCurrentContract(address newCurrent){
        if (msg.sender==main){
            currentContract=newCurrent;
        }
    }
    modifier permissionRequired(string permissionName,string userStatusAllowed) { //userStatusAllowed - a certain user status is the only thing necessary to run the function
        _;
        if (!main.call.gas(msg.gas)(bytes4(sha3("getHasPermission(address,string,string) returns bool")),msg.sender,permissionName,userStatusAllowed)){
            throw;
        }
    }
    
    function OrangeGov_Template (address currentMain){
        main = msg.sender;
    }
    //TO GATHER DATA FROM PREVIOUS CONTRACT, MAKE A FUNCTION CALLED tellPreviousContract(address prev) WHICH FEEDS IT THE PREVIOUS CONTRACT'S ADDRESS
}