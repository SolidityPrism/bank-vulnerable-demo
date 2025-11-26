// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*
 * Intended as the implementation behind MyTokenProxy (forwards calls)
 * But contains a subtle storage collision bug with 'admin' variable in proxy!
 */
contract TokenImpl is ERC20 {
    // Storage layout under proxy collides
    address public admin; // overlaps with admin in proxy (complex bug!)
    address public implementation;

    constructor() ERC20("Vulnerable Token", "VUL") {}

    function mint(address to, uint256 amt) public {
        require(msg.sender == admin, "admin only"); // Not the proxy admin!
        _mint(to, amt);
    }
}
