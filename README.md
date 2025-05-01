# Foundry Cheatcode and Smart Contract Test Ideas Boilerplate 🚀

The most comprehensive Foundry testing toolkit featuring:
- Standard test patterns
- Advanced invariant & fuzzing tests
- Handler-based differential testing
- A massive collection of test ideas grouped into categories like Staking, Bridge, and Yield
- Full VM cheatcode documentation
- Ready-to-use code snippets

---

## 📂 Directory Structure

Below is the directory structure of the project:

```
contract/
├── Foundry Test Cheatcode/
│   ├── foundryTestCheat.sol       // Solidity file containing cheatcode examples
│   └── foundryTestCheat.json      // JSON file for VS Code snippet integration
│
└── Vulnerability Idea/
    ├── securityIdea.sol           // Solidity file containing test idea examples
    └── securityIdea.json          // JSON file for VS Code snippet integration
```

### Explanation of Files:
- **foundryTestCheat.sol**: Contains practical examples of Foundry cheatcodes for smart contract testing.
- **foundryTestCheat.json**: JSON file used to integrate Foundry cheatcodes into VS Code for autocomplete support.
- **securityIdea.sol**: Contains example function signatures for testing vulnerabilities based on real-world audits.
- **securityIdea.json**: JSON file used to integrate vulnerability test ideas into VS Code for autocomplete support.

---

## 🔧 Features

✅ **Smart Contract Test Ideas Collection**  
A curated list of 600+ test ideas that you can use as inspiration during smart contract audits or development. These ideas are grouped into categories such as Staking, Bridge, and Yield. Each idea is represented as a function signature, ready for implementation:

```solidity
function test_third_party_redeem_burns_shares_from_owner_even_when_allowance_used() public;
function test_third_party_redeem_only_spends_approved_allowance_and_not_more() public;
function test_requestWithdrawal_allows_anyone_to_initiate_with_valid_parameters() public; 
function test_rescueTokens_function_cannot_be_called_by_authorized_addresses() public; 
function test_position_cannot_be_unwound_after_transfer_to_new_owner() public; 
```

These test ideas were extracted and refined from over **30 public and private security reviews** conducted on protocols such as:
- **YieldFi**, **Euler**, **Surge**, **Optimism**, **FyD May**, **Beanstalk**
- **Notional Leverage Vault**, **Sigma Prime**, **Rocketpool**, **Archimedes**
- **Tadle**, **PoolTogether**, **Lyra Finance**, **Biconomy**, **Axelar Network**
- **WooFiSwap**, **BaderDAO**, **Astaria**, **Ethene Labs**, **Velodrome Finance**

Big thanks to platforms like **Solodit** for aggregating findings from these audits, making it easier to compile this extensive list of test ideas. Special thanks to:
- **Cantina**, **Spearbit**, **Code4rena**, **Sherlock**, **Halborn**, **CyfrinAudit**
- **MixBytes**, **Lonelyslot**, **milotruck**, **oxdeadbeef**, and others who made their findings public.

You can generate this list of test ideas by simply typing:

```bash
idea
```

To scaffold a new test file based on the `securityIdeas.json` template.

---

✅ **Foundry Cheatcode Snippets**  
Access a wide range of cheatcodes to streamline your smart contract testing. Activate cheatcodes by typing:

```bash
ft
```

This will leverage the `cheatCode.json` template for quick insertion of Foundry cheatcodes.

---

