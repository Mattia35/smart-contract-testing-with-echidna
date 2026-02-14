pragma solidity ^0.8.22;

import "Lottery.sol";

contract Taxpayer {

  uint age; 

  bool isMarried; 

  bool iscontract;

  /* Reference to spouse if person is married, address(0) otherwise */
  address spouse; 


  address  parent1; 
  address  parent2; 

  /* Constant default income tax allowance */
  uint constant  DEFAULT_ALLOWANCE = 5000;

  /* Constant income tax allowance for Older Taxpayers over 65 */
  uint constant ALLOWANCE_OAP = 7000;

  uint constant MIN_AGE_FOR_MARRIAGE = 18;

  uint constant MIN_AGE_FOR_OAP = 65;

  /* Income tax allowance */
  uint tax_allowance; 

  uint income; 

  uint256 rev;


  //Parents are taxpayers
  constructor(address p1, address p2) {
    age = 0;
    isMarried = false;
    parent1 = p1;
    parent2 = p2;
    spouse = address(0);
    income = 0;
    tax_allowance = DEFAULT_ALLOWANCE;
    iscontract = true;
  } 


  //We require new_spouse != address(0);
  function marry(address new_spouse) public {
    require(!isMarried && !Taxpayer(address(new_spouse)).getIsMarried());
    require(new_spouse != address(this));
    require(age >= MIN_AGE_FOR_MARRIAGE && Taxpayer(address(new_spouse)).getAge() >= MIN_AGE_FOR_MARRIAGE);
    spouse = new_spouse;
    isMarried = true;
    Taxpayer sp = Taxpayer(address(spouse));
    sp.setSpouse(address(this));
    sp.setIsMarried(true);
  }

  function divorce() public {
    Taxpayer sp = Taxpayer(address(spouse));
    sp.setSpouse(address(0));
    sp.setIsMarried(false);
    if (sp.getAge() < MIN_AGE_FOR_OAP) {
      sp.setTaxAllowance(DEFAULT_ALLOWANCE);
    } else {
      sp.setTaxAllowance(ALLOWANCE_OAP);
    }
    spouse = address(0);
    isMarried = false;
    if (age < MIN_AGE_FOR_OAP) {
      setTaxAllowance(DEFAULT_ALLOWANCE);
    } else {
      setTaxAllowance(ALLOWANCE_OAP);
    }
  }

  /* Transfer part of tax allowance to own spouse */
  function transferAllowance(uint change) public {
    tax_allowance = tax_allowance - change;
    Taxpayer sp = Taxpayer(address(spouse));
    sp.setTaxAllowance(sp.getTaxAllowance()+change);
  }

  function haveBirthday() public {
    age++;
    if (age == MIN_AGE_FOR_OAP) {
      tax_allowance = tax_allowance + (ALLOWANCE_OAP - DEFAULT_ALLOWANCE);
    }
  }

  function setTaxAllowance(uint ta) public {
    require(Taxpayer(msg.sender).isContract() || Lottery(msg.sender).isContract());
    tax_allowance = ta;
  }

  function getTaxAllowance() public view returns(uint) {
    return tax_allowance;
  }

  function isContract() public view returns(bool){
    return iscontract;
  }

  function joinLottery(address lot, uint256 r) public {
    Lottery l = Lottery(lot);
    l.commit(keccak256(abi.encode(r)));
    rev = r;
  }

    function revealLottery(address lot, uint256 r) public {
    Lottery l = Lottery(lot);
    l.reveal(r);
    rev = 0;
  }

  function getIsMarried() public view returns(bool) {
    return isMarried;
  }

  function getSpouse() public view returns(address) {
    return spouse;
  }

  function setIsMarried(bool im) public {
    require(Taxpayer(msg.sender).isContract());
    isMarried = im;
  }

  function setSpouse(address sp) public {
    require(Taxpayer(msg.sender).isContract());
    spouse = sp;
  }

  function getAge() public view returns(uint) {
    return age;
  }

}
