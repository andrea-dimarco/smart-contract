pragma solidity ^0.8.22;

contract Taxpayer {

 uint age; 

 bool isMarried; 

 /* Reference to spouse if person is married, address(0) otherwise */
 address spouse; 


address  parent1; 
address  parent2; 

 /* Constant default income tax allowance */
 uint constant  DEFAULT_ALLOWANCE = 5000;

 /* Constant income tax allowance for Older Taxpayers over 65 */
  uint constant ALLOWANCE_OAP = 7000;

 /* Income tax allowance */
 uint tax_allowance; 

 uint income; 


 constructor(address p1, address p2) {
   age = 0;
   isMarried = false;
   parent1 = p1;
   parent2 = p2;
   spouse = address(0);
   income = 0;
   tax_allowance = DEFAULT_ALLOWANCE;
 } 


 //We require new_spouse != address(0);
 function marry(address new_spouse) public {
  spouse = new_spouse;
  isMarried = true;
 }
 
 function divorce() public {
  Taxpayer sp = Taxpayer(address(spouse));
  sp.setSpouse(address(0));
  spouse = address(0);
  isMarried = false;
 }

 /* Transfer part of tax allowance to own spouse */
 function transferAllowance(uint change) public {
  tax_allowance = tax_allowance - change;
  Taxpayer sp = Taxpayer(address(spouse));
  sp.setTaxAllowance(sp.getTaxAllowance()+change);
 }

 function haveBirthday() public {
  age++;
 }

function setSpouse(address sp) public {
    spouse = sp;
}
function getSpouse() public returns (address) {
    return spouse;
}
function setTaxAllowance(uint ta) public {
    tax_allowance = ta;
}
function getTaxAllowance() public returns (uint) {
    return tax_allowance;
}
}
