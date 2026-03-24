import 'dart:io';

class Board {
  List<List<String>> board = [
    [' ', ' ', ' '],
    [' ', ' ', ' '],
    [' ', ' ', ' '],
  ];

  void resetBoard() {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        board[i][j] = ' ';
      }
    }
  }

  String checker() {
    for (int i = 0; i < 3; i++) {
      if (board[i][0] != ' ' &&
          board[i][0] == board[i][1] &&
          board[i][0] == board[i][2]) {
        return board[i][0] == 'X' ? 'human' : 'computer';
      }
      if (board[0][i] != ' ' &&
          board[0][i] == board[1][i] &&
          board[0][i] == board[2][i]) {
        return board[0][i] == 'X' ? 'human' : 'computer';
      }
    }

    if (board[1][1] != ' ') {
      if ((board[0][0] == board[1][1] && board[1][1] == board[2][2]) ||
          (board[0][2] == board[1][1] && board[1][1] == board[2][0])) {
        return board[1][1] == 'X' ? 'human' : 'computer';
      }
    }

    return board.any((row) => row.contains(' ')) ? 'noone' : 'draw';
  }

  bool validMove(int n) {
    int row = (((n - 1) ~/ 3) - 2).abs();
    int col = (n - 1) % 3;
    if (board[row][col] == ' ') return true;
    return false;
  }

  static int getRow(int n) {
    return (((n - 1) ~/ 3) - 2).abs();
  }

  static int getCol(int n) {
    return (n - 1) % 3;
  }

  void placeMove(Player player, int n) {
    board[Board.getRow(n)][Board.getCol(n)] = player.token;
  }

  void placeMove1(Player player, int r, int c) {
    board[r][c] = player.token;
  }

  void printBoard() {
    print('');
    for (int i = 0; i < 3; i++) {
      print('${board[i][0]} | ${board[i][1]} | ${board[i][2]}');
      (i != 2) ? print('-----------') : print('');
    }
  }
}

abstract class Player {
  String token = ' ';
  int score = 0;

  Player(this.token);

  void makeMove(Board board, Player otherPlayer);

  void getsAPoint() {
    score += 1;
  }

  void resetScore() {
    score = 0;
  }
}

class AIPlayer extends Player {
  AIPlayer(super.token);

  @override
  void makeMove(Board board, Player player) {
    Board b = Board();
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        b.board[i][j] = board.board[i][j];
      }
    }

    List<int> solve(
      Board b,
      Player AI,
      Player Human,
      Player currentPlayer,
      int r,
      int c,
    ) {
      if (b.checker() == 'noone') {
        List<List<int>> res = [];
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            if (b.board[i][j] == ' ') {
              b.board[i][j] = currentPlayer.token;
              List<int> result;
              if (currentPlayer == AI) {
                result = solve(b, AI, Human, Human, i, j);
              } else {
                result = solve(b, AI, Human, AI, i, j);
              }
              b.board[i][j] = ' ';
              res.add([i, j, result[2]]);
            }
          }
        }

        List<int> optimalPosition = [-1, -1, -1000];
        if (currentPlayer == AI) {
          for (int i = 0; i < res.length; i++) {
            if (res[i][2] > optimalPosition[2]) {
              optimalPosition = res[i];
            }
          }
        } else {
          optimalPosition[2] = 1000;
          for (int i = 0; i < res.length; i++) {
            if (res[i][2] < optimalPosition[2]) {
              optimalPosition = res[i];
            }
          }
        }
        return optimalPosition;
      } else if (b.checker() == 'human') {
        return [r, c, -1];
      } else if (b.checker() == 'computer') {
        return [r, c, 1];
      } else if (b.checker() == 'draw') {
        return [r, c, 0];
      }

      return [-1, -1, -1000];
    }

    List<int> move = solve(b, this, player, this, -1, -1);
    board.placeMove(this, AIPlayer.positionToNum(move[0], move[1]));
  }

  static int positionToNum(int r, int c) {
    return 7 - (r * 3) + c;
  }
}

class HumanPlayer extends Player {
  HumanPlayer(super.token);

  @override
  void makeMove(Board board, Player player) {
    int n = -1;
    while (true) {
      stdout.write("Enter a number(1-9): ");
      String a = stdin.readLineSync() ?? "";
      n = int.tryParse(a) ?? -1;
      if (n == -1 || n > 9 || n < 1) {
        a = "";
      } else {
        break;
      }

      if (board.validMove(n) == true) {
        board.placeMove(this, n);
        break;
      } else {
        a = "";
      }
    }
    board.placeMove(this, n);
  }
}

// class Game {
//   HumanPlayer human = HumanPlayer('X');
//   AIPlayer ai = AIPlayer('O');
//   Board board = Board();

//   bool humanTurn = true;

//   void play(int i, int j) {

//   }
// }

void main() {
  HumanPlayer human = HumanPlayer('X');
  AIPlayer ai = AIPlayer('O');
  Board board = Board();

  board.printBoard();
  print("You are X\nComputer is O");
  bool humanTurn = true;
  while (true) {
    while (board.checker() == 'noone') {
      if (humanTurn) {
        print('Your turn');
        human.makeMove(board, ai);
        humanTurn = false;
      } else {
        ai.makeMove(board, human);
        board.printBoard();
        humanTurn = true;
      }
    }

    if (board.checker() == 'computer') {
      print('I win!');
      humanTurn = false;
    } else if (board.checker() == 'human') {
      print('You win!');
      humanTurn = true;
    } else if (board.checker() == 'draw') {
      board.printBoard();
      print("Its a Draw!");
    }

    print("Do you want to continue?");
    String? s = stdin.readLineSync();
    if (s == '' || s == 'yes' || s == 'YES' || s == 'Yes') {
      board.resetBoard();
      continue;
    } else {
      break;
    }
  }
}
