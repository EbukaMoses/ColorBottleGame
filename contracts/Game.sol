// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract Game {
    uint256[5] private correctArrange;
    uint256 public attempts;
    bool public gameActive;
    address public player;

    constructor() {
        _randomlyShuffleBottles();
    }

    event GameStarted(address indexed player, uint256[5] arrangement);
    event AttemptMade(
        address indexed player,
        uint256[5] attempt,
        uint256 correctCount
    );
    event YouWon(address indexed player);
    event StartAllOver(address indexed player, uint256[5] reshuffle);

    function startGame() external {
        require(!gameActive, "Game going on already");
        player = msg.sender;
        attempts = 0;
        gameActive = true;
        emit GameStarted(player, correctArrange);
    }

    function playGame(
        uint256[5] calldata attempt
    ) external returns (uint256 correctCount) {
        require(gameActive, "No active game");
        require(msg.sender == player, "Not your game session");
        require(attempts < 5, "No attempts left");

        attempts++;
        correctCount = _checkArrangement(attempt);
        emit AttemptMade(player, attempt, correctCount);

        if (correctCount == 5) {
            gameActive = false;
            emit YouWon(player);
        } else if (attempts == 5) {
            _randomlyShuffleBottles();
            emit StartAllOver(player, correctArrange);
        }
    }

    function _checkArrangement(
        uint256[5] memory attempt
    ) private view returns (uint256 correctCount) {
        for (uint256 i = 0; i < 5; i++) {
            if (attempt[i] == correctArrange[i]) {
                correctCount++;
            }
        }
    }

    function _randomlyShuffleBottles() private {
        uint256 outCome = uint256(
            keccak256(
                abi.encodePacked(block.prevrandao, block.number, msg.sender)
            )
        );
        uint256[5] memory reshuffle;

        for (uint256 i = 0; i < 5; i++) {
            reshuffle[i] = (outCome % 5) + 1;
            outCome /= 5;
        }

        correctArrange = reshuffle;
    }
}
