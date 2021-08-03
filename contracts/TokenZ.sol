// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
contract TokenZ is ERC20PresetMinterPauser {

    constructor() ERC20PresetMinterPauser("TokenZ", "TKNZ") { }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20PresetMinterPauser) {
        super._beforeTokenTransfer(from, to, amount);
    }
}
