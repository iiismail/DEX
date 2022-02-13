pragma solidity 0.8.10; 

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol"; 

contract tokens is ERC20 {
    constructor() ERC20("ChainLink", "LINK") {
        _mint(msg.sender, 10000);
    }
}