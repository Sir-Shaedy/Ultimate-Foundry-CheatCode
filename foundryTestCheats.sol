// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// ==============================================
// 🧪 FOUNDRY SOLIDITY TEST CHEAT SHEET (All-in-One File)
// ==============================================
// A comprehensive guide for testing smart contracts using Foundry.
// Includes standard tests, invariant testing, cheatcodes, handler patterns,
// and full Vm interface reference.

// Import core libraries
import {Test, console} from "forge-std/Test.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";
import {StdUtils} from "forge-std/StdUtils.sol";

// Target contract placeholder (replace with your actual contract path)
contract YourContract {}

contract FoundryCheatSheet is Test {
    // ==============
    // 1️⃣ SETUP PATTERNS & TEST FIXTURES
    // ==============

    address public owner = makeAddr("owner");
    address public user = makeAddr("user");
    ERC20Mock public token;
    uint256 public constant TEST_AMOUNT = 100e18;

    function setUp() public {
        token = new ERC20Mock();
        token.mint(owner, TEST_AMOUNT);
        deal(user, 1 ether); // Fund native balance
    }

    // ==============
    // 2️⃣ CORE ASSERTIONS AND REVERT TESTING
    // ==============

    function testAssertions() public {
        assertEq(1 + 1, 2, "1+1 should be 2");
        assertGt(3, 2, "3 > 2");
        assertLt(1, 2, "1 < 2");
        assertTrue(true, "True assertion");
        assertFalse(false, "False assertion");
    }

    function testReverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                bytes4(keccak256("CustomError()"))
            )
        );
        revert("CustomError");

        vm.expectRevert(bytes("Error message"));
        revert("Error message");
    }

    // ==============
    // 3️⃣ VM CHEATCODES - SUPERPOWERS FOR TESTING
    // ==============

    function testCheatcodes() public {
        address hacker = makeAddr("hacker");
        deal(address(token), hacker, TEST_AMOUNT);
        deal(hacker, 10 ether);

        vm.startPrank(hacker);
        assertEq(token.balanceOf(hacker), TEST_AMOUNT);
        vm.stopPrank();

        vm.warp(block.timestamp + 1 days);
        vm.roll(block.number + 100);
        vm.fee(25 gwei);
        vm.chainId(137);
    }

    // ==============
    // 4️⃣ TOKEN TESTING WORKFLOWS
    // ==============

    function testTokenFlows() public {
        vm.startPrank(owner);
        token.approve(address(this), TEST_AMOUNT);
        token.transferFrom(owner, user, TEST_AMOUNT);
        assertEq(token.balanceOf(user), TEST_AMOUNT);
        vm.stopPrank();
    }

    // ==============
    // 5️⃣ ADVANCED PATTERNS: FUZZING & STORAGE
    // ==============

    function testFuzzing(uint256 amount) public {
        vm.assume(amount > 0.1 ether && amount < 100 ether);
        vm.startPrank(user);
        (bool success,) = address(token).call{value: amount}("");
        assertTrue(success);
    }

    function testStorageManipulation() public {
        bytes32 slot = bytes32(uint256(0));
        vm.store(address(token), slot, bytes32(uint256(100)));
        assertEq(uint256(vm.load(address(token), slot)), 100);
    }

    // ==============
    // 6️⃣ FORK TESTING (MAINNET SIMULATION)
    // ==============

    function testMainnetFork() public {
        vm.createSelectFork("mainnet", 18_000_000);
        address dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        uint256 bal = IERC20(dai).balanceOf(owner);
        assertGt(bal, 0);
    }

    // ==============
    // 7️⃣ DEBUGGING TOOLS
    // ==============

    function testDebugging() public {
        console.log("Token balance:", token.balanceOf(user));
        vm.recordLogs();
        token.transfer(user, 1e18);
        Vm.Log[] memory logs = vm.getRecordedLogs();
    }
}

    // ==============
    // 🛡️ INVARIANT TESTING
    // ==============

contract InvariantTest is Test {
    YourContract public target;
    ERC20Mock public token;

    function setUp() public {
        token = new ERC20Mock();
        target = new YourContract();
        targetContract(address(target));
        deal(address(this), 100 ether);
    }

    receive() external payable {}

    function invariant_balanceConsistency() public view {
        assertGe(
            token.balanceOf(address(target)) + target.releasedAmount(),
            target.totalDeposits(),
            "Balance sum mismatch"
        );
    }

    function invariant_accessControl() public view {
        assertEq(
            target.owner(),
            address(this),
            "Ownership violated"
        );
    }
}

    // ==============
    // 👥 MULTI-ACTOR INVARIANT TESTING
    // ==============

