import 'package:flutter/material.dart';

void main() {
  runApp(const ChessApp());
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,    
      title: 'Flutter Chess',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // We will eventually get this from the C++ engine
  final String initialFen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess UI'),
        centerTitle: true,
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2.0),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(4, 4),
                )
              ],
            ),
            child: ChessBoard(fen: initialFen),
          ),
        ),
      ),
    );
  }
}

class ChessBoard extends StatelessWidget {
  final String fen;
  const ChessBoard({required this.fen, super.key});

  @override
  Widget build(BuildContext context) {
    final lightSquareColor = Colors.grey[300]!;
    final darkSquareColor = Colors.brown[600]!;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
      ),
      itemBuilder: (context, index) {
        final row = index ~/ 8;
        final col = index % 8;
        final isLightSquare = (row + col) % 2 == 0;

        return Container(
          color: isLightSquare ? lightSquareColor : darkSquareColor,
          child: Center(
            // We'll render pieces here based on the FEN string later
            child: Text(
              _getPieceForSquare(row, col),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
      itemCount: 64,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  // A very basic FEN parser to place pieces.
  // This should be expanded for a full implementation.
  String _getPieceForSquare(int row, int col) {
    final fenParts = fen.split(' ');
    final boardState = fenParts[0].split('/');
    final fenRow = boardState[row];
    int currentPos = 0;
    for (int i = 0; i < fenRow.length; i++) {
      final char = fenRow[i];
      final isDigit = int.tryParse(char);
      if (isDigit != null) {
        currentPos += isDigit;
      } else {
        if (currentPos == col) {
          return _unicodePieces[char] ?? '';
        }
        currentPos++;
      }
    }
    return '';
  }

  static const Map<String, String> _unicodePieces = {
    'r': '♜', 'n': '♞', 'b': '♝', 'q': '♛', 'k': '♚', 'p': '♟',
    'R': '♖', 'N': '♘', 'B': '♗', 'Q': '♕', 'K': '♔', 'P': '♙',
  };
}


