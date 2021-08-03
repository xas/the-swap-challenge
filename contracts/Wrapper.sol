// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract Wrapper is Context {
    using SafeMath for uint256;

    // address for the first swappable token (eg. token A)
    address private addressTokenLeft1;
    // address for the second swappable token (eg. token B)
    address private addressTokenLeft2;
    // address for the swappable destination token (eg. token C)
    ERC20PresetMinterPauser private tokenRight1;
    address private addressTokenRight1;

    event Swap(address indexed from, address indexed to, uint256 value);
    event Unswap(address indexed from, address indexed to, uint256 value);

    constructor(address _t1, address _t2, address _t3) {
        require(_t1 != address(0), "Token 1 at 0");
        require(_t2 != address(0), "Token 2 at 0");
        require(_t3 != address(0), "Token 3 at 0");
        addressTokenLeft1 = _t1;
        addressTokenLeft2 = _t2;
        addressTokenRight1 = _t3;
        tokenRight1 = ERC20PresetMinterPauser(_t3);
    }

    modifier checkTokenAddress(address _token) {
      require(_token == addressTokenLeft1 || _token == addressTokenLeft2, "Token address not valid");
      _;
    }

    /**
     * Convert an amount of input token_ to an equivalent amount of the output token
     *
     * @param _token address of token to swap
     * @param amount amount of token to swap/receive
     */
    function swap(address _token, uint amount) checkTokenAddress(_token) external {
      /** begin fix (see README.md) **/
      require(amount > 0, "Amount is zero");
      /** end fix **/

      IERC20(_token).transferFrom(_msgSender(), address(this), amount);
      tokenRight1.mint(_msgSender(), amount);
      emit Swap(_msgSender(), _token, amount);
    }

    /**
     * Convert an amount of the output token to an equivalent amount of input token_
     *
     * @param _token address of token to receive
     * @param amount amount of token to swap/receive
     */
    function unswap(address _token, uint amount) checkTokenAddress(_token) external {
      /** begin fix (see README.md) **/
      require(amount > 0, "Amount is zero");
      /** end fix **/

      tokenRight1.burnFrom(_msgSender(), amount);

      /** begin fix (see README.md) **/
      require(IERC20(_token).balanceOf(_msgSender()) >= amount, "Not enough tokens");
      /** end fix **/

      IERC20(_token).transfer(_msgSender(), amount);
      emit Unswap(_msgSender(), _token, amount);
    }
}
