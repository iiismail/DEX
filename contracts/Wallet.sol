pragma solidity 0.8.10; 

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol"; 
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol"; 

contract Wallet is Ownable {

    struct Token {
        bytes32 ticker; 
        address tokenAddress; 
    }

    mapping (bytes32 => Token) public tokens; 
    bytes32[] public tokensList; 

    mapping(address => mapping (bytes32 => uint)) public balances; 

    modifier tokenExist(bytes32 ticker){
        require(tokens[ticker].tokenAddress != address(0), "Token does not exist");
        _;
    }

    function addToken(address address_ , bytes32 ticker) onlyOwner external {
        
        tokens[ticker] = Token(ticker, address_); 
        tokensList.push(ticker);
    }

    function deposit(bytes32 ticker, uint amount) tokenExist(ticker) external {
        
        balances[msg.sender][ticker] += amount; 
        IERC20(tokens[ticker].tokenAddress).transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(bytes32 ticker, uint amount) tokenExist(ticker) external {

        require(balances[msg.sender][ticker] >= amount, "Not enough balance"); 
         
        balances[msg.sender][ticker] -= amount; 
        IERC20(tokens[ticker].tokenAddress).transfer(msg.sender, amount);
    }

    function depositEth() public payable {
        balances[msg.sender]["ETH"] += msg.value; 
    }

    function getBalance(bytes32 ticker) public view returns (uint) {
       return balances[msg.sender][ticker];
    }

    

}