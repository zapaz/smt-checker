// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Overflow {
    uint256 immutable _x;
    uint256 immutable _y;

    function add(uint256 x_, uint256 y_) internal pure returns (uint256) {
        return x_ + y_;
    }

    constructor(uint256 x_, uint256 y_) {
        (_x, _y) = (x_, y_);
    }

    function stateAdd() public view returns (uint256) {
        return add(_x, _y);
    }

    function invariant() public view {
        assert(_x + _y < 2);
    }
}

//
// https://docs.soliditylang.org/en/v0.8.17/smtchecker.html#smtchecker-targets
//
// $ solc src/Overflow.sol --model-checker-engine all
//
// Warning: CHC: Assertion violation happens here.
// Counterexample:
// _x = 0, _y = 2

// Transaction trace:
// Overflow.constructor(0, 2)
// State: _x = 0, _y = 2
// Overflow.invariant()
//   --> src/Overflow.sol:21:9:
//    |
// 21 |         assert(_x + _y < 2);
//    |         ^^^^^^^^^^^^^^^^^^^
//
