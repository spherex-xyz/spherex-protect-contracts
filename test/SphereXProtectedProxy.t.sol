// SPDX-License-Identifier: UNLICENSED
// (c) SphereX 2023 Terms&Conditions

pragma solidity >=0.6.2;

import "forge-std/Test.sol";

contract SphereXProtectedBaseTest is Test {
    function setUp() public {
        allowed_senders.push(address(this));
        spherex_engine.addAllowedSender(allowed_senders);
    }
}
