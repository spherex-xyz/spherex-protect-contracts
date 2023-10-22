// SPDX-License-Identifier: UNLICENSED
// (c) SphereX 2023 Terms&Conditions

pragma solidity ^0.8.0;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AddressUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import {StorageSlot} from "@openzeppelin/contracts/utils/StorageSlot.sol";

/**
 * @dev UUPSUpgradeable implementation designed for implementations under SphereX's ProtectedERC1967SubProxy
 */
abstract contract ProtectedUUPSUpgradeable is UUPSUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable _self = address(this);

    bytes32 private constant _SPHEREX_IMPLEMENTATION_SLOT =
        bytes32(uint256(keccak256("eip1967.spherex.implementation_slot")) - 1);

    /**
     * Sets an address value in in the sub-imp storage slot
     * @param newImplementation to be set
     */
    function _setSubImplementation(address newImplementation) private {
        StorageSlot.getAddressSlot(_SPHEREX_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * Returns an sub-imp address from our arbitrary slot.
     */
    function _getSubImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_SPHEREX_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * the sub-proxy contract with an implementation (as defined in SphereXProtectedSubProxy) pointing to self.
     */
    modifier onlySubProxy() {
        require(address(this) != _self, "Function must be called through delegatecall");
        require(_getSubImplementation() == _self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Overrid with the same implementation replacing the onlyProxy modifier since is being called under a sub-proxy
     */
    function upgradeTo(address newImplementation) public virtual override onlySubProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Overrid with the same implementation replacing the onlyProxy modifier since is being called under a sub-proxy
     */
    function upgradeToAndCall(address newImplementation, bytes memory data)
        public
        payable
        virtual
        override
        onlySubProxy
    {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }

    /**
     * Upgrades the logic in our arbitrary slot
     * @param newImplementation new dst address
     */
    function subUpgradeTo(address newImplementation) external {
        _authorizeUpgrade(newImplementation);
        _setSubImplementation(newImplementation);
    }

    /**
     * Upgrades the logic in our arbitrary slot and delegates to the new implementation
     * @param newImplementation new dst address
     * @param data delegate call's data for the new implementation
     */
    /// @custom:oz-upgrades-unsafe-allow delegatecall
    function subUpgradeToAndCall(address newImplementation, bytes memory data) external {
        _authorizeUpgrade(newImplementation);
        _setSubImplementation(newImplementation);

        require(AddressUpgradeable.isContract(newImplementation), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = newImplementation.delegatecall(data);
        AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }
}
