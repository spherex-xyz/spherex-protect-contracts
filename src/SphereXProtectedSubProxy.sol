// SPDX-License-Identifier: UNLICENSED
// (c) SphereX 2023 Terms&Conditions

pragma solidity ^0.8.0;

import {SphereXProtectedProxy} from "./SphereXProtectedProxy.sol";

abstract contract SphereXProtectedSubProxy is SphereXProtectedProxy {

    bytes32 private constant _SPHEREX_IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.spherex.implementation_slot")) - 1);

    constructor(address admin, address operator, address engine, address _logic) SphereXProtectedProxy(admin, operator, engine) {
        _setAddress(_SPHEREX_IMPLEMENTATION_SLOT, _logic);
    }

    function _implementation() internal view virtual override returns (address impl) {
        return _getAddress(_SPHEREX_IMPLEMENTATION_SLOT);
    }

    function subUpgradeTo(address newImplementation) internal {
        _setAddress(_SPHEREX_IMPLEMENTATION_SLOT, newImplementation);
    }
}