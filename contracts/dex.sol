pragma solidity 0.8.10; 
pragma experimental ABIEncoderV2;

import "./Wallet.sol";



contract Dex is Wallet {

    enum Side {
    BUY,
    SELL
}
    
    struct Order {
        uint id; 
        address trader; 
        uint side;
        bytes32 ticker;
        uint amount; 
        uint price; 
        uint filled; 
    }

    uint nextOrderID = 0; 

    


mapping (bytes32 => mapping(uint => Order[])) public orderBook;

function getOrderBook(bytes32 ticker, uint side) view public returns(Order[] memory) {
    return orderBook[ticker][side];
}

 function createLimitOrder(uint side, bytes32 ticker, uint amount,  uint price) public {
        
        
        if (side == 0){
            require(balances[msg.sender][bytes32("ETH")] >= amount * price, "BUY side balance deficient");
            
        }

        if (side == 1){
            require(balances[msg.sender][ticker] >= amount, "SELL side balance deficient");
        }

        Order[] storage orders = orderBook[ticker][side];
        
        uint filled = 0; 

        orders.push(
            Order(nextOrderID, msg.sender, side, ticker, amount, price, filled)
        );


       

        uint i = orders.length > 0 ? orders.length - 1 : 0; 

        if (side == 0){

            while(i>0) {
                if(orders[i - 1].price > orders[i].price) {
                    break;
                }

                Order memory orderToMove = orders[i - 1];
                     orders[i - 1] = orders[i]; 
                     orders[i] = orderToMove;
                     i--; 


            }

        }

        else if (side == 1){

            while(i>0) {
                if(orders[i - 1].price < orders[i].price) {
                    break;
                }

                Order memory orderToMove = orders[i - 1];
                     orders[i - 1] = orders[i]; 
                     orders[i] = orderToMove;
                     i--; 


            }

        }

         nextOrderID++; 




    }

    function createMarketOrder(uint side, bytes32 ticker, uint amount) public{

        if(side == 1){
            require(balances[msg.sender][ticker] >= amount, "Insuffient balance");
        }
        
        uint orderBookSide;
        if(side == 0){
            orderBookSide = 1;
        }
        else{
            orderBookSide = 0;
        }
        Order[] storage orders = orderBook[ticker][orderBookSide];

        uint totalFilled = 0;

        for (uint256 i = 0; i < orders.length && totalFilled < amount; i++) {
            uint leftToFill = amount -totalFilled;
            uint availableToFill = orders[i].amount - orders[i].filled;
            uint filled = 0;
            if(availableToFill > leftToFill){
                filled = leftToFill; //Fill the entire market order
            }
            else{ 
                filled = availableToFill; //Fill as much as is available in order[i]
            }

            totalFilled = totalFilled+(filled);
            orders[i].filled = orders[i].filled+(filled);
            uint cost = filled*(orders[i].price);

            if(side == 0){
                //Verify that the buyer has enough ETH to cover the purchase (require)
                require(balances[msg.sender]["ETH"] >= cost);
                //msg.sender is the buyer
                balances[msg.sender][ticker] = balances[msg.sender][ticker]+(filled);
                balances[msg.sender]["ETH"] = balances[msg.sender]["ETH"]-(cost);
                
                balances[orders[i].trader][ticker] = balances[orders[i].trader][ticker]-(filled);
                balances[orders[i].trader]["ETH"] = balances[orders[i].trader]["ETH"]+(cost);
            }
            else if(side == 1){
                //Msg.sender is the seller
                balances[msg.sender][ticker] = balances[msg.sender][ticker]-(filled);
                balances[msg.sender]["ETH"] = balances[msg.sender]["ETH"]+(cost);
                
                balances[orders[i].trader][ticker] = balances[orders[i].trader][ticker]+(filled);
                balances[orders[i].trader]["ETH"] = balances[orders[i].trader]["ETH"]-(cost);
            }
            
        }
            //Remove 100% filled orders from the orderbook
        while(orders.length > 0 && orders[0].filled == orders[0].amount){
            //Remove the top element in the orders array by overwriting every element
            // with the next element in the order list
            for (uint256 i = 0; i < orders.length - 1; i++) {
                orders[i] = orders[i + 1];
            }
            orders.pop();
        }
        
    }

    //  function remove(Order[] storage array, uint index) internal returns(Order[] storage) {
        
    //     for (uint i = index; i<array.length-1; i++){
    //         array[i] = array[i+1];
    //     }
    //     array.pop(); 
    //     return array;
    // }
    
}




