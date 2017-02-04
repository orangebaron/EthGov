#List of Contracts

\* = function doesn't require special permissions

** = function only requires citizenship

// = comment

[opt] = optional

Main
 - Permissions: All
 - Functions:
  - addContract(code,permissions,id)
  - removeContract(id)
  - updateContract(id,code)
  - update(code)
  - spendEther(address,amt)
  - givePermission(address,permission) //even if you "have permission" to use this you can only give permissions you already have

Government
 - Permissions: All
 - Functions:
  - proposeAct(functionList,argument2dList)** returns id
  - vote(id,y/n,lastVoteDigitalSigPubKey[opt])** //lastVoteDigitalSigPubKey is for when you did a group anonymous vote(explained below) and want to override your last vote
  - groupAnonymousVote(voterList,y/nSum,individualVoteDigitalSignatures[opt])** //can't be done if you're a delegate; individualVoteDigitalSignatures is for when you want to be able to undo your vote later; generate a random private key, encrypt a nonce plus your vote, and put the generated number and your nonce into the table; to reveal later, give the public key
  - setDelegate(address,permissions)**
  - agreeToBeDelegate(address,y/n)**
  - setMajorityNeeded(function,percent)

CitizenManager
 - Permissions: None
 - Functions:
  - addCitizen(address)
  - removeCitizen(address) //you have permission to remove yourself
  - applyForCitizenship()*

DataStorage //used for code verification, forum uploads, government documents, etc
 - Permissions: None
 - Functions:
  - uploadData(name,description,data)* returns id
  - verifyLawCode(dataId,lawId)*

TokenManager
 - Permissions: None
 - Functions:
  - *//all the g20 functions but the transaction event also has a random id as an argument and using that id, tax rates can be manually changed within 10 minutes
  - setTax(rate) //tax rate on all transactions
  - manuallySetRate(transactionID)
  - sendTokenAsGov(address,amt) //tax free

Bank
 - Permissions:
  - TokenManager.sendTokenAsGov
  - spendEther
 - Functions:
  - takeOutTokenLoan(amt)*
  - takeOutEtherLoan(amt)*
  - etherToTok()* is payable
  - tokToEther(amt)*
  - setTokLoanRate(rate)
  - setEthLoanRate(rate)
  - setEthToTokRate(rate)
  - setTokToEthRate(rate)

Forum //name is a bit misleading; this can also be used for emails and private messaging rooms
 - Permissions: none
 - Functions:
  - startThread(msg,unlisted,subforumId)* returns id //unlisted indicates that you _could_ look at it but you would see a bunch of random encrypted messages bc it's a private room
  - tellThreadKey(address,encodedKey,threadId)* //triggers an alert with the same info passed into it; encodedKey should be the forum key encoded with address's public key
  - post(msg,threadId)* returns id
  - startSubforum(name)* returns id //starts a subforum that you own; name is purely for vanity
  - removeMsg(id) //can always remove your own messages
  - setMembershipLvl(subforumId,address,lvl) //0: banned, 1: normal, 2: can remove msgs of lower tiers and set memberships of lower levels to 0 or 1, 3: can remove lower-lvl messages+set lower level users' levels to 0, 1, or 2, etc
