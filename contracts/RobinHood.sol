pragma solidity >=0.4.99 <0.6.0;

import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "./Devil.sol";

/**
 * @title RobinHood
 * @author Ryo Komiyama <https://github.com/ryokomy>
 */
contract RobinHood is ReentrancyGuard {

    event StealEvent(
        uint32 _stealAt
    );
    event ProvideEvent(
        uint256 _amount,
        uint32 _provideAt
    );

    /**
     * @notice
     * This is the wallet address of UNICEF New Zealand
     * <https://www.unicef.org.nz/donate-in-crypto>
     */
    address payable public donationAddress = 0xB9407f0033DcA85ac48126a53E1997fFdE04B746;

    constructor() public {}

    function steal(address _devilAddress) external {
        Devil devil = Devil(_devilAddress);
        devil.stolen();
        emit StealEvent(uint32(now));
    }

    function provide() external nonReentrant() {
        uint256 amount = address(this).balance;
        donationAddress.transfer(amount);
        // solium-disable-next-line security/no-block-members
        emit ProvideEvent(amount, uint32(now));
    }
}
