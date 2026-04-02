import '../models/game_state.dart';
import '../models/piece.dart';

class FenConverter {
  static String boardToFen(GameState state) {
    final rows = <String>[];
    
    for (var r = 0; r < 8; r++) {
      var emptyCount = 0;
      var rowStr = '';
      
      for (var c = 0; c < 8; c++) {
        final piece = state.board[r][c];
        
        if (piece == null) {
          emptyCount++;
        } else {
          if (emptyCount > 0) {
            rowStr += '$emptyCount';
            emptyCount = 0;
          }
          rowStr += _pieceToFenChar(piece);
        }
      }
      
      if (emptyCount > 0) {
        rowStr += '$emptyCount';
      }
      
      rows.add(rowStr);
    }

    final turnChar = state.currentTurn == PieceColor.white ? 'w' : 'b';
    return '${rows.join('/')} $turnChar KQkq - 0 1';
  }

  static String _pieceToFenChar(Piece piece) {
    final map = {
      PieceType.pawn: 'p',
      PieceType.knight: 'n',
      PieceType.bishop: 'b',
      PieceType.rook: 'r',
      PieceType.queen: 'q',
      PieceType.king: 'k',
    };
    
    final ch = map[piece.type]!;
    return piece.isWhite ? ch.toUpperCase() : ch;
  }

  static void fenToBoard(String fen, GameState state) {
    // Implementation for loading FEN string into board
    // This would parse the FEN and update the game state
    final parts = fen.split(' ');
    if (parts.isEmpty) return;
    
    final boardPart = parts[0];
    final rows = boardPart.split('/');
    
    for (var r = 0; r < 8; r++) {
      var c = 0;
      for (var i = 0; i < rows[r].length; i++) {
        final char = rows[r][i];
        if (int.tryParse(char) != null) {
          final emptyCount = int.parse(char);
          for (var j = 0; j < emptyCount; j++) {
            state.board[r][c + j] = null;
          }
          c += emptyCount;
        } else {
          state.board[r][c] = _fenCharToPiece(char);
          c++;
        }
      }
    }
    
    if (parts.length > 1) {
      state.currentTurn = parts[1] == 'w' ? PieceColor.white : PieceColor.black;
    }
    
    state.notifyListeners();
  }

  static Piece _fenCharToPiece(String char) {
    final isWhite = char.toUpperCase() == char;
    final typeChar = char.toLowerCase();
    
    PieceType type;
    switch (typeChar) {
      case 'p': type = PieceType.pawn; break;
      case 'n': type = PieceType.knight; break;
      case 'b': type = PieceType.bishop; break;
      case 'r': type = PieceType.rook; break;
      case 'q': type = PieceType.queen; break;
      case 'k': type = PieceType.king; break;
      default: throw ArgumentError('Invalid FEN character: $char');
    }
    
    return Piece(type, isWhite ? PieceColor.white : PieceColor.black);
  }
}
