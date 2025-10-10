import 'package:flutter/material.dart';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';

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
  // Board: [row][col], 0..7 (row 0 = rank 8, row 7 = rank 1)
  late List<List<String>> board;

  // selected square as row,col or null
  Pair<int, int>? selected;

  // Chess engine FFI
  late ffi.DynamicLibrary dylib;
  late ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>) returnMove;

  @override
  void initState() {
    super.initState();
    board = _initialBoard();
    _precachePieces();
    _loadEngine();
  }

  void _loadEngine() {
    try {
      // Load the engine library
      if (Platform.isAndroid || Platform.isLinux) {
        dylib = ffi.DynamicLibrary.open('libengine.so');
      } else if (Platform.isIOS || Platform.isMacOS) {
        dylib = ffi.DynamicLibrary.open('libengine.dylib');
      } else if (Platform.isWindows) {
        dylib = ffi.DynamicLibrary.open('engine.dll');
      } else {
        throw UnsupportedError('Platform not supported');
      }

      // Bind the return_move function
      returnMove = dylib
          .lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>>('return_move')
          .asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>();
    } catch (e) {
      debugPrint('Failed to load chess engine: $e');
    }
  }

  List<List<String>> _initialBoard() {
    // Fixed board orientation: White on bottom (rows 6-7), Black on top (rows 0-1)
    return [
      ['br','bn','bb','bq','bk','bb','bn','br'], // Rank 8
      ['bp','bp','bp','bp','bp','bp','bp','bp'], // Rank 7
      ['','','','','','','',''],                   // Rank 6
      ['','','','','','','',''],                   // Rank 5
      ['','','','','','','',''],                   // Rank 4
      ['','','','','','','',''],                   // Rank 3
      ['wp','wp','wp','wp','wp','wp','wp','wp'], // Rank 2
      ['wr','wn','wb','wq','wk','wb','wn','wr'], // Rank 1
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

  Future<void> _getEngineMove() async {
    try {
      final fen = boardToFen();
      
      // Convert Dart string to C string
      final fenPointer = fen.toNativeUtf8().cast<ffi.Char>();
      
      // Call the engine
      final resultPointer = returnMove(fenPointer);
      
      // Convert C string back to Dart string
      final moveString = resultPointer.cast<Utf8>().toDartString();
      
      // Free the input string
      malloc.free(fenPointer);
      
      // Display the engine's move
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Engine suggests: $moveString'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      // Optionally, parse and apply the move
      _applyEngineMove(moveString);
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Engine error: $e')),
        );
      }
    }
  }

  void _applyEngineMove(String move) {
    // Parse UCI move format (e.g., "e2e4" or algebraic notation)
    // This is a simple parser - adjust based on your engine's output format
    if (move.length >= 4) {
      try {
        // Assuming UCI format: e2e4
        final fromFile = move[0].codeUnitAt(0) - 'a'.codeUnitAt(0);
        final fromRank = 8 - int.parse(move[1]);
        final toFile = move[2].codeUnitAt(0) - 'a'.codeUnitAt(0);
        final toRank = 8 - int.parse(move[3]);
        
        setState(() {
          board[toRank][toFile] = board[fromRank][fromFile];
          board[fromRank][fromFile] = '';
        });
      } catch (e) {
        debugPrint('Failed to parse move: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Chessboard — Engine'),
        actions: [
          IconButton(
            tooltip: 'Get Engine Move',
            onPressed: _getEngineMove,
            icon: const Icon(Icons.psychology),
          ),
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
