// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface Unknown {
    function run() external;
}

contract Mutex {
    uint256 _x;
    bool _lock;

    Unknown immutable unknown;

    constructor(Unknown u_) {
        require(address(u_) != address(0));
        unknown = u_;
    }

    modifier mutex() {
        require(!_lock);
        _lock = true;
        _;
        _lock = false;
    }

    function set(uint256 x_) public mutex {
        _x = x_;
    }

    // function run() public mutex {
    function run() public {
        uint256 xPre = _x;
        unknown.run();
        assert(xPre == _x);
    }
}

// https://docs.soliditylang.org/en/v0.8.17/smtchecker.html#smtchecker-targets
//
// Warning: CHC: Assertion violation happens here.
// Counterexample:
// _x = 1, _lock = false, unknown = 1
// xPre = 0
//
// Transaction trace:
// Mutex.constructor(1)
// State: _x = 0, _lock = false, unknown = 1
// Mutex.run()
//     unknown.run() -- untrusted external call, synthesized as:
//         Mutex.set(1) -- reentrant call
//   --> src/Mutex.sol:34:9:
//    |
// 34 |         assert(xPre == _x);
//    |         ^^^^^^^^^^^^^^^^^^
//
