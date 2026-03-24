import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tic_tac_toe_minmax.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("TicTacToe"),
          backgroundColor: Color.fromARGB(120, 8, 0, 248),
          foregroundColor: Color.fromARGB(184, 0, 0, 0),
          centerTitle: true,
        ),
        body: UIBoard(),
      ),
    );
  }
}

class UIBoard extends StatefulWidget {
  const UIBoard({super.key});

  @override
  State<UIBoard> createState() => _UIBoardState();
}

class _UIBoardState extends State<UIBoard> {
  final HumanPlayer _human = HumanPlayer('X');
  final AIPlayer _ai = AIPlayer('O');
  final Board _board = Board();

  bool isProcessing = false;

  Future<void> _handleTap(int r, int c) async {
    if (isProcessing == true) {
      return;
    } else {
      isProcessing = true;
    }

    if (_board.board[r][c] != ' ') {
      isProcessing = false;
      return;
    }
    _board.placeMove1(_human, r, c);
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 300));
    String status = _board.checker();
    if (status == 'noone') {
      _ai.makeMove(_board, _human);
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 300));
      if (_board.checker() == 'computer') {
        _ai.getsAPoint();
        _board.resetBoard();
        _ai.makeMove(_board, _human);
      } else if (_board.checker() == 'draw') {
        _board.resetBoard();
      }
    } else if (status == 'human') {
      _board.resetBoard();
    } else if (status == 'draw') {
      _board.resetBoard();
      _ai.makeMove(_board, _human);
    }

    setState(() {
      isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Spacer(),
        for (int i = 0; i < 3; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int j = 0; j < 3; j++)
                Tile(
                  onTap: _handleTap,
                  row: i,
                  col: j,
                  token: _board.board[i][j],
                ),
            ],
          ),
        ScoreBoard(_ai.score, _human.score),
        Spacer(),
      ],
    );
  }
}

class ScoreBoard extends StatelessWidget {
  const ScoreBoard(this.computerScore, this.humanScore, {super.key});

  final int humanScore;
  final int computerScore;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Text("Computer", style: TextStyle(fontSize: 24)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsetsGeometry.all(8.0),
                child: Center(
                  child: Text("You", style: TextStyle(fontSize: 24)),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Text("$computerScore", style: TextStyle(fontSize: 24)),
              ),
            ),
            Expanded(
              child: Center(
                child: Text("$humanScore", style: TextStyle(fontSize: 24)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class Tile extends StatelessWidget {
  const Tile({
    required this.onTap,
    required this.row,
    required this.col,
    required this.token,
    super.key,
  });

  final String token;
  final int row;
  final int col;
  final Function(int, int) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 115,
      height: 115,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        ),
        onPressed: () {
          onTap(row, col);
        },
        child: Center(
          child: Text(token, style: GoogleFonts.comicRelief(fontSize: 60)),
        ),
      ),
    );
  }
}
