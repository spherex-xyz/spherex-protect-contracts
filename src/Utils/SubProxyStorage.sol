// SPDX-License-Identifier: UNLICENSED
// (c) SphereX 2023 Terms&Conditions

pragma solidity ^0.8.0;

import {StorageSlot} from "@openzeppelin/contracts/utils/StorageSlot.sol";

contract SubProxyStorage {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable _self = address(this);

    bytes32 private constant _SPHEREX_IMPLEMENTATION_SLOT =
        bytes32(uint256(keccak256("eip1967.spherex.implementation_slot")) - 1);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * the sub-proxy contract with an implementation (as defined in SphereXProtectedSubProxy) pointing to self.
     */
    modifier onlySubProxy() {
        require(address(this) != _self, "Function must be called through delegatecall");
        require(_getSubImplementation() == _self, "Function must be called through active proxy");
        _;
    }

    modifier isDelegated() {
        require(address(this) != _self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * Sets an address value in in the sub-imp storage slot
     * @param newImplementation to be set
     */
    function _setSubImplementation(address newImplementation) internal {
        StorageSlot.getAddressSlot(_SPHEREX_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * Returns an sub-imp address from our arbitrary slot.
     */
    function _getSubImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_SPHEREX_IMPLEMENTATION_SLOT).value;
    }
}
