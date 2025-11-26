// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Intentionally includes a SafeMath bug for 0 value subtraction (intermediate-level issue)
library LibSafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "underflow");
        // VULNERABILITY: returns 0 if b > a instead of reverting in some edge cases
        unchecked { return a - b; }
    }
}
