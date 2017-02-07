pragma solidity ^0.4.8;

contract OrangeGov_Main {
    address public currentContract;
    
	mapping(address=>mapping(string=>bool)) permissions;
	mapping(address=>mapping(string=>bool)) userStatuses;
	mapping(string=>address) addresses;
	mapping(string=>address) contractIDs;
	mapping(string=>bool) contractIDExists;
	function getHasPermission(address user, string permissionName, string userStatusAllowed) returns (bool hasPermission){ //for use between contracts
	    return permissions[msg.sender][permissionName]||permissions[msg.sender]["all"]||userStatuses[msg.sender][userStatusAllowed];
	}
	function getContractByID(string ID) returns (address addr,bool exists){ //for use between contracts
	    return (contractIDs[ID],contractIDExists[ID]);
	}
	
    modifier permissionRequired(string permissionName,string userStatusAllowed) {
        _; //code will be run; code MUST have variable permissionName(name of permission) and userStatusAllowed(a certain user statu is the only thing necessary)
        if (getHasPermission(msg.sender,permissionName,userStatusAllowed)){
            throw;
        }
    }
    
	function addContract(string ID,bytes code) permissionRequired("addContract",""){
	    address addr;
        assembly {
            addr := create(0,add(code,0x20), mload(code))
            jumpi(invalidJumpLabel,iszero(extcodesize(addr)))
        }
        address oldAddr = contractIDs[ID];
	    contractIDs[ID]=addr;
	    contractIDExists[ID]=true;
	    //warnings below are irrelevant
	    oldAddr.call.gas(msg.gas)(bytes4(sha3("changeCurrentContract(address)")),addr); //if there was a previous contract, tell it the new one's address
	    addr.call.gas(msg.gas)(bytes4(sha3("tellPreviousContract(address)")),oldAddr); //feed it the address of the previous contract
	}
	function removeContract(string ID) permissionRequired("removeContract",""){
	    contractIDExists[ID]=false;
	    //warning below is irrelevant
	    contractIDs[ID].call.gas(msg.gas)(bytes4(sha3("changeCurrentContract(address)")),currentContract); //make sure people using know it's out of service
	}
	//TO DO HERE: UPDATE
	function spendEther(address addr, uint256 weiAmt) permissionRequired("spendEther",""){
	    if (!addr.send(weiAmt)) throw;
	}
	function givePermission(address addr, string permission) permissionRequired("givePermission",""){
	    if (getHasPermission(msg.sender,permission,"")){
	        permissions[addr][permission]=true;
	    }
	}
	function removePermission(address addr, string permission) permissionRequired("removePermission",""){
	    permissions[addr][permission]=false;
	}
}

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