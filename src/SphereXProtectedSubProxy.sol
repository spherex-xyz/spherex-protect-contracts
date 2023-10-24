// SPDX-License-Identifier: UNLICENSED
// (c) SphereX 2023 Terms&Conditions

pragma solidity ^0.8.0;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";

import {SphereXProtectedProxy} from "./SphereXProtectedProxy.sol";
import {SphereXInitializable} from "./Utils/SphereXInitializable.sol";
import {SubProxyStorage} from "./Utils/SubProxyStorage.sol";

/**
 * @title Interface for SphereXProtectedSubProxy - upgrade logic
 */
interface ISphereXProtectedSubProxy {
    function subUpgradeTo(address newImplementation) external;
    function subUpgradeToAndCall(address newImplementation, bytes memory data) external;
}

/**
 * @title A version of SphereX's proxy implementation designed to be under another proxy,
 *        Enabled using a different arbitrary slot for the imp to avoid clashing with the first proxy,
 *        and adding initializing and sub-uprade logic to SphereXProtectedSubProxy.
 */
contract SphereXProtectedSubProxy is SphereXProtectedProxy, SphereXInitializable, SubProxyStorage {
    /**
     * @dev Prevents initialization of the implementation contract itself,
     * as extra protection to prevent an attacker from initializing it.
     * SEE: https://forum.openzeppelin.com/t/what-does-disableinitializers-function-mean/28730/2
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() SphereXProtectedProxy(address(0), address(0), address(0)) {
        _disableInitializers();
    }

    /**
     * Used when the client uses a proxy - should be called by the inhereter initialization
     */
    function initialize(address admin, address operator, address engine, address _logic, bytes memory data)
        external
        initializer
    {
        __SphereXProtectedBase_init(admin, operator, engine);
        _setSubImplementation(_logic);
        if (data.length > 0) {
            Address.functionDelegateCall(_logic, data);
        }
    }

    /**
     * Override Proxy.sol _implementation and retrieve the imp address from the another arbitrary slot.
     */
    function _implementation() internal view virtual override returns (address impl) {
        return _getSubImplementation();
    }

    /**
     * Upgrades the logic in our arbitrary slot
     * @param newImplementation new dst address
     */
    function subUpgradeTo(address newImplementation) internal onlySubProxy {
        _setSubImplementation(newImplementation);
    }

    /**
     * Upgrades the logic in our arbitrary slot and delegates to the new implementation
     * @param newImplementation new dst address
     * @param data delegate call's data for the new implementation
     */
    function subUpgradeToAndCall(address newImplementation, bytes memory data) internal onlySubProxy {
        subUpgradeTo(newImplementation);
        if (data.length > 0) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    function upgradeTo(address newImplementation) public {
        _fallback();
    }

    /**
     * @dev To avoid calling fallback from non-delegate calls
     */
    function _beforeFallback() internal virtual override isDelegated {}
}
