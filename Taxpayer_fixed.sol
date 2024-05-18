// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.19;

contract Taxpayer {

    uint private age; 
    bool private isMarried; 

    /* Reference to spouse if person is married, address(0) otherwise */
    address  private spouse;
    address  private parent1; 
    address  private parent2; 

    /* Constant default income tax allowance */
    uint constant  DEFAULT_ALLOWANCE = 5000;

    /* Constant income tax allowance for Older Taxpayers over 65 */
    uint constant ALLOWANCE_OAP = 7000;

    /* Income tax allowance */
    uint private tax_allowance; 
    uint private income; 


    constructor(address _p1, address _p2) {
        parent1 = _p1;
        parent2 = _p2;
        age = 0;
        isMarried = false;
        spouse = address(0);
        income = 0;
        tax_allowance = DEFAULT_ALLOWANCE;
    } 


    function marry(address _spouse) public {
        require(address(_spouse) != address(0x0)); // can't marry ghosts
        require(_spouse != address(this)); // can't marry yourself
        Taxpayer sp = Taxpayer(_spouse);
        require((sp.getMaritalStatus() == false) && (isMarried == false)); // no polyamorous couples!
        // me to them
        spouse = address(_spouse);
        isMarried = true;
        // them to me
        sp.setSpouse(address(this)); // get consent
        assert(sp.getSpouse() == address(this));
    } /* marry */
    function setSpouse(address _spouse) public {
        /**
         * This function must be called from iside _spouse.marry(address(this)).
         *  otherwise it won't work. This is the second part of the marriage,
         *  commonly known as consent.
         */
        require(isMarried == false);
        Taxpayer sp = Taxpayer(_spouse);
        require(sp.getSpouse() == address(this)); // can't marry without consent
        spouse = _spouse;
        isMarried = true;
    } /* setSpouse */
 

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

    function getSpouse() public view returns (address) {
        return spouse;
    }
    function getMaritalStatus() public view returns (bool) {
        return isMarried;
    }
    function setTaxAllowance(uint ta) public {
        tax_allowance = ta;
    }
    function getTaxAllowance() public view returns (uint) {
        return tax_allowance;
    }
}