// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AcademicToken is ERC20 {
    constructor() ERC20("AcademicToken", "ACT") {
        _mint(msg.sender, 10000);
    }
}

