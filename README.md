edit
# Solidity Multi-File Security Showcase

A pedagogical Solidity project demonstrating vulnerabilities across multiple interacting contracts. This repo showcases **three severity levels of security issues**: simple (easy to spot), intermediate (requires good Solidity knowledge), and complex (tricky storage/proxy interactions).

## Project Overview

This project contains four Solidity contracts that interact with each other and use OpenZeppelin dependencies:

- **BankVulnerable.sol** — A simple bank contract with a classic reentrancy vulnerability
- **LibSafeMath.sol** — A math library with subtle underflow edge cases
- **MyTokenProxy.sol** — An upgradeable proxy pattern with critical flaws
- **TokenImpl.sol** — An ERC20 implementation meant to run behind the proxy

## Contracts

### BankVulnerable.sol
A basic bank deposit/withdraw contract. Users can deposit ETH and withdraw it. However, the withdrawal logic updates the balance **after** transferring funds to the caller, opening a reentrancy attack vector.

**Key Issue:** State update occurs after external call.

### LibSafeMath.sol
A lightweight math library used by BankVulnerable for balance arithmetic. Includes add() and sub() functions.

**Key Issue:** The sub() function uses `unchecked` block without proper validation in certain edge cases, potentially allowing underflow scenarios.

### MyTokenProxy.sol
An upgradeable proxy pattern implementation designed to delegate calls to a token implementation contract. Features a fallback function for delegatecall routing.

**Key Issues:**
1. No access control on `upgradeTo()` — any caller can change the implementation address
2. Potential storage layout collision with the implementation contract (see TokenImpl.sol)

### TokenImpl.sol
An ERC20 token implementation meant to run behind MyTokenProxy. Includes a mint() function restricted to `admin`.

**Key Issue:** Storage layout mismatch with proxy. The `admin` and `implementation` slots are not aligned correctly, causing storage collision and potential privilege escalation or logic bypass.

---

## Vulnerabilities to Find

### Level 1: Simple (Beginner)
**Reentrancy in BankVulnerable.withdraw()**
- **What to look for:** Balance update happens AFTER the external call (msg.sender.call)
- **Why it matters:** A malicious contract can call withdraw() again before balance is decremented
- **Impact:** Drain all contract funds

**How to detect it:**
- Look at the order of operations in withdraw()
- Any external call (.call, .transfer, etc.) before state changes is a red flag

---

### Level 2: Intermediate
**Access Control in MyTokenProxy.upgradeTo()**
- **What to look for:** No `onlyAdmin` modifier or sender check
- **Why it matters:** Anyone can call upgradeTo() and point the proxy to a malicious implementation
- **Impact:** Complete compromise of the contract logic

**How to detect it:**
- Notice the function has no access restrictions
- Compare with OpenZeppelin's Ownable or AccessControl patterns

---

### Level 3: Complex / Hard to Find
**Storage Collision in Proxy ↔ Implementation Pattern**
- **What to look for:** Storage slot misalignment between MyTokenProxy and TokenImpl
  - Proxy declares: `address public implementation;` → slot 0
  - Proxy declares: `address public admin;` → slot 1
  - TokenImpl declares: `address public admin;` → slot 0 (under proxy context, becomes slot 1 via delegatecall)
  - **Collision:** TokenImpl's `admin` is written to the same slot as Proxy's `implementation`!
- **Why it matters:** When TokenImpl tries to set `admin`, it actually overwrites the proxy's `implementation` pointer
- **Impact:** Proxy can be bricked, or logic can be hijacked through storage manipulation

**How to detect it:**
- Understand ERC-1967 proxy storage layout standards
- Trace storage slots carefully when using delegatecall
- Use tools like `slither` or manual slot analysis
- This is a **known pattern vulnerability** in many upgradeable contracts

---

## Recommended Tools for Analysis

- **Slither** (static analyzer): `slither . --json output.json`
- **Mythril** (symbolic execution): `myth analyze contracts/BankVulnerable.sol`
- **Hardhat console**: Deploy and trace calls to understand storage and execution flow

---

## Usage

Clone this repo and analyze the contracts:

