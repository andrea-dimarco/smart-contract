// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.19;
import './Taxpayer_fixed.sol';

contract Fuzzer {

    // Constants
    uint constant DEFAULT_ALLOWANCE = 5000;
    uint constant ALLOWANCE_OAP = 7000;

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

    Taxpayer[] private all_citizens;



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

        all_citizens = [person_1, person_2, person_3];
    } /* constructor */


    /**
     * P1: if x is married to y --> y is also be married (and) to x
     */

    function echidna_test_marriage() public view returns (bool) {
        Taxpayer husband;
        Taxpayer wife;
        bool partner_condition;
        bool ring_condition;
        bool property;
        // check all couples
        for (uint8 i = 0; i < (all_citizens.length-1); i++) {
            husband = all_citizens[i];
            for (uint8 j = (i+1); j < all_citizens.length; j++) {
                wife = all_citizens[j];
                    // (if married) --> (they must be each other's partner)
                partner_condition = ( husband.getSpouse() != address(wife) ) 
                                        || ( wife.getSpouse() == address(husband) );
                    // (if married) --> (they must both be married)
                ring_condition = ( husband.getSpouse() != address(wife) )
                                        || ( husband.getMaritalStatus() && wife.getMaritalStatus() );
                property = partner_condition && ring_condition;
                if (property == false) {
                    return false;
                }
            }
        }
        return true;
    } /* echidna_test_marriage */
    
        /* These functions challenge P1 */
    
    function marry(uint8 _p1, uint8 _p2) public {
        require(_p1 < all_citizens.length && _p2 <  all_citizens.length);
        all_citizens[_p1].marry(address(all_citizens[_p2]));
    } /* marry */
    function set_spouse(uint8 _p1, uint8 _p2) public {
        require(_p1 < all_citizens.length && _p2 <  all_citizens.length);
        all_citizens[_p1].setSpouse(address(all_citizens[_p2]));
    } /* marry */
    
    
    function divorce(uint8 _p) public {
        require(_p < all_citizens.length); 
        all_citizens[_p].divorce();
    } /* divorce */


    /** 
      * P2-3: Income tax allowance:
      * - Every person has an income tax allowance on which no tax is paid. 
      *    There is a default tax allowance of 5000 per individual, and only income above 
      *    this amount is taxed.
      *
      * - Married persons can pool their tax allowance as long as the sum of their tax allowances 
      *    remains the same.
      *    For example, the wife could have a tax allowance of 9000, and the husband a tax allowance of 1000.
      *    Add invariants that express these constraints, and, if necessary, fix/improve the code to ensure
      *    that they are not violated.
      */
    
    function echidna_test_allowance_married() public returns (bool) {
        Taxpayer person;
        Taxpayer wife;
        uint old_allowance_sum;
        uint new_allowance_sum;
        for (uint8 i=0; i < all_citizens.length; i++) {
            person = all_citizens[i];
            if (person.getMaritalStatus()) {
                // has a partner
                wife = Taxpayer(person.getSpouse());
                old_allowance_sum = person.getTaxAllowance() + wife.getTaxAllowance();
                person.transferAllowance(1);
                new_allowance_sum = person.getTaxAllowance() + wife.getTaxAllowance();
                if (old_allowance_sum != new_allowance_sum) {
                    return false;
                }
            } 
        }
        return true;
    }
    
    function echidna_test_allowance_single() public returns (bool) {
        Taxpayer person;
        uint old_allowance = 0;
        uint new_allowance = 0;
        for (uint8 i=0; i < all_citizens.length; i++) {
            person = all_citizens[i];
            if (person.getMaritalStatus() == false) {
                old_allowance = person.getTaxAllowance();
                try person.transferAllowance(1) {
                    new_allowance = person.getTaxAllowance();
                } catch {
                    new_allowance = person.getTaxAllowance();
                }
                if (old_allowance != new_allowance) {
                    return false;
                }
            }
        }
        return true;
    }
    
    function echidna_test_allowance_divorce() public returns (bool) {
        Taxpayer person;
        uint allowance;
        for (uint8 i=0; i < all_citizens.length; i++) {
            person = all_citizens[i];
            if (person.getMaritalStatus()) {
                if (person.getAge() >= 65) {
                    allowance = ALLOWANCE_OAP;
                } else {
                    allowance = DEFAULT_ALLOWANCE;
                }

                person.divorce();
                if (person.getTaxAllowance() != allowance) {
                    return false;
                }
            }
        }
        return true;
    }
    
        /* this function challenges P2-3 */

    function agePerson(uint8 _p) public {
        require(_p < all_citizens.length);
        all_citizens[_p].haveBirthday();
    }


    /**
     * Check this with assertion mode
     */
    function assert_test_allowance(uint8 _p, uint _change) public {
        require(_p < all_citizens.length);
        Taxpayer person;
        Taxpayer wife;
        uint old_allowance_sum;
        uint new_allowance_sum;
        person = all_citizens[_p];
        uint default_allowance;
        if (person.getMaritalStatus()) {
            // has a partner
            wife = Taxpayer(person.getSpouse());
            old_allowance_sum = person.getTaxAllowance() + wife.getTaxAllowance();
            person.transferAllowance(_change);
            new_allowance_sum = person.getTaxAllowance() + wife.getTaxAllowance();
        } else {
            // doesn't have a partner
            if (person.getMaritalStatus() == false) {
                old_allowance_sum = person.getTaxAllowance();
                try person.transferAllowance(1) {
                    new_allowance_sum = person.getTaxAllowance();
                } catch {
                    new_allowance_sum = person.getTaxAllowance();
                }
                assert(old_allowance_sum == new_allowance_sum);
            }
        }
        assert(old_allowance_sum == new_allowance_sum);

        // after divorce allowance has to be the default amount
        if (person.getAge() >= 65) {
            default_allowance = ALLOWANCE_OAP;
        } else {
            default_allowance = DEFAULT_ALLOWANCE;
        }
        if (person.getMaritalStatus()) {
            person.divorce();
            assert(person.getTaxAllowance() == default_allowance);
        }
    }
}
