// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract OurTokenTest is StdCheats, Test {
    uint256 BOB_STARTING_AMOUNT = 100 ether;

    OurToken public ourToken;
    DeployOurToken public deployer;
    address public deployerAddress;
    address bob;
    address alice;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        bob = makeAddr("bob");
        alice = makeAddr("alice");

        deployerAddress = vm.addr(deployer.deployerKey());
        vm.prank(deployerAddress);
        ourToken.transfer(bob, BOB_STARTING_AMOUNT);
    }

    function testInitialSupply() public {
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(address(this), 1);
    }

    function testAllowances() public {
        uint256 initialAllowance = 1000;

        // Alice approves Bob to spend tokens on her behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);
        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);
        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), BOB_STARTING_AMOUNT - transferAmount);
    }

    // can you get the coverage up?
}

// pragma solidity ^0.8.18;

// import {Test} from "forge-std/Test.sol";
// import {DeployOurToken} from "../script/DeployOurToken.s.sol";
// import {OurToken} from "../src/OurToken.sol";

// contract OurTokenTest is Test {
//     OurToken public ourToken;
//     DeployOurToken public deployer;

//     address bob = makeAddr("bob");
//     address alice = makeAddr("alice");

//     uint256 public constant STARTING_BALANCE = 100 ether;

//     function setUp() public {
//         deployer = new DeployOurToken();
//         ourToken = deployer.run();

//         vm.prank(msg.sender);
//         ourToken.transfer(bob, STARTING_BALANCE);
//     }

//     function testBobBalance() public {
//         assertEq(STARTING_BALANCE, ourToken.balanceOf(bob));
//     }

//     function testAllowancesWorks() public {
//         uint256 initialAllowance = 1000;

//         vm.prank(bob);
//         ourToken.approve(alice, initialAllowance);

//         uint256 transferAmount = 500;

//         vm.prank(alice);
//         ourToken.transferFrom(bob, alice, transferAmount);

//         assertEq(ourToken.balanceOf(alice), transferAmount);
//         assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
//     }

//     function testTransfer() public {
//         vm.prank(msg.sender);
//         ourToken.transfer(alice, 100);
//         assertEq(ourToken.balanceOf(alice), 100);
//     }

//     function testTransferFrom() public {
//         // Mint some tokens to alice initially
//         ourToken.transfer(alice, 1000);

//         // Approve the contract to spend tokens on behalf of alice
//         ourToken.approve(address(this), 100);

//         // Perform the transfer from alice to bob
//         ourToken.transferFrom(alice, bob, 50);

//         // Check the balances after the transfer
//         assertEq(ourToken.balanceOf(bob), 50);
//         assertEq(ourToken.balanceOf(alice), 950); // Alice's balance should be reduced by 50
//     }
// }
