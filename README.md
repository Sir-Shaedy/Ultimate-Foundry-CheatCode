# Ultimate Foundry CheatCode Boilerplate 🚀

The most comprehensive Foundry testing toolkit featuring:
- Standard test patterns
- Advanced invariant testing
- Cheatcode reference
- Handler-based testing
- Full VM interface documentation
- Ready-to-use code snippets

## 📦 Installation

```bash
git clone https://github.com/Sir-Shaedy/Ultimate-Foundry-CheatCode.git
cd Ultimate-Foundry-CheatCode
```

## 🔌 VS Code Snippet Setup

[Step One]  
Open the `ultimateCheat.json` file in VS Code.

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
  // Paste the entire ultimateCheat.json content here
}
```

[Step Six]  
Save the file (`CTRL+S`). Now you can use all cheatcodes via autocomplete!

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
contract InvariantTest {
    function invariant_balance_sum() public view {
        assertEq(
            token.balanceOf(alice) + token.balanceOf(bob),
            token.totalSupply()
        );
    }
}
```

### 3. Handler-Based Testing
```solidity
contract Handler {
    function deposit(uint256 amount) public {
        amount = bound(amount, 1, 100 ether);
        token.deposit(amount);
        ghost_deposits += amount;
    }
}
```

## 🎮 Cheatcode Categories

### Time Manipulation ⏰
```solidity
vm.warp(block.timestamp + 1 days);  // Fast forward
vm.roll(block.number + 100);        // Jump blocks
```

### Account Simulation 👤
```solidity
vm.prank(alice);                    // Next call's msg.sender
vm.startPrank(alice);               // Persistent prank
deal(alice, 100 ether);             // Fund account
```

### Forking 🌐
```solidity
uint256 forkId = vm.createFork("mainnet");
vm.selectFork(forkId);
```

## 🛠️ Advanced Patterns

### Mocking Calls
```solidity
vm.mockCall(
    address(token),
    abi.encodeWithSelector(token.balanceOf.selector, alice),
    abi.encode(100 ether)
);
```

### Gas Snapshots
```solidity
uint256 gasBefore = gasleft();
token.swap();
console.log("Gas used:", gasBefore - gasleft());
```

### Fuzz Testing
```solidity
function testFuzzTransfer(uint256 amount) public {
    amount = bound(amount, 1, 1000 ether);
    deal(alice, amount);
    vm.prank(alice);
    token.transfer(bob, amount);
}
```

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

## 🏗️ Project Structure
```
├── test/
│   ├── Standard/
│   │   └── Basic.t.sol          # Conventional tests
│   ├── Invariant/
│   │   └── Protocol.t.sol       # Property-based tests
│   └── Mocks/
│       └── ERC20Mock.t.sol      # Mock contracts
├── script/
│   └── Deploy.s.sol             # Deployment scripts
└── cheatcodes/                  
    └── ultimateCheat.json       # VS Code snippets
```

## 🚀 Quick Start
1. Install Foundry:
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

2. Run tests:
```bash
forge test -vvv                  # Basic tests
forge test --match-contract InvariantTest -vvvv  # Invariant tests
```

## 📜 Best Practices
- 🔄 Always clean up with `vm.stopPrank()`/`vm.clearMockedCalls()`
- 🏷️ Use `vm.label(address, "Name")` for better traces
- 📊 Generate gas reports with `forge test --gas-report`
- 🧹 Separate test types into different files/directories

## 🆘 Troubleshooting
| Error | Solution |
|-------|----------|
| "No such file" | Run `forge install` |
| Cheatcode not working | Check `foundry.toml` FFI settings |
| Snapshots failing | Ensure `vm.revertTo(snapshotId)` is called |

## 📈 Benchmark Results
```text
Standard Tests:   256 runs  | 0.8s avg
Invariant Tests:  10k runs  | 4.2s avg
Fuzz Tests:       500 runs  | 1.5s avg
```

## 🌟 Pro Tips
```solidity
// Debug complex tests with traces
vm.recordLogs();
myContract.action();
Vm.Log[] memory logs = vm.getRecordedLogs();

// Test specific revert reasons
vm.expectRevert(abi.encodeWithSelector(CustomError.selector));
```

## 📄 License
MIT - Use freely in your projects with attribution
