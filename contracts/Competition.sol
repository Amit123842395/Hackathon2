// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "./Token.sol";

contract Competition is Ownable {
    address public token1;
    address public token2;
    address payable public wallet;
    uint public end_time;
    uint256[2] public score;
    bool public gameInProgress;
    uint public price;
    uint public token1Count;
    uint public token2Count;

    uint public numberTokens;
    bool public gameEnded;
    address public winner;
    uint tokensReturned;
    uint balance;

    event TokensPurchased(address buyer, uint256 amount);

    constructor(address token1_, address token2_) Ownable(msg.sender) {
        token1 = token1_;
        token2 = token2_;
        score[0] = 0;
        score[1] = 0;
        wallet = payable(msg.sender);
        price = 1 gwei;
        token1Count = 100_000 * 10**18;
        token2Count = 100_000 * 10**18;
        gameInProgress = false;
        gameEnded = false;
        tokensReturned = 0;
    }

    function purchaseToken(ERC20 token) public payable {
        require(gameInProgress == false, "Game in progress");

        // 100_000 tokens corresponds to .0001 eth
        // 1 token = .00_000_0001 eth = 1 gwei
        // Transfer the received Ether to the owner
        numberTokens = (msg.value * 10**18) / price;
        
        require(numberTokens > 0, "You must send enough gwei to buy at least 1 token");
        if (address(token) == token1 && token1Count < numberTokens){
            revert("Insufficient token1 remaining");
        }
        if (address(token) == token2 && token2Count < numberTokens){
            revert("Insufficient token2 remaining");
        }

        // Transfer the tokens from the owner to the buyer
        // Transfer the received Ether to the owner
        // (bool sent, ) = wallet.call{value: msg.value}("");
        // require(sent, "Failed to send Ether");

        // Transfer the tokens from the owner to the buyer
        bool success = token.transferFrom(wallet, msg.sender, numberTokens);
        require(success, "Token transfer failed");

        emit TokensPurchased(msg.sender, numberTokens);
    }

    function start() public onlyOwner {
        gameInProgress = true;
    }


    function getScore() public view returns (uint256[2] memory) {
        return score;
    }
    
    // Function to update a score at a specific index in the scores array
    function updateScore(uint256 _index, uint256 _newScore) public onlyOwner {
        require(_index < score.length, "Index out of bounds");
        score[_index] = _newScore;
    }


    function end(int winner_) public onlyOwner {
        gameInProgress = false;
        gameEnded = true;
        winner = (winner_ == 1 ? token1 : token2);
    }

    function cashout(uint amount) public {
        require(gameEnded == true, "Game not ended");
        require(amount > 0, "Amount must be greater than zero");
        

        balance = address(this).balance;
        price = balance / (100_000 - tokensReturned); // get wei per token


        uint ethAmount = (amount * price) / 10**18; // Adjusting for 18 decimals
        require(address(this).balance >= ethAmount, "Insufficient ETH in contract");

        // Transfer tokens from the user to the contract
        bool success = ERC20(winner).transferFrom(msg.sender, address(this), amount);
        require(success, "Token transfer failed");

        // Transfer ETH to the user
        (bool sent, ) = msg.sender.call{value: ethAmount}("");
        require(sent, "Failed to send Ether");

        // emit TokensCashedOut(msg.sender, amount);
        // emit Log("Cashout completed", msg.sender, amount, address(token));
    }

}

// Things need to decide:
// - If amount of winner token bought should be all ETH returned from LP or ETH from LP - original contributions

// Things need to do:
// - Change the amount of ether provided for liquidity with each hosted game
// - Change the address of the owner to not be my wallet
// - Don't hardcode when deploying
// - Test