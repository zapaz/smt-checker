// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @dev bare minimum of IERC20 and IERC20Metadata that we'll use
interface IERC20 {
    function decimals() external view returns (uint8);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract AMMPairEngine {
    uint256 xReserves;
    uint256 yReserves;

    uint256 totalSupply;

    constructor(uint256 depositX, uint256 depositY) {
        require(depositX > 1e9, "depositX != 0");
        require(depositY > 1e9, "depositY != 0");

        xReserves = depositX;
        yReserves = depositY;
        totalSupply = depositX * depositY / 1e18;
    }

    function addLiquidityStateChange(uint256 depositX, uint256 depositY) internal returns (uint256) {
        require(depositX != 0, "depositX != 0");
        require(depositY != 0, "depositY != 0");
        require((depositX * 1e18) / depositY == (xReserves * 1e18) / yReserves, "unbalancing");

        uint256 extraSupply = (depositX * totalSupply) / xReserves;

        xReserves += depositX;
        yReserves += depositY;
        totalSupply += extraSupply;

        return extraSupply;
    }

    function invariant1() public view {
        assert(xReserves > 0);
        assert(yReserves > 0);
    }

    function invariantAddLiquidity(uint256 depositX, uint256 depositY) public {
        uint256 oldSupply = totalSupply;
        uint256 oldXReserves = xReserves;

        uint256 supplyAdded = addLiquidityStateChange(depositX, depositY);
        assert(depositX / oldXReserves == supplyAdded / oldSupply);
        revert("all done");
    }
}

contract AMMPair is AMMPairEngine {
    IERC20 x;
    IERC20 y;

    constructor(IERC20 _x, IERC20 _y, uint256 depositX, uint256 depositY) AMMPairEngine(depositX, depositY) {
        require(_x.decimals() == 18);
        require(_y.decimals() == 18);

        x = _x;
        y = _y;

        x.transferFrom(msg.sender, address(this), depositX);
        y.transferFrom(msg.sender, address(this), depositY);
    }

    function addLiquidity(uint256 depositX, uint256 depositY) public {
        addLiquidityStateChange(depositX, depositY);

        x.transferFrom(msg.sender, address(this), depositX);
        y.transferFrom(msg.sender, address(this), depositY);
    }
}
