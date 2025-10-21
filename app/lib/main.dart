import 'package:flutter/material.dart';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';

void main() => runApp(const MyApp());

class Pair<A, B> {
  final A a;
  final B b;
  Pair(this.a, this.b);
}

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
  late List<List<String>> board;
  Pair<int, int>? selected;
  bool isWhiteTurn = true;
  double currentEval = 0.0;
  bool isEngineThinking = false;
  String gameStatus = "White's turn";
  List<Pair<int, int>> validMoves = [];

  // Chess engine FFI
  late ffi.DynamicLibrary dylib;
  late int Function(ffi.Pointer<ffi.Char>) evaluatePosition;

  @override
  void initState() {
    super.initState();
    board = _initialBoard();
    _precachePieces();
    _loadEngine();
  }

  void _loadEngine() {
    try {
      if (Platform.isAndroid || Platform.isLinux) {
        dylib = ffi.DynamicLibrary.open('libengine.so');
      } else if (Platform.isIOS || Platform.isMacOS) {
        dylib = ffi.DynamicLibrary.open('libengine.dylib');
      } else if (Platform.isWindows) {
        dylib = ffi.DynamicLibrary.open('engine.dll');
      } else {
        throw UnsupportedError('Platform not supported');
      }

      evaluatePosition = dylib
          .lookup<
            ffi.NativeFunction<ffi.Int32 Function(ffi.Pointer<ffi.Char>)>
          >('eval')
          .asFunction<int Function(ffi.Pointer<ffi.Char>)>();
    } catch (e) {
      debugPrint('Failed to load chess engine: $e');
    }
  }

  List<List<String>> _initialBoard() {
    return [
      ['br', 'bn', 'bb', 'bq', 'bk', 'bb', 'bn', 'br'],
      ['bp', 'bp', 'bp', 'bp', 'bp', 'bp', 'bp', 'bp'],
      ['', '', '', '', '', '', '', ''],
      ['', '', '', '', '', '', '', ''],
      ['', '', '', '', '', '', '', ''],
      ['', '', '', '', '', '', '', ''],
      ['wp', 'wp', 'wp', 'wp', 'wp', 'wp', 'wp', 'wp'],
      ['wr', 'wn', 'wb', 'wq', 'wk', 'wb', 'wn', 'wr'],
    ];
  }

  Future<void> _precachePieces() async {
    final names = [
      'wp',
      'wn',
      'wb',
      'wr',
      'wq',
      'wk',
      'bp',
      'bn',
      'bb',
      'br',
      'bq',
      'bk',
    ];
    for (final n in names) {
      final provider = AssetImage('assets/pieces/$n.png');
      // ignore: use_build_context_synchronously
      await precacheImage(provider, context);
    }
  }

  bool _isValidPawnMove(int fromR, int fromC, int toR, int toC) {
    final piece = board[fromR][fromC];
    final isWhite = piece.startsWith('w');
    final direction = isWhite ? -1 : 1;
    final startRow = isWhite ? 6 : 1;
    final targetPiece = board[toR][toC];

    if (fromC == toC) {
      if (toR == fromR + direction && targetPiece.isEmpty) {
        return true;
      }

      if (fromR == startRow &&
          toR == fromR + 2 * direction &&
          targetPiece.isEmpty &&
          board[fromR + direction][fromC].isEmpty) {
        return true;
      }
    }
    if ((toC == (fromC + 1) || toC == (fromC - 1)) &&
        toR == fromR + direction &&
        targetPiece.isNotEmpty) {
      return true;
    }

    return false;
  }

  bool _isValidKnightMove(int fromR, int fromC, int toR, int toC) {
    final rowDiff = (fromR - toR).abs();
    final colDiff = (fromC - toC).abs();

    return (colDiff == 2 && rowDiff == 1) || (colDiff == 1 && rowDiff == 2);
  }

  bool _isValidBishopMove(int fromR, int fromC, int toR, int toC) {
    final rowDiff = (fromR - toR).abs();
    final colDiff = (fromC - toC).abs();

    if (rowDiff != colDiff) {
      return false;
    }

    final rowStep = toR > fromR ? 1 : -1;
    final colStep = toC > fromC ? 1 : -1;

    var currentR = fromR + rowStep;
    var currentC = fromC + colStep;

    while (currentR != toR || currentC != toC) {
      if (board[currentR][currentC].isNotEmpty) {
        return false;
      }
      currentR += rowStep;
      currentC += colStep;
    }

    return true;
  }

  bool _isValidRookMove(int fromR, int fromC, int toR, int toC) {
    if (toR != fromR && toC != fromC) {
      return false;
    }

    if (fromR == toR) {
      final step = toC > fromC ? 1 : -1;
      var currentC = fromC + step;
      while (currentC != toC) {
        if (board[fromR][currentC].isNotEmpty) {
          return false;
        }
        currentC += step;
      }
    } else if (fromC == toC) {
      final step = toR > fromR ? 1 : -1;
      var currentR = fromR + step;
      while (currentR != toR) {
        if (board[currentR][fromC].isNotEmpty) {
          return false;
        }
        currentR += step;
      }
    }
    return true;
  }

  bool _isValidQueenMove(int fromR, int fromC, int toR, int toC) {
    return _isValidBishopMove(fromR, fromC, toR, toC) ||
        _isValidRookMove(fromR, fromC, toR, toC);
  }

  bool _isValidKingMove(int fromR, int fromC, int toR, int toC) {
    final rowDiff = (toR - fromR).abs();
    final colDiff = (toC - fromC).abs();

    if (rowDiff <= 1 && colDiff <= 1) {
      return true;
    }
    return false;
  }

  bool _isValidMove(int fromR, int fromC, int toR, int toC) {
    final piece = board[fromR][fromC];
    if (piece.isEmpty) return false;

    if (isWhiteTurn && !piece.startsWith('w')) return false;
    if (!isWhiteTurn && !piece.startsWith('b')) return false;

    if (fromR == toR && fromC == toC) return false;

    final targetPiece = board[toR][toC];
    if (targetPiece.isNotEmpty) {
      if (piece.startsWith('w') && targetPiece.startsWith('w')) return false;
      if (piece.startsWith('b') && targetPiece.startsWith('b')) return false;
    }

    final pieceType = piece[1];
    switch (pieceType) {
      case 'p':
        return _isValidPawnMove(fromR, fromC, toR, toC);
      case 'n':
        return _isValidKnightMove(fromR, fromC, toR, toC);
      case 'b':
        return _isValidBishopMove(fromR, fromC, toR, toC);
      case 'r':
        return _isValidRookMove(fromR, fromC, toR, toC);
      case 'q':
        return _isValidQueenMove(fromR, fromC, toR, toC);
      case 'k':
        return _isValidKingMove(fromR, fromC, toR, toC);
      default:
        return false;
    }
  }

  List<Pair<int, int>> _getValidMoves(int row, int col) {
    final moves = <Pair<int, int>>[];
    for (var r = 0; r < 8; r++) {
      for (var c = 0; c < 8; c++) {
        if (_isValidMove(row, col, r, c)) {
          moves.add(Pair(r, c));
        }
      }
    }
    return moves;
  }

  bool _isValidMoveTarget(int row, int col) {
    return validMoves.any((move) => move.a == row && move.b == col);
  }

  void _onTapSquare(int row, int col) {
    if (isEngineThinking) return;

    setState(() {
      final piece = board[row][col];

      if (selected == null) {
        if (piece.isNotEmpty) {
          if ((isWhiteTurn && piece.startsWith('w')) ||
              (!isWhiteTurn && piece.startsWith('b'))) {
            selected = Pair(row, col);
            validMoves = _getValidMoves(row, col);
          }
        }
      } else {
        final fromR = selected!.a;
        final fromC = selected!.b;

        if (fromR == row && fromC == col) {
          selected = null;
          validMoves = [];
        } else if (piece.isNotEmpty &&
            ((isWhiteTurn && piece.startsWith('w')) ||
                (!isWhiteTurn && piece.startsWith('b')))) {
          selected = Pair(row, col);
          validMoves = _getValidMoves(row, col);
        } else if (_isValidMove(fromR, fromC, row, col)) {
          board[row][col] = board[fromR][fromC];
          board[fromR][fromC] = '';
          selected = null;
          validMoves = [];

          isWhiteTurn = !isWhiteTurn;
          gameStatus = isWhiteTurn ? "White's turn" : "Black's turn";
          _updateEvaluation();

          if (!isWhiteTurn) {
            _getEngineMove();
          }
        } else {
          selected = null;
          validMoves = [];
        }
      }
    });
  }

  Future<void> _updateEvaluation() async {
    try {
      final fen = boardToFen();
      debugPrint('Sending FEN to engine: $fen');

      final fenPointer = fen.toNativeUtf8().cast<ffi.Char>();
      final eval = evaluatePosition(fenPointer);
      malloc.free(fenPointer);

      setState(() {
        currentEval = eval / 100.0;
        debugPrint('Engine evaluation: $eval centipawns, $currentEval pawns');
      });
    } catch (e) {
      debugPrint('Evaluation error: $e');
      setState(() {
        currentEval = 0.0;
      });
    }
  }

  String boardToFen() {
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

    final turnChar = isWhiteTurn ? 'w' : 'b';
    return '${rows.join('/')} $turnChar - - 0 1';
  }

  String _pieceCodeToFenChar(String code) {
    if (code.isEmpty) return '';
    final color = code[0];
    final t = code[1];
    final map = {'p': 'p', 'n': 'n', 'b': 'b', 'r': 'r', 'q': 'q', 'k': 'k'};
    final ch = map[t] ?? '?';
    return color == 'w' ? ch.toUpperCase() : ch;
  }

  Future<void> _getEngineMove() async {
    if (isEngineThinking) return;

    setState(() {
      isEngineThinking = true;
      gameStatus = "Engine thinking...";
    });

    try {
      final fen = boardToFen();
      final fenPointer = fen.toNativeUtf8().cast<ffi.Char>();
      malloc.free(fenPointer);

      const String moveString = "e7e5";
      //_applyEngineMove(moveString);

      setState(() {
        isEngineThinking = false;
        isWhiteTurn = true;
        gameStatus = "White's turn";
      });

      _updateEvaluation();
    } catch (e) {
      setState(() {
        isEngineThinking = false;
        gameStatus = "Engine error";
      });
      debugPrint('Engine error: $e');
    }
  }

  void _applyEngineMove(String move) {
    if (move.length >= 4) {
      try {
        final fromFile = move[0].codeUnitAt(0) - 'a'.codeUnitAt(0);
        final fromRank = 8 - int.parse(move[1]);
        final toFile = move[2].codeUnitAt(0) - 'a'.codeUnitAt(0);
        final toRank = 8 - int.parse(move[3]);

        setState(() {
          board[toRank][toFile] = board[fromRank][fromFile];
          board[fromRank][fromFile] = '';
        });
      } catch (e) {
        debugPrint('Failed to parse engine move: $e');
      }
    }
  }

  Widget _buildEvaluationBar() {
    double clampedEval = currentEval.clamp(-10.0, 10.0);
    double percentage = (clampedEval + 10.0) / 20.0;

    Color barColor;
    if (currentEval > 2.0) {
      barColor = Colors.green[400]!;
    } else if (currentEval > 0.5) {
      barColor = Colors.lightGreen;
    } else if (currentEval < -2.0) {
      barColor = Colors.red[700]!;
    } else if (currentEval < -0.5) {
      barColor = Colors.red[400]!;
    } else {
      barColor = Colors.grey;
    }

    return Container(
      width: 30,
      height: 400,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade800),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.grey.shade700, Colors.white],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: percentage * 400,
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: barColor.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              height: 1,
              width: double.infinity,
              color: Colors.grey.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveDot(bool isCapture) {
    return Center(
      child: Container(
        width: isCapture ? 36 : 20,
        height: isCapture ? 36 : 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCapture ? Colors.transparent : Colors.green.withOpacity(0.3),
          border: isCapture
              ? Border.all(
                  color: const Color.fromARGB(255, 231, 0, 0).withOpacity(0.6),
                  width: 3,
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gameStatus),
        backgroundColor: isWhiteTurn ? Colors.white : Colors.black,
        foregroundColor: isWhiteTurn ? Colors.black : Colors.white,
        actions: [
          if (isEngineThinking)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          IconButton(
            tooltip: 'Reset Board',
            onPressed: isEngineThinking
                ? null
                : () {
                    setState(() {
                      board = _initialBoard();
                      selected = null;
                      validMoves = [];
                      isWhiteTurn = true;
                      currentEval = 0.0;
                      gameStatus = "White's turn";
                    });
                    _updateEvaluation();
                  },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Chess Board
              Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade800, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(4, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 8,
                            ),
                        itemCount: 64,
                        itemBuilder: (context, index) {
                          final row = index ~/ 8;
                          final col = index % 8;
                          final isLight = (row + col) % 2 == 0;
                          final piece = board[row][col];

                          final isSelected =
                              selected != null &&
                              selected!.a == row &&
                              selected!.b == col;

                          final isValidMoveTarget = _isValidMoveTarget(
                            row,
                            col,
                          );
                          final isCapture =
                              isValidMoveTarget && piece.isNotEmpty;

                          return GestureDetector(
                            onTap: () => _onTapSquare(row, col),
                            child: Container(
                              color: isSelected
                                  ? Colors.blue[400]!.withOpacity(0.7)
                                  : isValidMoveTarget && isCapture
                                  ? Colors.red.withOpacity(0.4)
                                  : (isLight
                                        ? Colors.brown[100]
                                        : Colors.brown[700]),
                              child: Stack(
                                children: [
                                  if (isValidMoveTarget && !isSelected)
                                    _buildMoveDot(isCapture),

                                  if ((row == 7 && col == 0) ||
                                      (row == 0 && col == 7))
                                    Positioned(
                                      top: row == 7 ? 2 : null,
                                      bottom: row == 0 ? 2 : null,
                                      left: col == 0 ? 4 : null,
                                      right: col == 7 ? 4 : null,
                                      child: Text(
                                        _getCoordinateLabel(row, col),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isLight
                                              ? Colors.brown[800]
                                              : Colors.brown[100],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                  // Chess piece
                                  Center(
                                    child: piece.isNotEmpty
                                        ? Image.asset(
                                            'assets/pieces/$piece.png',
                                            fit: BoxFit.contain,
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 40),

              // Evaluation and Controls
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildEvaluationBar(),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Text(
                      '${currentEval > 0 ? '+' : ''}${currentEval.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: currentEval > 0.5
                            ? Colors.green[700]
                            : currentEval < -0.5
                            ? Colors.red[700]
                            : Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: isEngineThinking ? null : _getEngineMove,
                    icon: const Icon(Icons.psychology),
                    label: const Text('Engine Move'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  OutlinedButton.icon(
                    onPressed: isEngineThinking
                        ? null
                        : () {
                            final fen = boardToFen();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: SelectableText('FEN: $fen'),
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          },
                    icon: const Icon(Icons.copy_all),
                    label: const Text('Copy FEN'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCoordinateLabel(int row, int col) {
    if (row == 7) return String.fromCharCode('a'.codeUnitAt(0) + col);
    if (col == 7) return '${8 - row}';
    return '';
  }
}
