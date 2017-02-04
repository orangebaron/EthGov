pragma solidity ^0.4.8;

contract OrangeGov_Main {
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
	    contractIDs[ID]=addr;
	    contractIDExists[ID]=true;
	}
	function removeContract(string ID) permissionRequired("removeContract",""){
	    contractIDExists[ID]=false;
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
    modifier permissionRequired(string permissionName,string userStatusAllowed) { //userStatusAllowed - a certain user status is the only thing necessary to run the function
        _;
        if (!OrangeGov_Main(main).getHasPermission(msg.sender,permissionName,userStatusAllowed)){
            throw;
        }
    }
}