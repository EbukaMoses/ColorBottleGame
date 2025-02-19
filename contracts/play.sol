// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract BottleGame {
    struct GameState {
        uint256[5] correctArrangement;
        uint256 attempts;
        bool isActive;
        bool hasWon;
    }

    mapping(address => GameState) public games;

    event GameStarted(address player, uint256 timestamp);
    event AttemptMade(address player, uint256 correctPositions);
    event GameWon(address player, uint256 attempts);
    event GameReset(address player);

    constructor() {
        // Initialize with a random arrangement
    }

    function startNewGame() public {
        require(
            !games[msg.sender].isActive ||
                games[msg.sender].hasWon ||
                games[msg.sender].attempts >= 5,
            "Current game still in progress"
        );

        // Generate new random arrangement
        uint256[5] memory newArrangement = generateRandomArrangement();

        games[msg.sender] = GameState({
            correctArrangement: newArrangement,
            attempts: 0,
            isActive: true,
            hasWon: false
        });

        emit GameStarted(msg.sender, block.timestamp);
    }

    function makeAttempt(uint256[5] memory attempt) public returns (uint256) {
        GameState storage game = games[msg.sender];

        require(game.isActive, "No active game found");
        require(!game.hasWon, "Game already won");
        require(game.attempts < 5, "Maximum attempts reached");

        // Validate input
        for (uint256 i = 0; i < 5; i++) {
            require(
                attempt[i] >= 1 && attempt[i] <= 5,
                "Invalid bottle number"
            );
        }

        // Count correct positions
        uint256 correctPositions = 0;
        for (uint256 i = 0; i < 5; i++) {
            if (attempt[i] == game.correctArrangement[i]) {
                correctPositions++;
            }
        }

        game.attempts++;

        // Check win condition
        if (correctPositions == 5) {
            game.hasWon = true;
            emit GameWon(msg.sender, game.attempts);
        } else if (game.attempts >= 5) {
            game.isActive = false;
        }

        emit AttemptMade(msg.sender, correctPositions);
        return correctPositions;
    }

    function generateRandomArrangement()
        internal
        view
        returns (uint256[5] memory)
    {
        uint256[5] memory arrangement;
        uint256[5] memory used = [uint256(0), 0, 0, 0, 0];

        for (uint256 i = 0; i < 5; i++) {
            uint256 rand = uint256(
                keccak256(abi.encodePacked(block.timestamp, msg.sender, i))
            ) % 5;
            uint256 value = 0;
            uint256 count = 0;

            // Find the nth unused number
            for (uint256 j = 1; j <= 5; j++) {
                if (used[j - 1] == 0) {
                    if (count == rand) {
                        value = j;
                        break;
                    }
                    count++;
                }
            }

            arrangement[i] = value;
            used[value - 1] = 1;
        }

        return arrangement;
    }

    function getGameState()
        public
        view
        returns (uint256 attempts, bool isActive, bool hasWon)
    {
        GameState storage game = games[msg.sender];
        return (game.attempts, game.isActive, game.hasWon);
    }

    function getRemainingAttempts() public view returns (uint256) {
        return 5 - games[msg.sender].attempts;
    }
}
