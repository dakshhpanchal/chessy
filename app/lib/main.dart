// lib/main.dart
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChessHomePage(),
    );
  }
}

class ChessHomePage extends StatefulWidget {
  const ChessHomePage({super.key});
  @override
  State<ChessHomePage> createState() => _ChessHomePageState();
}

class _ChessHomePageState extends State<ChessHomePage> {
  // Board: [row][col], 0..7
  late List<List<String>> board;

  // selected square as row,col or null
  Pair<int, int>? selected;

  @override
  void initState() {
    super.initState();
    board = _initialBoard();
    // precache assets to avoid first-draw jank
    _precachePieces();
  }

  List<List<String>> _initialBoard() {
    return [
      ['br','bn','bb','bq','bk','bb','bn','br'],
      ['bp','bp','bp','bp','bp','bp','bp','bp'],
      ['','','','','','','',''],
      ['','','','','','','',''],
      ['','','','','','','',''],
      ['','','','','','','',''],
      ['wp','wp','wp','wp','wp','wp','wp','wp'],
      ['wr','wn','wb','wq','wk','wb','wn','wr'],
    ];
  }

  Future<void> _precachePieces() async {
    final names = ['wp','wn','wb','wr','wq','wk','bp','bn','bb','br','bq','bk'];
    for (final n in names) {
      final provider = AssetImage('assets/pieces/$n.png');
      // ignore: use_build_context_synchronously
      await precacheImage(provider, context);
    }
  }

  void _onTapSquare(int row, int col) {
    setState(() {
      final piece = board[row][col];
      if (selected == null) {
        // select only if there's a piece
        if (piece != '') selected = Pair(row, col);
      } else {
        // apply move (no legality check here)
        final fromR = selected!.a;
        final fromC = selected!.b;
        if (fromR == row && fromC == col) {
          // unselect
          selected = null;
        } else {
          board[row][col] = board[fromR][fromC];
          board[fromR][fromC] = '';
          selected = null;
        }
      }
    });
  }

  String boardToFen() {
    // Simple FEN generator (no castling/en passant/halfmove/fullmove)
    final rows = <String>[];
    for (var r = 0; r < 8; r++) {
      var emptyCount = 0;
      var rowStr = '';
      for (var c = 0; c < 8; c++) {
        final p = board[r][c];
        if (p == '') {
          emptyCount++;
        } else {
          if (emptyCount > 0) {
            rowStr += '$emptyCount';
            emptyCount = 0;
          }
          final char = _pieceCodeToFenChar(p);
          rowStr += char;
        }
      }
      if (emptyCount > 0) rowStr += '$emptyCount';
      rows.add(rowStr);
    }
    return rows.join('/') + ' w - - 0 1';
  }

  String _pieceCodeToFenChar(String code) {
    if (code.isEmpty) return '';
    final color = code[0]; // 'w' or 'b'
    final t = code[1]; // p,n,b,r,q,k
    final map = {
      'p': 'p',
      'n': 'n',
      'b': 'b',
      'r': 'r',
      'q': 'q',
      'k': 'k',
    };
    final ch = map[t] ?? '?';
    return color == 'w' ? ch.toUpperCase() : ch;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Chessboard — Prototype'),
        actions: [
          IconButton(
            tooltip: 'Print FEN',
            onPressed: () {
              final fen = boardToFen();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('FEN: $fen')),
              );
            },
            icon: const Icon(Icons.copy_all),
          ),
          IconButton(
            tooltip: 'Reset Board',
            onPressed: () {
              setState(() {
                board = _initialBoard();
                selected = null;
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: LayoutBuilder(builder: (context, constraints) {
              final squareSize = constraints.maxWidth / 8;
              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                ),
                itemCount: 64,
                itemBuilder: (context, index) {
                  final row = index ~/ 8;
                  final col = index % 8;
                  final isLight = (row + col) % 2 == 0;
                  final piece = board[row][col];

                  final isSelected = selected != null &&
                      selected!.a == row &&
                      selected!.b == col;

                  return GestureDetector(
                    onTap: () => _onTapSquare(row, col),
                    child: Container(
                      color: isSelected
                          ? Colors.green[400]
                          : (isLight ? Colors.brown[100] : Colors.brown[500]),
                      child: Center(
                        child: piece.isNotEmpty
                            ? Image.asset(
                                'assets/pieces/$piece.png',
                                width: squareSize * 0.85,
                                height: squareSize * 0.85,
                                fit: BoxFit.contain,
                              )
                            : null,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

// small utility Pair
class Pair<A, B> {
  final A a;
  final B b;
  Pair(this.a, this.b);
}

