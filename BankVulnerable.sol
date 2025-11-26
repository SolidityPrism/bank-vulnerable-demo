// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./LibSafeMath.sol";

contract BankVulnerable {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] = LibSafeMath.add(balances[msg.sender], msg.value);
    }

    // VULNERABILITY: Reentrancy - balance updated after transfer
    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "balance too low");
        (bool ok,) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");
        balances[msg.sender] = LibSafeMath.sub(balances[msg.sender], amount); // effect after interaction (bad)
    }
}