## 📦 Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Sir-Shaedy/Ultimate-Foundry-CheatCode.git
   cd Ultimate-Foundry-CheatCode
   ```

2. Ensure you have both `foundryTestCheat.json` and `securityIdeas.json` files available in the repository. These files are essential for activating cheatcodes (`ft`) and generating test ideas (`idea`).

---

## 💡 VS Code Snippet Setup

[Step One]  
Open the `foundryTestCheat.json` file in VS Code.

[Step Two]  
Copy the entire content from the file.

[Step Three]  
Press `CTRL + SHIFT + P` on your keyboard.

[Step Four]  
Search for "snippet" and choose "Configure User Snippets."

[Step Five]  
Select `solidity.json` and paste the copied content into the file:

```json
{
  // Paste the entire foundryTestCheat.json content here
}
```

[Step Six]  
Save the file (`CTRL+S`). Now you can use cheatcodes via autocomplete.

---

[Step Seven]  
Repeat the process for `securityIdeas.json`:
- Open the `securityIdeas.json` file in VS Code.
- Copy its content.
- Paste it into the same `solidity.json` file below the previous content.

Your `solidity.json` should now look like this:

```json
{
  // Content from foundryTestCheat.json
  // Content from securityIdeas.json
}
```

[Step Eight]  
Save the file again (`CTRL+S`). Now you can use both cheatcodes and test ideas via autocomplete!

---

## 🧪 Test Types Overview

### 1. Standard Tests
```solidity
function testTransfer() public {
    // Setup
    deal(alice, 1 ether);
    vm.prank(alice);

    // Execute
    token.transfer(bob, 1 ether);

    // Verify
    assertEq(token.balanceOf(bob), 1 ether);
}
```

### 2. Invariant Tests
```solidity
contract InvariantTest is Test {
    function invariant_balance_sum() public view {
        assertEq(
            token.balanceOf(alice) + token.balanceOf(bob),
            token.totalSupply()
        );
    }
}
```

### 3. Handler-Based Differential Testing
```solidity
contract TokenHandler is Test {
    uint256 internal ghost_totalSupply;

    function deposit(uint256 amount) public {
        amount = bound(amount, 1, 100 ether);
        token.deposit{value: amount}(user);
        ghost_totalSupply += amount;
    }
}
```

---

## 🎮 Cheatcode Categories

### Time Manipulation ⏰
```solidity
vm.warp(block.timestamp + 1 days);  // Fast forward time
vm.roll(block.number + 100);         // Jump block number
```

### Account Simulation 👤
```solidity
vm.prank(alice);                     // Next call as alice
vm.startPrank(alice);                // All subsequent calls as alice
deal(alice, 100 ether);              // Fund user account
```

### Forking 🌐
```solidity
uint256 forkId = vm.createFork("mainnet");
vm.selectFork(forkId);
```

---

## 🛠️ Advanced Patterns

### Mocking External Calls
```solidity
vm.mockCall(
    address(token),
    abi.encodeWithSelector(token.balanceOf.selector, alice),
    abi.encode(100 ether)
);
```

### Gas Snapshots & Measurement
```solidity
uint256 gasBefore = gasleft();
token.swap();
console.log("Gas used:", gasBefore - gasleft());
```

### Fuzz Testing with Bounds
```solidity
function testFuzz_Transfer(uint256 amount) public {
    amount = bound(amount, 1, 1000 ether);
    deal(alice, amount);
    
    vm.prank(alice);
    token.transfer(bob, amount);
}
```

### Log Tracing for Debugging
```solidity
vm.recordLogs();
myContract.action();
Vm.Log[] memory logs = vm.getRecordedLogs();
```

### Revert Reason Matching
```solidity
vm.expectRevert(abi.encodeWithSelector(CustomError.selector));
```

---

## 📚 Full VM Interface Reference

### View Operations (VmSafe)

```solidity
interface VmSafe {
    function readFile(string calldata) external view returns (string memory);
    function envUint(string calldata) external view returns (uint256);
}
```

### State-Changing Operations (Vm)

```solidity
interface Vm {
    function etch(address, bytes calldata) external;
    function broadcast() external;
    function makePersistent(address) external;
}
```

---

## 📜 Best Practices

- 🔄 Always clean up with `vm.stopPrank()` or `vm.clearMockedCalls()`
- 🏷️ Use `vm.label(address, "Name")` for better traceability
- 📊 Generate detailed gas reports using `forge test --gas-report`
- 🧹 Keep test files modular – separate unit, invariant, handler tests

---

## ❤️ Acknowledgments

This