contract MultiActorInvariantTest is Test {
    address[] public actors;
    address internal currentActor;
    ERC20Mock public asset;
    YourContract public token;

    mapping(address => uint256) public sumDeposits;
    uint256 public sumBalanceOf;

    function setUp() public {
        asset = new ERC20Mock();
        token = new YourContract(address(asset));
        for (uint256 i = 0; i < 10; i++) {
            actors.push(address(uint160(uint256(keccak256(abi.encodePacked(i))))));
            deal(address(asset), actors[i], 1000 ether);
        }
        targetContract(address(token));
    }

    modifier useActor(uint256 actorIndexSeed) {
        currentActor = actors[bound(actorIndexSeed, 0, actors.length - 1)];
        vm.startPrank(currentActor);
        _;
        vm.stopPrank();
    }

    function invariant_totalDepositsMatch() public view {
        uint256 computedTotal;
        for (uint256 i = 0; i < actors.length; i++) {
            computedTotal += sumDeposits[actors[i]];
        }
        assertEq(computedTotal, token.totalDeposits(), "Deposit sum mismatch");
    }

    function deposit(uint256 assets, uint256 actorIndexSeed) public useActor(actorIndexSeed) {
        assets = bound(assets, 1 ether, 100 ether);
        asset.approve(address(token), assets);
        token.deposit(assets, currentActor);
        sumDeposits[currentActor] += assets;
        sumBalanceOf += token.balanceOf(currentActor);
    }

    function withdraw(uint256 shares, uint256 actorIndexSeed) public useActor(actorIndexSeed) {
        shares = bound(shares, 1, token.balanceOf(currentActor));
        token.withdraw(shares);
        sumBalanceOf -= token.balanceOf(currentActor);
    }
}

    // ==============
    // 🧱 HANDLER-BASED INVARIANT TESTING
    // ==============

contract BaseHandler is StdUtils {
    YourContract public token;
    ERC20Mock public asset;

    uint256 public sumBalanceOf;
    mapping(address => uint256) public sumDeposits;

    constructor(YourContract _token, ERC20Mock _asset) {
        token = _token;
        asset = _asset;
    }

    function deposit(uint256 assets) public virtual {
        assets = bound(assets, 1, type(uint128).max);
        asset.mint(address(this), assets);
        asset.approve(address(token), assets);
        token.deposit(assets, address(this));
        sumBalanceOf += token.balanceOf(address(this));
        sumDeposits[msg.sender] += assets;
    }
}

contract BoundedHandler is BaseHandler {
    constructor(YourContract _token, ERC20Mock _asset) BaseHandler(_token, _asset) {}

    function deposit(uint256 assets) public override {
        assets = bound(assets, 0.1 ether, 1000 ether);
        super.deposit(assets);
    }
}

contract InvariantTestWithHandlers is Test {
    YourContract public token;
    ERC20Mock public asset;
    BoundedHandler public handler;
    address[] public actors;

    function setUp() public {
        asset = new ERC20Mock();
        token = new YourContract(address(asset));
        handler = new BoundedHandler(token, asset);
        for (uint256 i = 0; i < 5; i++) {
            actors.push(address(uint160(uint256(keccak256(abi.encodePacked(i))))));
            deal(address(asset), actors[i], 1000 ether);
        }
        targetContract(address(handler));
    }

    function invariant_totalSupplyMatchesGhost() public view {
        assertEq(token.totalSupply(), handler.sumBalanceOf(), "Total supply ≠ ghost sum");
    }

    function invariant_depositAccounting() public view {
        uint256 totalDeposited;
        for (uint256 i = 0; i < actors.length; i++) {
            totalDeposited += handler.sumDeposits(actors[i]);
        }
        assertEq(token.totalAssets(), totalDeposited, "Asset accounting broken");
    }
}

    // ==============
    // 🔍 FULL VM INTERFACE REFERENCE
    // ==============

    interface VmSafe {
        function envAddress(string calldata name) external view returns (address);
        function envBool(string calldata name) external view returns (bool);
        function envUint(string calldata name) external view returns (uint256);
        function getBlockNumber() external view returns (uint256);
        function getBlockTimestamp() external view returns (uint256);
        function load(address target, bytes32 slot) external view returns (bytes32);
        function readFile(string calldata path) external view returns (string memory);
        function fsMetadata(string calldata path) external view returns (FsMetadata memory);
        function assume(bool condition) external pure;
        function expectRevert() external;
        function expectRevert(bytes4 revertData) external;
    }

    interface Vm is VmSafe {
        function deal(address account, uint256 newBalance) external;
        function etch(address target, bytes calldata newRuntimeBytecode) external;
        function warp(uint256 newTimestamp) external;
        function roll(uint256 newHeight) external;
        function prank(address msgSender) external;
        function startPrank(address msgSender) external;
        function stopPrank() external;
        function createFork(string calldata urlOrAlias) external returns (uint256 forkId);
        function selectFork(uint256 forkId) external;
        function expectCall(address callee, bytes calldata data) external;
        function expectEmit() external;
        function snapshot() external returns (uint256 snapshotId);
        function revertTo(uint256 snapshotId) external returns (bool success);
    }

    struct FsMetadata {
        bool isDir;
        bool isSymlink;
        uint256 length;
        uint256 modified;
        uint256 accessed;
        uint256 created;
    }

    // ==============
    // 📋 BEST PRACTICES & TIPS
    // ==============

    /**
     * ✅ Best Practices:
     * - Always use `makeAddr()` for deterministic accounts
     * - Use `vm.assume()` to constrain fuzz inputs
     * - Prefer `expectRevert(bytes)` over generic checks
     * - Use `console.log()` for debugging
     * - Label addresses with `vm.label()` for trace clarity
     * - Clean up mocks with `clearMockedCalls()`
     */

    /**
     * ⚠️ Common Gotchas:
     * - Reverts unexpectedly? → Check reverts are expected or logic is correct
     * - Balance issues? → Verify `deal()` / `mint()` calls
     * - Storage corruption? → Use `vm.store()` / `vm.load()` carefully
     * - Fork fails? → Confirm RPC URL and block number
     * - Invariant fails? → Investigate overflow, access control, state sync
     */

    /**
     * 🧰 CLI Command Examples:
     * forge test --match-contract StandardTest
     * forge test --match-contract InvariantTestWithHandlers -vvv
     * forge test --invariant
     * forge test --debug <failing_test>
     */
