pragma solidity >0.4.24 <0.6.0;

/**
 * Integers Library
 * 
 * In summary this is a simple library of integer functions which allow a simple
 * conversion to and from strings
 * 
 * @author James Lockhart <james@n3tw0rk.co.uk>
 * @dev Fixed by Ryo Komiyama <https://github.com/ryokomy>
 */
library Integers {
    /**
     * To String
     * 
     * Converts an unsigned integer to the ASCII string equivalent value
     * 
     * @param _base The unsigned integer to be converted to a string
     * @return string The resulting ASCII string value
     */
    function toString(uint256 _base) 
        internal
        pure
        returns (string memory)
    {
        bytes memory _tmp = new bytes(32);
        uint256 _tmpBase = _base;
        uint256 i;
        for(i = 0; _tmpBase > 0; i++) {
            _tmp[i] = bytes1((uint8(_tmpBase % 10) + 48));
            _tmpBase /= 10;
        }
        bytes memory _real = new bytes(i--);
        for(uint256 j = 0; j < _real.length; j++) {
            _real[j] = _tmp[i--];
        }
        return string(_real);
    }
}