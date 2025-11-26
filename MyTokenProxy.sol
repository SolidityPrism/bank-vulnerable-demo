// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/*
 * Upgradeable ERC20 Proxy, but with a critical admin fallback vulnerability (misses sender validation!)
 */
contract MyTokenProxy {
    address public implementation; // storage slot collision possibility
    address public admin;          // should be protected

    constructor(address _impl) {
        implementation = _impl;
        admin = msg.sender;
    }

    // VULNERABILITY: no sender check (intermediate-level), anyone can change implementation
    function upgradeTo(address _impl) public {
        implementation = _impl; // Any caller can upgrade
    }

    fallback() external payable {
        address impl = implementation;
        require(impl != address(0), "no implementation");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return (0, returndatasize()) }
        }
    }
}
