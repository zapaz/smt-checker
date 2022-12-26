// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Knight {
    int8 private _x;
    int8 private _y;

    function isValidPosition() internal view returns (bool) {
        return _x >= 0 && _x < 8 && _y >= 0 && _y < 8;
    }

    function move1() public {
        _x += 1;
        _y += 2;
        require(isValidPosition());
    }

    function move2() public {
        _x += 2;
        _y += 1;
        require(isValidPosition());
    }

    function move3() public {
        _x += 2;
        _y -= 1;
        require(isValidPosition());
    }

    function move4() public {
        _x -= 1;
        _y -= 2;
        require(isValidPosition());
    }

    function move5() public {
        _x -= 1;
        _y += 2;
        require(isValidPosition());
    }

    function move6() public {
        _x -= 2;
        _y += 1;
        require(isValidPosition());
    }

    function move7() public {
        _x -= 2;
        _y -= 1;
        require(isValidPosition());
    }

    function move8() public {
        _x -= 1;
        _y -= 2;
        require(isValidPosition());
    }

    function get_to_7_7() public view {
        assert(!(_x == 7 && _y == 7));
    }
}

// https://medium.com/coinmonks/smtchecker-almost-practical-superpower-5a3efdb3cf19
//
// $ solc Knight.sol --model-checker-engine chc --model-checker-show-unproved --model-checker-timeout 0
//
// Warning: CHC: Assertion violation happens here.
// Counterexample:
// _x = 7, _y = 7
//
// Transaction trace:
// Knight.constructor()
// State: _x = 0, _y = 0
// Knight.move1()
//     Knight.isValidPosition() -- internal call
// State: _x = 1, _y = 2
// Knight.move2()
//     Knight.isValidPosition() -- internal call
// State: _x = 3, _y = 3
// Knight.move6()
//     Knight.isValidPosition() -- internal call
// State: _x = 1, _y = 4
// Knight.move2()
//     Knight.isValidPosition() -- internal call
// State: _x = 3, _y = 5
// Knight.move2()
//     Knight.isValidPosition() -- internal call
// State: _x = 5, _y = 6
// Knight.move2()
//     Knight.isValidPosition() -- internal call
// State: _x = 7, _y = 7
// Knight.get_to_7_7()
//   --> Knight.sol:61:9:
//    |
// 61 |         assert(!(_x == 7 && _y == 7));
//    |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
