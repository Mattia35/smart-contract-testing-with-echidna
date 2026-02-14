pragma solidity ^0.8.22;
// SPDX-License-Identifier: UNLICENSED
import "Taxpayer.sol";

contract Lottery {
address owner;
mapping (address => bytes32) commits;
mapping (address => uint) reveals;
address[] revealed;

uint256 startTime;
uint256 revealTime;
uint256 endTime;
uint256 period;
bool iscontract;
uint constant MIN_AGE_FOR_JOIN = 65;
bool isStarted = false;

// Initialize the registry with the lottery period.
 constructor(uint p) {
  period = p;
  startTime = 0;
  endTime = 0;
  iscontract=true;
 } 


//If the lottery has not started, anyone can invoke a lottery.
function startLottery() public {
  require(isStarted==false);
  require (startTime == 0);
  //startTime current time. Users send their committed value
  startTime = block.timestamp;
  //revealTime  time for revealing. User reveal their value
  revealTime = startTime+period;
  //endTime a winner can be computed
  endTime = revealTime+period;
  isStarted = true;
}

//A taxpayer send his own commitment. 
function commit(bytes32 y) public {
  require(isStarted==true);
  Taxpayer tp = Taxpayer(msg.sender);
  require(tp.getAge() >= MIN_AGE_FOR_JOIN);
  require(block.timestamp >= startTime);
  commits[msg.sender] = y;
}

//A valid taxpayer who sent his own commitment, sends the revealing value.
function reveal(uint256 rev) public {
  require(isStarted==true);
  require(block.timestamp >= revealTime);
  require(keccak256(abi.encode(rev))==commits[msg.sender]);
  for (uint i=0; i<revealed.length; i++){
    require(revealed[i]!=msg.sender);
  }
  revealed.push(msg.sender);
  reveals[msg.sender] = uint(rev);
  
}

//Ends the lottery and compute the winner.
function endLottery() public {
  require(isStarted==true);
  require(block.timestamp >= endTime);
  uint total = 0;
  for (uint i = 0; i < revealed.length; i++){
    total+= reveals[revealed[i]];
  }
  Taxpayer(revealed[total%revealed.length]).setTaxAllowance(9000);
  startTime = 0;
  revealTime = 0;
  endTime = 0;
  isStarted = false;
  delete revealed;
}
  function isContract() public view returns(bool) {
    return iscontract;
  }

}
