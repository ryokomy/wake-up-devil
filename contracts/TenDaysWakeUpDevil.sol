pragma solidity >=0.4.99 <0.6.0;
pragma experimental ABIEncoderV2;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "../submodules/solidity-util/lib/SafeMath16.sol";

/**
 * @title TenDaysWakeUpDevil
 * @author Ryo Komiyama <https://github.com/ryokomy>
 */
contract TenDaysWakeUpDevil is Ownable, ReentrancyGuard {

    using SafeMath16 for uint16;

    /**
     * @notice
     * struct for wakeup data
     */
    struct WakeUps {
        uint16 userId;
        uint8 successCount;
        uint8 withdrawCount;
        uint32[10] wakeUpAts;
        bool[10] successes;
        bool exists;
    }

    event RegisterEvent(
        address indexed _userAddress,
        uint32 _startAt
    );

    /**
     * @notice
     * total ETH amount lost by users
     */
    uint256 public totalLostETH = 0;

    /**
     * @notice
     * deposit ETH amount for register
     * this ETH is progressively lost when user fails to waek up
     */
    uint256 public depositETHAmount = 3 ether;

    uint16 public numberOfUsers = 0;

    /**
     * @notice
     * mapping from userId to address
     */
    mapping(uint16 => address) internal _userIdToAddress;
 
    /**
     * @notice
     * mapping from user address to wakeup data
     */
    mapping(address => WakeUps) internal _userAddressToWakeUps;

    /**
     * @notice
     * constructor
     */
    constructor() public {
    }

    /**
     * @notice
     * register function
     * deposit is needed for register
     *
     * @param startAt is the first wakeup time in Unix Time
     */
    function register(uint32 startAt) external nonReentrant() payable
    {
        // higher value than depositETHAmont is needed for register
        require(msg.value >= depositETHAmount, "deposit ETH is not enough");

        // one address can register only once (TODO: fix this limitation)
        require(_userAddressToWakeUps[msg.sender].exists == false, "user is already registered");

        // check startAt
        // solium-disable-next-line security/no-block-members
        require((startAt > now) && (startAt < now + 5 days), "invalid start time");

        // increment numberOfUsers
        numberOfUsers = numberOfUsers.add(1);

        // set _userIdToAddress mapping
        _userIdToAddress[numberOfUsers] = msg.sender;

        // create WakeUps
        uint32[10] memory wakeUpAts;
        bool[10] memory successes;
        WakeUps memory wakeUps = WakeUps({
            userId: numberOfUsers,
            successCount: 0,
            withdrawCount: 0,
            wakeUpAts: wakeUpAts,
            successes: successes,
            exists: true
        });
        for (uint i = 0; i < 10; i++) {
            wakeUps.wakeUpAts[i] = uint32(startAt + i * (1 days));
        }
        _userAddressToWakeUps[msg.sender] = wakeUps;

        // return extra amount of ETH
        if (msg.value > depositETHAmount) {
            msg.sender.transfer(msg.value - depositETHAmount);
        }
    }

    // function RobinHood(address _userAddress) external {
        
    // }

    /**
     */
    function userAddressToWakeUps(address _userAddress) external view returns (WakeUps memory) {
        return _userAddressToWakeUps[_userAddress];
    }

    /**
     * @notice
     * lostEHTPerFailure function
     *
     * @return lost ETH amount per failure
     */
    function lostEHTPerFailure() public view returns (uint256) {
        return (depositETHAmount / 10);
    }

    /**
     * @return current time in Unix Time
     */
    function currentTime() public view returns (uint32) {
        // solium-disable-next-line security/no-block-members
        return uint32(now);
    }
}
