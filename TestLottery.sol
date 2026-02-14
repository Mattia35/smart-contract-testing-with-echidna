pragma solidity ^0.8.22;

import "Lottery.sol";
import "Taxpayer.sol";

contract TestLottery is Lottery {
    mapping (address => uint) local_joins;
    Taxpayer joiner;

    constructor() Lottery(1) {
        joiner = new Taxpayer(address(0x123), address(0x456));
    }

/*-------------------------------ECHIDNA INVARIANTS-------------------------------*/
    function echidna_no_multiple_access() public returns (bool) {
        // check if a taxpayer joins multiple times
        for (uint i = 0; i < revealed.length; i++){
            local_joins[revealed[i]]= local_joins[revealed[i]] + 1;
            if (local_joins[revealed[i]] > 1) {
                return false;
            }
        }
        return true;
    }

    function echidna_min_age_for_join() public view returns (bool) {
        // check if a taxpayer is at least 18 years old to join the lottery
        for (uint i = 0; i < revealed.length; i++){
            Taxpayer tp = Taxpayer(revealed[i]);
            if (tp.getAge() < MIN_AGE_FOR_JOIN) {
                return false;
            }
        }
        return true;
    }

    function echidna_has_clean_data_structures() public view returns (bool) {
        if (startTime == 0 && revealTime == 0 && endTime == 0 && revealed.length != 0) {
            return false;
        }
        return true;
    }

/*-------------------------------EXTRA FUNCTIONS-------------------------------*/
    function force_join() public {
        joiner.joinLottery(address(this), uint256(34));
    }

    function force_reveal() public {
        joiner.revealLottery(address(this), uint256(34));
    }

    function force_have_birthday() public {
        joiner.haveBirthday();
    }
}