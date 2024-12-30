//SPDX License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor(string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }
}

// 0xd16B472C1b3AB8bc40C1321D7b33dB857e823f01
//0x9dAf7c849c20Be671315E77CB689811bD5EDefe6