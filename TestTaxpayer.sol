pragma solidity ^0.8.22;

import "Taxpayer.sol";

contract TestTaxpayer is Taxpayer {
    
    Taxpayer other_1;
    Taxpayer other_2;

    constructor() Taxpayer(address(0x111), address(0x222)) {
        other_1 = new Taxpayer(address(0x123), address(0x456));
        other_2 = new Taxpayer(address(0x789), address(0xabc));
    }




/*-------------------------------ECHIDNA INVARIANTS-------------------------------*/




    function echidna_1_is_correctly_married() public view returns (bool) {
        // check if the first user and his/her spouse are correctly married
        if (isMarried) {
            Taxpayer sp = Taxpayer(address(spouse));
            if (sp.isContract()) {
                return (sp.getIsMarried() && sp.getSpouse() == address(this));
            }
            return false;
        }
        return true;
    }

    function echidna_2_is_correctly_married() public view returns (bool) {
        // check if the second user and his/her spouse are correctly married
        if (other_1.getIsMarried()) {
            Taxpayer sp = Taxpayer(address(other_1.getSpouse()));
            if (sp.isContract()) {
                return (sp.getIsMarried() && sp.getSpouse() == address(other_1));
            }
            return false;
        }
        return true;
    }

    function echidna_3_is_correctly_married() public view returns (bool) {
        // check if the third user and his/her spouse are correctly married
        if (other_2.getIsMarried()) {
            Taxpayer sp = Taxpayer(address(other_2.getSpouse()));
            if (sp.isContract()) {
                return (sp.getIsMarried() && sp.getSpouse() == address(other_2));
            }
            return false;
        }
        return true;
    }

    function echidna_1_not_self_married() public view returns (bool) {
        // check if the first user is not married to himself/herself
        if (isMarried) {
            return spouse != address(this);
        }
        return true;
    }

    function echidna_2_not_self_married() public view returns (bool) {
        // check if the second user is not married to himself/herself
        if (other_1.getIsMarried()) {
            return other_1.getSpouse() != address(other_1);
        }
        return true;
    }

    function echidna_3_not_self_married() public view returns (bool) {
        // check if the third user is not married to himself/herself
        if (other_2.getIsMarried()) {
            return other_2.getSpouse() != address(other_2);
        }
        return true;
    }

    function echidna_1_min_age_for_marriage() public view returns (bool) {
        // check if the age is >= MIN_AGE_FOR_MARRIAGE when married
        if (isMarried) {
            return Taxpayer(address(spouse)).getAge() >= MIN_AGE_FOR_MARRIAGE && age >= MIN_AGE_FOR_MARRIAGE;
        }
        return true;
    }

    function echidna_2_min_age_for_marriage() public view returns (bool) {
        // check if the age is >= MIN_AGE_FOR_MARRIAGE when married
        if (other_1.getIsMarried()) {
            return Taxpayer(address(other_1.getSpouse())).getAge() >= MIN_AGE_FOR_MARRIAGE && other_1.getAge() >= MIN_AGE_FOR_MARRIAGE;
        }
        return true;
    }

    function echidna_3_min_age_for_marriage() public view returns (bool) {
        // check if the age is >= MIN_AGE_FOR_MARRIAGE when married
        if (other_2.getIsMarried()) {
            return Taxpayer(address(other_2.getSpouse())).getAge() >= MIN_AGE_FOR_MARRIAGE && other_2.getAge() >= MIN_AGE_FOR_MARRIAGE;
        }
        return true;
    }

    function echidna_1_tax_is_balanced() public view returns (bool) {
        // check if the spouse and the first taxpayer have the total tax allowance equal to 2 * DEFAULT_ALLOWANCE
        if (isMarried) {
            Taxpayer sp = Taxpayer(address(spouse));
            if (sp.isContract()) {
                if (age < MIN_AGE_FOR_OAP && sp.getAge() < MIN_AGE_FOR_OAP) {
                    return tax_allowance + sp.getTaxAllowance() == 2 * DEFAULT_ALLOWANCE;
                }
                else if (age >= MIN_AGE_FOR_OAP && sp.getAge() >= MIN_AGE_FOR_OAP) {
                    return tax_allowance + sp.getTaxAllowance() == 2 * ALLOWANCE_OAP;
                }
                else {
                    return tax_allowance + sp.getTaxAllowance() == DEFAULT_ALLOWANCE + ALLOWANCE_OAP;
                }
            }
        }
        return true;
    }

    function echidna_2_tax_is_balanced() public view returns (bool) {
        // check if the spouse and the second taxpayer have the total tax allowance equal to 2 * DEFAULT_ALLOWANCE
        if (other_1.getIsMarried()) {
            Taxpayer sp = Taxpayer(address(other_1.getSpouse()));
            if (sp.isContract()) {
                if (other_1.getAge() < MIN_AGE_FOR_OAP && sp.getAge() < MIN_AGE_FOR_OAP) {
                    return other_1.getTaxAllowance() + sp.getTaxAllowance() == 2 * DEFAULT_ALLOWANCE;
                }
                else if (other_1.getAge() >= MIN_AGE_FOR_OAP && sp.getAge() >= MIN_AGE_FOR_OAP) {
                    return other_1.getTaxAllowance() + sp.getTaxAllowance() == 2 * ALLOWANCE_OAP;
                }
                else {
                    return other_1.getTaxAllowance() + sp.getTaxAllowance() == DEFAULT_ALLOWANCE + ALLOWANCE_OAP;
                }
            }
        }
        return true;
    }

    function echidna_3_tax_is_balanced() public view returns (bool) {
        // check if the spouse and the third taxpayer have the total tax allowance equal to 2 * DEFAULT_ALLOWANCE
        if (other_2.getIsMarried()) {
            Taxpayer sp = Taxpayer(address(other_2.getSpouse()));
            if (sp.isContract()) {
                if (other_2.getAge() < MIN_AGE_FOR_OAP && sp.getAge() < MIN_AGE_FOR_OAP) {
                    return other_2.getTaxAllowance() + sp.getTaxAllowance() == 2 * DEFAULT_ALLOWANCE;
                }
                else if (other_2.getAge() >= MIN_AGE_FOR_OAP && sp.getAge() >= MIN_AGE_FOR_OAP) {
                    return other_2.getTaxAllowance() + sp.getTaxAllowance() == 2 * ALLOWANCE_OAP;
                }
                else {
                    return other_2.getTaxAllowance() + sp.getTaxAllowance() == DEFAULT_ALLOWANCE + ALLOWANCE_OAP;
                }
            }
        }
        return true;
    }




/*-------------------------------EXTRA FUNCTIONS-------------------------------*/




    function force_valid_marriage_1_to_2() public {
        marry(address(other_1));
    }

    function force_valid_marriage_1_to_3() public {
        marry(address(other_2));
    }

    function force_valid_marriage_2_to_1() public {
        other_1.marry(address(this));
    }

    function force_valid_marriage_2_to_3() public {
        other_1.marry(address(other_2));
    }

    function force_valid_marriage_3_to_2() public {
        other_2.marry(address(other_1));
    }

    function force_valid_marriage_3_to_1() public {
        other_2.marry(address(this));
    }

        function force_valid_divorce_2() public {
        other_1.divorce();
    }

    function force_valid_divorce_3() public {
        other_2.divorce();
    }

    function force_2_self_marriage() public {
        other_1.marry(address(other_1));
    }

    function force_3_self_marriage() public {
        other_2.marry(address(other_2));
    }

    function force_2_have_birthday() public {
        other_1.haveBirthday();
    }

    function force_3_have_birthday() public {
        other_2.haveBirthday();
    }

}