pragma solidity >=0.4.99 <0.6.0;

import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";

interface Devil {
    function stolen() external;
}
