# TicTacToePonzi

Smart Contract Specification
Once the ponzi starts, there will only be two active players involved: the current payee, and a challenger. When a challenger pays into the pot, they automatically enter a game of tic-tac-toe with the current payee.

Tic-tac-toe subspec
Each player has roughly 1 hour to complete any actions required, like submitting a move. If the player fails to act, they forfeit the tic-tac-toe game and the other player wins.
If the current payee wins the game, or if there is a draw, the challenger must pay at least 1.1x what the current payee paid. Any amount that the challenger paid above what the current payee paid will turn into profit for the payee.
If the challenger wins the game, the challenger only needs to pay 1.0x what the current payee paid to become the payee (i.e. the payee has to pay the same amount). Anything the challenger pays over the 1.0x threshold will not count as profit for the current payee, however, it must be matched by the next challenger.
In both cases, after the tic-tac-toe game completes, the challenger will become the new payee, regardless of whether they won the tic-tac-toe game or not. 

Ponzi subspec
The person who deploys the contract automatically becomes the first payee.
A challenger must pay into the contract to initiate the game of tic-tac-toe with the current payee.
Players will hold accounts in this contract, and if someone behind them has paid, the player must be able to withdraw their funds + possible profit!
If someone pays into the contract, but it doesn't meet the required threshold, their money will be deposited into the contract and they must be able to withdraw their money at a later date.
The contract must not eat money, meaning that if every eligible person in the contract withdrew their funds, the Ether balance of the contract would essentially drop to zero, save perhaps the current outstanding amount the payee is waiting on. If you find a way to make another team's contract eat money, it will be considered an eligible bug.

This project was designed to focus on security, so some things we tried to do were:
- Implement safe withdrawal and deposit mechanisms from accounts stored on your contract
- Be wary of gas usage and avoid gas loops
- Be wary of potential race conditions when players join/play/leave the game
- Be wary that all incentives in the contract are aligned and that no player can be locked out their funds and that no funds can be stolen from its intended recipient.

Made for Blockchain At Berkeley
