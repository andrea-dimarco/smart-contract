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
    uint constant DEFAULT_ALLOWANCE = 5000;

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
        require(address(_spouse) != address(0)); // can't marry ghosts
        require(_spouse != address(this)); // can't marry yourself
        Taxpayer sp = Taxpayer(_spouse);
        require((sp.getMaritalStatus() == false) && (isMarried == false)); // no multiple partners!
        // me to them
        spouse = address(_spouse);
        isMarried = true;
        // them to me
        sp.setSpouse(address(this)); // get consent
    } /* marry */

    function setSpouse(address _spouse) public {
        require(isMarried == false);
        Taxpayer sp = Taxpayer(_spouse);
        require(sp.getSpouse() == address(this)); // can't marry without consent
        spouse = _spouse;
        isMarried = true;
    } /* setSpouse */
    
    
    function getSpouse() public view returns (address) {
        return spouse;
    } /* getSpouse */
    function getMaritalStatus() public view returns (bool) {
        return isMarried;
    }

    function divorce() public {
        require(isMarried);
        Taxpayer sp = Taxpayer(address(spouse));
        spouse = address(0);
        isMarried = false;
        if (age >= 65) {
            setTaxAllowance(ALLOWANCE_OAP);
        } else {
            setTaxAllowance(DEFAULT_ALLOWANCE);
        }
        // partner must also divorce
        if (sp.getMaritalStatus()) {
            sp.divorce();
        }
    } /* divorce */


    /* Transfer part of tax allowance to own spouse */
    function transferAllowance(uint _change) public {
        require(isMarried); // can only transfer to partner
        require(tax_allowance >= _change); // can't transfer more than is owned
        Taxpayer sp = Taxpayer(address(spouse));
        sp.setTaxAllowance(sp.getTaxAllowance() + _change);
        tax_allowance = tax_allowance - _change;
    }

    function getAge() public view returns (uint) {
        return age;
    }

    function haveBirthday() public {
        age++;
    }

    function setTaxAllowance(uint ta) public {
        tax_allowance = ta;
    }
    function getTaxAllowance() public view returns (uint) {
        return tax_allowance;
    }
}