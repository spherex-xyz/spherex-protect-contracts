// SPDX-License-Identifier: UNLICENSED
// (c) SphereX 2023 Terms&Conditions

pragma solidity ^0.8.0;

import {TransparentUpgradeableProxy} from "openzeppelin/proxy/transparent/TransparentUpgradeableProxy.sol";
import {SphereXProtectedProxy} from "./SphereXProtectedProxy.sol";

contract SphereXTransparentUpgradeableProxy is SphereXProtectedProxy, TransparentUpgradeableProxy {
    constructor(address _logic, address admin_, bytes memory _data)
        SphereXProtectedProxy(admin_, address(0), address(0))
        TransparentUpgradeableProxy(_logic, admin_, _data)
    {}

    function _fallback() internal virtual override(Proxy, TransparentUpgradeableProxy) {
        TransparentUpgradeableProxy._fallback();
    }
}
