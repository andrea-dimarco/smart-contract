// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.19;
import './Taxpayer_fixed.sol';

contract Fuzzer {

    // Variables
    address private fake_address_1;
    address private fake_address_2;
    address private fake_address_3;
    address private fake_address_4;
    address private fake_address_5;
    address private fake_address_6;

    // Objects
    Taxpayer private person_1;
    Taxpayer private person_2;
    Taxpayer private person_3;



    constructor() {
        fake_address_1 = address(0x100);
        fake_address_2 = address(0x200);
        fake_address_3 = address(0x300);
        fake_address_4 = address(0x400);
        fake_address_5 = address(0x500);
        fake_address_6 = address(0x600);

        person_1 = new Taxpayer(fake_address_1, fake_address_2);
        person_2 = new Taxpayer(fake_address_3, fake_address_4);
        person_3 = new Taxpayer(fake_address_5, fake_address_6);
    }

    /* For every property P either:
     *      (1) Fix the Taxpayer contract to satisfy P
     *      (2) Add "require(...)" statements to prevent illegal executions
     *      (3) Add invariant for another property that can help in the verification
     */

    /**
     * P1: if x is married to y --> y is also be married (and) to x
     */
    function echidna_test_marriage() public view returns (bool property) {
        bool p1_married_to_p2 = ( person_1.getSpouse() != address(person_2) ) || ( person_2.getSpouse() == address(person_1) );
        bool p2_married_to_p1 = ( person_2.getSpouse() != address(person_1) ) || ( person_1.getSpouse() == address(person_2) );
        property = p1_married_to_p2 && p2_married_to_p1;
    }
        /* These functions challenge P1 */
    function marry(Taxpayer _p1, Taxpayer _p2) public {
        _p1.marry(address(_p2));
    }
    function divorce(Taxpayer _p) public {
        _p.divorce();
    }


    /* P2: */
    function echidna_test_p2() public view returns (bool property) {
        
        property = true;
    }
}
