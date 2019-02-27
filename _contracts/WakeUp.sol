pragma solidity >=0.4.21 <0.6.0;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "./SafeMath16.sol";

/**
 * @title WakeUp
 * @author Ryo Komiyama <https://github.com/ryokomy>
 */
contract WakeUp is Ownable, ReentrancyGuard {

    using SafeMath16 for uint16;

    /**
     * total ETH amount lost by users
     */
    uint256 public totalLostETH = 0;

    /**
     * deposit ETH amount for register
     * this ETH is progressively lost when user fails to waek up
     */
    uint256 public depositETHAmount = 5 ether;

    /**
     * days per register
     */
    uint256 public numberOfDays = 10;

    /**
     * number of users
     */
    uint16 public numberOfUsers = 0;

    /**
     * mapping from userId to address
     */
    mapping(uint16 => address) public userIdToAddress;
 
    /**
     * mapping from user address to wakeup data
     */
    mapping(address => WakeUps) public userAddressToWakeUps;

    /**
     * struct for wakeup data
     */
    struct WakeUps {
        uint16 userId;
        WakeUpElement[10] wakeUpElements; // length equals to numberOfDays
        bool exists;
    }
    struct WakeUpElement {
        uint32 wakeUpAt;
        bool success;
    }

    /**
     * constructor
     */
    constructor() public {
    }

    /**
     * @param wakeUpAtList is array of wakeup time in Unix Time
     */
    function register(uint32[10] calldata wakeUpAtList) external payable {
        require(msg.value >= depositETHAmount, "deposit ETH is not enough");
        require(userAddressToWakeUps[msg.sender].exists == true, "user is already registered");

        WakeUpElement[10] memory wakeUpElements;
        for (uint i=0; i<wakeUpAtList.length; i++) {
            require(wakeUpAtList[i] > now, "invalid wakeup time");
            require(wakeUpAtList[i] < now + 30 days, "invalid wakeup time");
            wakeUpElements[i] = WakeUpElement({wakeUpAt: wakeUpAtList[i], success: false});
        }

        numberOfUsers = numberOfUsers.add(1);

        WakeUps memory wakeUps = WakeUps({
            userId: numberOfUsers,
            wakeUpElements: wakeUpElements,
            exists: false
        });

        userAddressToWakeUps[msg.sender] = wakeUps;

        if (msg.value > depositETHAmount) {
            msg.sender.transfer(msg.value - depositETHAmount);
        }
    }

    /**
     * @param _user is a user's address
     * @return lost ETH amount per failure
     */
    function lostEHTPerFailure(address _user) public pure returns (uint256) {
        return (5 ether / 10);
    }

    /**
     * @return current time in Unix Time
     */
    function currentTime() public view returns (uint32) {
        // solium-disable-next-line security/no-block-members
        return uint32(now);
    }
}
