pragma solidity ^0.4.9;
contract TicTacToeP{

    mapping(address => Board) public boards;
    mapping(address => uint) public players;
    
    address owner;
    uint numAccounts = 0;
    uint ownerBet;
    uint gameNumber;
    bool isPlaying = false;
    bool hasStarted = false;
    struct Board {
        uint size;
        uint challengerBet;
        address challenger;
        address turnFinder;
        uint currTime;
        mapping (uint => string) ticTacToe;
    }       
  
    modifier checkRowAndColumnInputNull(uint row, uint col) { 
        uint boardPos = (row - 1) * 3 + (col - 1);
        if (boardPos > 8) throw;
        if (sha3(boards[owner].ticTacToe[boardPos]) == sha3(''))
    _;}
    
    modifier hasGame() {
        if (gameNumber >= 1) 
    _;}
    
    modifier started() {
        if (hasStarted) _;
    }
    
    modifier isThereAGame() {
        if (isPlaying) {
            throw;
        }
        _;
    }
    
    modifier correctMove() {
        if (boards[owner].turnFinder == msg.sender) _;
    }
    
    modifier currentlyPlaying(){
        if (!(msg.sender == owner || msg.sender == boards[owner].challenger)) 
        _;
    }
    
    modifier safeStop(){
        if (msg.sender == owner || msg.sender == boards[owner].challenger) _;
    }                                                  
    function startScheme() payable {
        if (hasStarted) {
            throw;
        }
        numAccounts++;
        gameNumber = 0;
        hasStarted = true;
        owner = msg.sender;
        ownerBet = msg.value;
        players[owner] = msg.value;
    }       
    
    function join() isThereAGame payable {
       if (msg.sender == owner) {
           throw;
       }
       isPlaying = true;
       if (gameNumber != 0) {
           ownerBet = boards[owner].challengerBet;
           owner = boards[owner].challenger;
       }
       if (players[msg.sender] == 0) {
           numAccounts++;
       }
       players[msg.sender] += msg.value;
       if (msg.value * 10 > 110 * ownerBet) {
           boards[owner] = Board(0, msg.value, msg.sender, owner, block.timestamp);
           gameNumber += 1;
       }
    }
    
  
    function playerMove(uint row, uint col) hasGame correctMove checkRowAndColumnInputNull(row, col) {
        uint moveTime = now;
        if (row > 3 || row < 1 || col > 3 || col < 1) {
            throw;
        }
        uint boardPos = (row - 1) * 3 + (col - 1);
        if (boards[owner].size == 0) {
            boards[owner].currTime = now;
        } 
        if (moveTime - boards[owner].currTime < 3600){
            if (msg.sender == boards[owner].challenger) {
                boards[owner].ticTacToe[boardPos] = 'o';
                boards[owner].turnFinder = owner;
                boards[owner].size += 1;
                boards[owner].currTime = now;
            } else if (msg.sender == owner) {
                boards[owner].ticTacToe[boardPos] = 'x';
                boards[owner].turnFinder = boards[owner].challenger;
                boards[owner].size += 1;
                boards[owner].currTime = now;
            }         
            bool winner = checkWinner();
            if (winner){
                updateAccounts(msg.sender);
            } else if (!winner && noWinner()){
                updateAccounts(owner);
            }
        } else if (moveTime - boards[owner].currTime > 3600) {
            if (msg.sender == owner){
                updateAccounts(boards[owner].challenger);
            } else {   
                updateAccounts(owner);
            }
        }
    }
    
    function withdraw() payable started {
        if (boards[owner].challenger == msg.sender && hasStarted && numAccounts == 1) {
            selfdestruct(boards[owner].challenger);
        } else if (boards[owner].challenger == msg.sender || owner == msg.sender) {
            throw;
        } else {
            players[msg.sender] = 0;
            if (!msg.sender.send(players[msg.sender])){
                throw;
            } else {
                numAccounts--;
            }
        }
    }
    
    function stopGame() safeStop {
        if (now - boards[owner].currTime > 3600){
            if (msg.sender == owner){
                updateAccounts(owner);
            } else {
                updateAccounts(boards[owner].challenger);
            }
        }
    }
  
    function updateAccounts(address winner) internal {
        isPlaying = false;
        if (winner == owner) {
            players[owner] = boards[owner].challengerBet; 
        } 
    }
          
    function rowWin() internal returns (bool) { 
        for (uint i = 0; i < 3; i++){
          if (stringsEqual(boards[owner].ticTacToe[3*i], boards[owner].ticTacToe[(3*i) + 1]) &&
              stringsEqual(boards[owner].ticTacToe[(3*i) + 1], boards[owner].ticTacToe[(3*i) + 2]) &&
              !stringsEqual(boards[owner].ticTacToe[3*i], '')){
                  return true;
              }
        }
        return false;
    }       
               
    function colWin() internal returns (bool) {
        for (uint i = 0; i < 3; i++) {
            if (stringsEqual(boards[owner].ticTacToe[i], boards[owner].ticTacToe[i+3]) 
                && stringsEqual(boards[owner].ticTacToe[i+6], boards[owner].ticTacToe[i+3]) 
                && stringsEqual(boards[owner].ticTacToe[i+3], '')) {
                    return true;
            }
        }
        return false;
    }       
            
    function diagWin() internal returns (bool) {
        if (stringsEqual(boards[owner].ticTacToe[4],'')){
            throw;
        }
        return ((stringsEqual(boards[owner].ticTacToe[0], boards[owner].ticTacToe[4]) 
                && stringsEqual(boards[owner].ticTacToe[8], boards[owner].ticTacToe[4])) || 
                (stringsEqual(boards[owner].ticTacToe[2], boards[owner].ticTacToe[4]) 
                && stringsEqual(boards[owner].ticTacToe[4], boards[owner].ticTacToe[6])));
    }       
                
    function checkWinner() internal returns (bool) {
        return rowWin() || colWin() || diagWin();
    }       
                
    function noWinner() internal returns (bool) {
        return boards[owner].size == 9;
    }
    
    //Function taken from the web. 
    function stringsEqual(string storage _a, string memory _b) internal returns (bool) {
        bytes storage a = bytes(_a);
        bytes memory b = bytes(_b);
        if (a.length != b.length)
            return false;
        // @todo unroll this loop
        for (uint i = 0; i < a.length; i ++)
            if (a[i] != b[i])
                return false;
        return true;
    }
}