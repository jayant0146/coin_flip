pragma solidity >=0.7.0 <0.9.0;

contract CoinFlipGame {
    struct Bet {
        uint amount;
        uint bet;
        bool flag;
    }

    mapping(address => Bet) public bets;
    mapping(address => uint) public balances;
    mapping(address => Bet) public rewarded_bets;

    event completed_event(address gambler, uint amount);

    function createBet(uint amt, uint betValue) public {
        if (!bets[msg.sender].flag ) {
            if (balances[msg.sender] - amt > 0) {  
                bets[msg.sender] = Bet(amt, betValue, true);
            }
        }
    }

    function generate_vrf() public view returns (bytes32 result) {
        uint[1] memory bn;
        bn[0] = block.number;
        assembly {
        let memPtr := mload(0x40)
        if iszero(staticcall(not(0), 0xff, bn, 0x20, memPtr, 0x20)) {
            invalid()
        }
        result := mload(memPtr)
        }
    }

    function rewardBets() public {
        if (bets[msg.sender].bet == (uint(generate_vrf()) % 2)) {
            bets[msg.sender].amount *= 2;
            balances[msg.sender] = balances[msg.sender] + bets[msg.sender].amount;
        }

        balances[msg.sender] = balances[msg.sender] - bets[msg.sender].amount;

        rewarded_bets[msg.sender] = bets[msg.sender];

        emit completed_event(msg.sender, rewarded_bets[msg.sender].amount);

        delete bets[msg.sender];
    }
}

