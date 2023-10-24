// SPDX-License-Identifier: UNLICENSED
// (c) SphereX 2023 Terms&Conditions

pragma solidity ^0.8.0;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AddressUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import {StorageSlot} from "@openzeppelin/contracts/utils/StorageSlot.sol";
import {SubProxyStorage} from "../Utils/SubProxyStorage.sol";

/**
 * @dev UUPSUpgradeable implementation designed for implementations under SphereX's ProtectedERC1967SubProxy
 */
abstract contract ProtectedUUPSUpgradeable is SubProxyStorage, UUPSUpgradeable {
    function getSubImplementation() external view returns (address) {
        return _getSubImplementation();
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
    function subUpgradeTo(address newImplementation) external onlySubProxy {
        _authorizeUpgrade(newImplementation);
        _setSubImplementation(newImplementation);
    }

    /**
     * Upgrades the logic in our arbitrary slot and delegates to the new implementation
     * @param newImplementation new dst address
     * @param data delegate call's data for the new implementation
     */
    function subUpgradeToAndCall(address newImplementation, bytes memory data) external onlySubProxy {
        _authorizeUpgrade(newImplementation);
        _setSubImplementation(newImplementation);

        require(AddressUpgradeable.isContract(newImplementation), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = newImplementation.delegatecall(data);
        AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }
}
