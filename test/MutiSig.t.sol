// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/MultisigWallet.sol";

contract CounterTest is Test {
    MultiSig public multisig;

    address alice;
    address bob;
    address charlie;
    address daisy;

    function setUp() public {
        alice = makeAddr("Alice");
        bob = makeAddr("Bob");
        charlie = makeAddr("Charlie");
        daisy = makeAddr("Daisy");
        address[] memory addr = new address[](3);
        addr[0] = alice;
        addr[1] = bob;
        addr[2] = charlie;
        multisig = new MultiSig(addr,2);
    }

    function testSubmitTransaction() public {
        multisig.submitTraqnsaction{value: 1 ether}(daisy);
    }

    function testexecution() public {
        multisig.submitTraqnsaction{value: 2 ether}(daisy);
        vm.prank(address(alice));
        multisig.confirmTransaction(0);
        vm.prank(address(bob));
        multisig.confirmTransaction(0);
        // multisig.executeTransaction(0);

        assertEq(address(daisy).balance, 2 ether);
    }
}
