// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract LazyCounter {
    int8 private _x;
    int8 private _y;

    constructor(int8 x_, int8 y_) {
        // check that we're within the board boundaries
        require(x_ >= 0 && x_ < 8 && y_ >= 0 && y_ < 8);

        _x = x_;
        _y = y_;
    }

    /// @dev capture a piece at (x_, y_)
    function capture(int8 x_, int8 y_) public {
        require(x_ >= 0 && x_ < 8 && y_ >= 0 && y_ < 8);

        int8 deltaX = x_ - _x;
        int8 deltaY = y_ - _y;
        // check that we're capturing a diagonally adjacent piece
        require((deltaX == 1 || deltaX == -1) && (deltaY == 1 || deltaY == -1));

        // jump over
        _x = x_ + deltaX;
        _y = y_ + deltaY;
    }

    /// @dev can't leave the board under any conditions
    function invariant() public view {
        assert(_x >= 0 && _x < 8 && _y >= 0 && _y < 8);
    }
}

// https://medium.com/coinmonks/smtchecker-almost-practical-superpower-5a3efdb3cf19
//
// $ solc LazyCounter.sol --model-checker-engine all
//
// Warning: CHC: Assertion violation happens here.
// Counterexample:
// _x = (- 1), _y = (- 1)
//
// Transaction trace:
// LazyCounter.constructor(1, 1)
// State: _x = 1, _y = 1
// LazyCounter.capture(0, 0)
// State: _x = (- 1), _y = (- 1)
// LazyCounter.invariant()
//   --> LazyCounter.sol:32:9:
//    |
// 32 |         assert(_x >= 0 && _x < 8 && _y >= 0 && _y < 8);
//    |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//
