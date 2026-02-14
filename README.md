# Smart Contracts Testing with Echidna

This academic project analyzes the **security and logical correctness** of two Solidity smart contracts (**Taxpayer** and **Lottery**) using **Echidna**, a property-based fuzzer for Ethereum smart contracts.

The goal of the project is to identify logical flaws and missing constraints through **invariant-based fuzz testing**, and to iteratively fix the contracts until all specified properties are satisfied.

## Project Overview

Smart contracts are immutable once deployed, which makes thorough testing crucial.  
This project adopts **property-based fuzzing** to uncover subtle bugs that may not emerge during traditional testing.

The workflow followed throughout the project is:

1. Define **invariants** representing security and correctness properties
2. Run **Echidna** to generate adversarial call sequences
3. Analyze counterexamples when invariants fail
4. Fix contract logic or add missing `require` conditions
5. Re-run Echidna to validate the fixes

## Contracts Description

### Taxpayer Contract

The `Taxpayer` contract models a citizen and manages:

- Personal information (age, marital status, spouse)
- Tax allowance handling
- Marriage and divorce logic
- Allowance transfers between spouses

Key properties enforced through invariants include:

- Marriage must be **mutual**
- A user cannot marry themselves
- Minimum age requirement for marriage
- Tax allowance conservation between spouses
- Correct handling of age-based allowances (e.g. over 65)

### Lottery Contract

The `Lottery` contract implements a **commit–reveal lottery mechanism** for eligible taxpayers.

Main features:

- Only taxpayers under a certain age can participate
- Each participant can join **only once**
- A fair winner selection process
- Cleanup of internal data structures after the lottery ends
- Prize awarded as an increased tax allowance

## Testing with Echidna

### Invariants

Echidna tests are written as Solidity functions that:

- Start with the prefix `echidna_`
- Return a boolean value
- Express a property that must **always hold**

Example:

```solidity
function echidna_not_self_married() public view returns (bool) {
    if (isMarried) {
        return spouse != address(this);
    }
    return true;
}
```
If an invariant returns false, Echidna provides a minimal call sequence that reproduces the bug.

## Test Contracts

To enable more complex scenarios, the project defines test contracts that extend the original ones:
- TestTaxpayer: deploys multiple Taxpayer instances to test inter-contract interactions
- TestLottery: simulates lottery participation and tracks internal state

These contracts are used exclusively for fuzzing and verification.

## Running Echidna (Local Binary, without Docker)

In this project, **Echidna is used as a locally installed executable** obtained from the official Crytic repository, **without using Docker or Cabal**.  
Once installed, Echidna can be invoked directly from the command line using the `echidna` command.

Official repository:  
https://github.com/crytic/echidna

### Requirements

To run Echidna locally, the following tools are required:

- **Echidna (local binary)**
- **Solidity compiler (solc)**

### Installing Echidna

Clone the official repository:

```bash
git clone https://github.com/crytic/echidna.git
```
**Follow the instructions** in the repository to install the prebuilt Echidna binary or add it to your system PATH.

### Running the Tests

Once Echidna is correctly installed, move to the directory containing the smart contracts and test files.
To analyze a contract, simply run:

```bash
echidna myContract.sol
```
Echidna will automatically:
- Compile the contracts
- Generate random sequences of function calls
- Check all invariants defined in functions whose name starts with echidna_

### Configuration

Echidna allows test parameters to be specified **either via a configuration file or directly from the command line**.
For example, to increase the number of generated test cases:

```bash
echidna TestTaxpayer.sol --test-limit 200000
```
