pragma solidity >0.4.24 <0.6.0;

/**
 * Addresses Library
 * 
 * @author Ryo Komiyama <ryokomy@kyuzan.com>
 */

library Addresses {
    /**
     * toBytes cast address to bytes
     * @param a is address you want to cast to string 
     * @return b is casted address
     */
    function toBytes(address a)
        internal
        pure 
        returns (bytes memory b)
    {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let m := mload(0x40)
            mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, a))
            mstore(0x40, add(m, 52))
            b := m
        }
    }

    /**
     * make_payable makes address to be payable
     * @param a is address you want to make payable 
     * @return payable address
     */
    function make_payable(address a)
        internal
        pure 
        returns (address payable)
    {
        return address(uint160(a));
    }
}