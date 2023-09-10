// SPDX-License-Identifier: UNLICENSED
// (c) SphereX 2023 Terms&Conditions

pragma solidity ^0.8.0;

import {Proxy} from "openzeppelin/proxy/Proxy.sol";
import {Address} from "openzeppelin/utils/Address.sol";

import {SphereXProtectedBase} from "./SphereXProtectedBase.sol";

abstract contract SphereXProtectedProxy is Proxy, SphereXProtectedBase {
    bytes32 private constant SPHEREX_PROTECTED_SIGS_BASE = bytes32(uint256(keccak256("eip1967.spherex.sigs_base")) - 1);

    constructor(address admin, address operator, address engine) SphereXProtectedBase(admin, operator, engine) {}

    function protectedSigs(bytes4 sig) private view returns (bool protected_sig) {
        bytes32 slot = bytes32(uint256(keccak256(abi.encode(sig, SPHEREX_PROTECTED_SIGS_BASE))));
        assembly {
            protected_sig := sload(slot)
        }
    }

    function changeSphereXProtectedSig(bytes4 sig, bool protected) external {
        bytes32 slot = bytes32(uint256(keccak256(abi.encode(sig, SPHEREX_PROTECTED_SIGS_BASE))));
        assembly {
            sstore(slot, protected)
        }
    }

    function _delegate(address _toimplementation) internal override {
        if (!protectedSigs(msg.sig)) {
            super._delegate(_toimplementation);
            // assembly return from here
        }

        bytes memory ret_data = _protectedDelegate(_toimplementation);
        uint256 ret_size = ret_data.length;

        // slither-disable-next-line assembly
        assembly {
            return(add(ret_data, 0x20), ret_size)
        }
    }

    function _protectedDelegate(address _toimplementation) private sphereXGuardExternalSig returns (bytes memory) {
        bytes memory ret_data = Address.functionDelegateCall(_toimplementation, msg.data);
        return ret_data;
    }
}
