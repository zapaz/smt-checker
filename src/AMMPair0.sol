// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @dev bare minimum of IERC20 and IERC20Metadata that we'll use
interface IERC20Metadata {
    function decimals() external view returns (uint8);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract AMMPair {
    IERC20Metadata x;
    IERC20Metadata y;

    uint256 xReserves;
    uint256 yReserves;

    uint256 totalSupply;

    constructor(IERC20Metadata _x, IERC20Metadata _y, uint256 depositX, uint256 depositY) {
        require(_x.decimals() == 18);
        require(_y.decimals() == 18);
        require(depositX != 0);
        require(depositY != 0);

        x = _x;
        y = _y;

        xReserves = depositX;
        yReserves = depositY;
        totalSupply = depositX * depositY / 1e18;

        x.transferFrom(msg.sender, address(this), depositX);
        y.transferFrom(msg.sender, address(this), depositY);
    }

    function addLiquidity(uint256 depositX, uint256 depositY) public returns (uint256) {
        require(depositX != 0, "depositX != 0");
        require(depositY != 0, "depositY != 0");
        require(depositX * 1e18 / depositY == xReserves * 1e18 / yReserves, "unbalancing");

        uint256 extraSupply = depositX * totalSupply / xReserves;

        xReserves += depositX;
        yReserves += depositY;
        totalSupply += extraSupply;

        x.transferFrom(msg.sender, address(this), depositX);
        y.transferFrom(msg.sender, address(this), depositY);

        return extraSupply;
    }

    function invariantAddLiquidity(uint256 depositX, uint256 depositY) public {
        uint256 oldSupply = totalSupply;
        uint256 oldXReserves = xReserves;

        uint256 supplyAdded = addLiquidity(depositX, depositY);
        assert(depositX / oldXReserves == supplyAdded / oldSupply);
        revert("all done");
    }
}

// https://medium.com/coinmonks/smtchecker-almost-practical-superpower-5a3efdb3cf19
//
// $ solc AMMPair.sol --model-checker-engine chc --model-checker-show-unproved --model-checker-timeout 0
//
// .. tooks too much time
