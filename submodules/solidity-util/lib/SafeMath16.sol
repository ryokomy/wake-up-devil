pragma solidity >0.4.24 <0.6.0;

/**
 * @title SafeMath16
 * @dev Modified SafeMath in openzeppelin-eth v2.1.3
 * @dev Fixed by Ryo Komiyama <https://github.com/ryokomy>
 */
library SafeMath16 {

    function mul(uint16 a, uint16 b) internal pure returns (uint16) {
        if (a == 0) {
            return 0;
        }

        uint16 c = a * b;
        require(c / a == b, "mul: reverts on SafeMath16");

        return c;
    }

    function div(uint16 a, uint16 b) internal pure returns (uint16) {
        require(b > 0, "div: reverts on SafeMath16");
        uint16 c = a / b;

        return c;
    }

    function sub(uint16 a, uint16 b) internal pure returns (uint16) {
        require(b <= a, "sub: reverts on SafeMath16");
        uint16 c = a - b;

        return c;
    }

    function add(uint16 a, uint16 b) internal pure returns (uint16) {
        uint16 c = a + b;
        require(c >= a, "add: reverts on SafeMath16");

        return c;
    }

    function mod(uint16 a, uint16 b) internal pure returns (uint16) {
        require(b != 0, "mod: reverts on SafeMath16");
        return a % b;
    }
    
}
