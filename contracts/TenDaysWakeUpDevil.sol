pragma solidity >=0.4.99 <0.6.0;
pragma experimental ABIEncoderV2;

import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./Devil.sol";

/**
 * @title TenDaysWakeUpDevil
 * @author Ryo Komiyama <https://github.com/ryokomy>
 */
contract TenDaysWakeUpDevil is ReentrancyGuard, Devil {

    using SafeMath for uint256;

    /**
     * @notice
     * struct for wakeup data
     */
    struct WakeUpUnit {
        uint256 id;
        uint32[10] wakeUpAts;
        bool[10] successes;
        bool exists;
    }

    event RegisterEvent(
        address indexed _userAddress,
        uint256 indexed _id,
        uint32 _startAt
    );
    event WakeUpEvent(
        uint256 indexed _id,
        uint8 indexed _day,
        uint32 _wakeUpAt
    );
    event FinishEvent(
        uint256 indexed _id,
        uint8 _oversleepCount,
        uint256 _lostETH,
        uint32 _finishAt
    );
    event StolenEvent(
        uint256 _stolenETH,
        uint32 _stolenAt
    );

    uint256 public totalOversleepCount = 0;

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

    uint256 public numberOfWakeUpUnits = 0;

    /**
     * @notice
     * mapping from user address to wakeup data
     */
    mapping(address => WakeUpUnit) internal _userAddressToWakeUpUnit;

    /**
     * @notice
     * This is the address of RobinHood who can steal Devil's ETH
     */
    address payable public robinHoodAddress;


    /**
     * @notice
     * constructor
     *
     * @param _robinHoodAddress is contract address of RobinHood
     */
    constructor(address payable _robinHoodAddress) public {
        robinHoodAddress = _robinHoodAddress;
    }

    /**
     * @notice
     * register function
     * deposit is needed for register
     *
     * @param _startAt is the first wakeup time in Unix Time
     */
    function register(uint32 _startAt) external nonReentrant() payable
    {
        // higher value than depositETHAmont is needed for register
        require(msg.value >= depositETHAmount, "deposit ETH is not enough");

        // one address can register only once (TODO: fix this limitation)
        require(_userAddressToWakeUpUnit[msg.sender].exists == false, "user is already registered");

        // check startAt
        // solium-disable-next-line security/no-block-members
        require((_startAt > now) && (_startAt < now + 5 days), "invalid start time");

        // increment numberOfWakeUpUnits
        numberOfWakeUpUnits = numberOfWakeUpUnits.add(1);

        // create WakeUpUnit
        uint32[10] memory wakeUpAts;
        bool[10] memory successes;
        WakeUpUnit memory wakeUpUnit = WakeUpUnit({
            id: numberOfWakeUpUnits,
            wakeUpAts: wakeUpAts,
            successes: successes,
            exists: true
        });
        for (uint i = 0; i < 10; i++) {
            wakeUpUnit.wakeUpAts[i] = uint32(_startAt + i * (1 days));
        }
        _userAddressToWakeUpUnit[msg.sender] = wakeUpUnit;

        // return extra amount of ETH
        if (msg.value > depositETHAmount) {
            msg.sender.transfer(msg.value - depositETHAmount);
        }

        emit RegisterEvent(msg.sender, numberOfWakeUpUnits, _startAt);
    }

    /**
     * @notice
     * wakeUp function
     *
     * @param _day is counted from 1 to 10
     */
    function wakeUp(uint8 _day) external
    {
        require(1 <= _day && _day <= 10, "given day is not in range");

        WakeUpUnit memory wakeUpUnit = _userAddressToWakeUpUnit[msg.sender];
        require(wakeUpUnit.exists == true, "user doesn't exist");

        uint256 dayIndex = _day - 1;
        require(wakeUpUnit.successes[dayIndex] == false, "already succeeded to wake up");

        // solium-disable-next-line security/no-block-members
        bool timeCondition = (wakeUpUnit.wakeUpAts[dayIndex] - 5 minutes < now) && (now < wakeUpUnit.wakeUpAts[dayIndex] + 5 minutes);
        require(timeCondition, "wakeup time is invalid");

        // success to wake up
        _userAddressToWakeUpUnit[msg.sender].successes[dayIndex] = true;

        // solium-disable-next-line security/no-block-members
        emit WakeUpEvent(wakeUpUnit.id, _day, uint32(now));
    }

    /**
     * @notice
     * This function make WakeUpUnit finish
     * Overslept days are counted and Devil steal deposited ETH based on it.
     */
    function finish() external nonReentrant()
    {
        WakeUpUnit memory wakeUpUnit = _userAddressToWakeUpUnit[msg.sender];
        require(wakeUpUnit.exists == true, "user doesn't exist");
        // solium-disable-next-line security/no-block-members
        require(wakeUpUnit.wakeUpAts[9] < now, "contract haven't expired yet");

        uint256 oversleepCount = 0;
        for(uint256 i = 0; i < 10; i++) {
            if(!wakeUpUnit.successes[i]) {
                oversleepCount++;
            }
        }
        totalOversleepCount = totalOversleepCount.add(oversleepCount);

        // delete mapping
        delete _userAddressToWakeUpUnit[msg.sender];

        // devil takes ETH
        uint256 lostETH = oversleepCount.mul(lostETHPerOversleep());
        totalLostETH = totalLostETH.add(lostETH);

        // return deposit
        if(lostETH < depositETHAmount) {
            msg.sender.transfer(depositETHAmount.sub(lostETH));
        }

        // solium-disable-next-line security/no-block-members
        emit FinishEvent(wakeUpUnit.id, uint8(oversleepCount), lostETH, uint32(now));
    }

    /**
     * @notice
     * This function is called by RobinHood contract
     * RobinHood steals Devil's ETH
     */
    function stolen() external nonReentrant() {
        require(msg.sender == robinHoodAddress, "No one can steal devil's ETH apart from Robin Hood");
        uint256 _stolenETH = totalLostETH;
        totalLostETH = 0;
        robinHoodAddress.transfer(_stolenETH);
        emit StolenEvent(_stolenETH, uint32(now));
    }

    /**
     * @notice
     * getter of WakeUpUnit contract
     */
    function userAddressToWakeUpUnit(address _userAddress) external view returns (WakeUpUnit memory) {
        return _userAddressToWakeUpUnit[_userAddress];
    }

    /**
     * @notice
     * lostETHPerOversleep function
     *
     * @return lost ETH amount per oversleep
     */
    function lostETHPerOversleep() public view returns (uint256) {
        return depositETHAmount.div(10);
    }

    /**
     * @return current time in Unix Time
     */
    function currentTime() public view returns (uint32) {
        // solium-disable-next-line security/no-block-members
        return uint32(now);
    }
}
