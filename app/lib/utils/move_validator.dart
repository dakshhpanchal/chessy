import '../models/piece.dart';
import '../models/position.dart';

class MoveValidator {
  bool isValidMove(
    List<List<Piece?>> board,
    int fromR,
    int fromC,
    int toR,
    int toC,
  ) {
    final piece = board[fromR][fromC];
    if (piece == null) return false;

    // Can't move to same square
    if (fromR == toR && fromC == toC) return false;

    // Check if target square has piece of same color
    final targetPiece = board[toR][toC];
    if (targetPiece != null && targetPiece.color == piece.color) return false;

    // Validate based on piece type
    switch (piece.type) {
      case PieceType.pawn:
        return _isValidPawnMove(board, fromR, fromC, toR, toC, piece.isWhite);
      case PieceType.knight:
        return _isValidKnightMove(fromR, fromC, toR, toC);
      case PieceType.bishop:
        return _isValidBishopMove(board, fromR, fromC, toR, toC);
      case PieceType.rook:
        return _isValidRookMove(board, fromR, fromC, toR, toC);
      case PieceType.queen:
        return _isValidQueenMove(board, fromR, fromC, toR, toC);
      case PieceType.king:
        return _isValidKingMove(fromR, fromC, toR, toC);
    }
  }

  bool _isValidPawnMove(
    List<List<Piece?>> board,
    int fromR,
    int fromC,
    int toR,
    int toC,
    bool isWhite,
  ) {
    final direction = isWhite ? -1 : 1;
    final startRow = isWhite ? 6 : 1;
    final targetPiece = board[toR][toC];

    // Move forward one square
    if (fromC == toC && toR == fromR + direction && targetPiece == null) {
      return true;
    }

    // Move forward two squares from start
    if (fromC == toC &&
        fromR == startRow &&
        toR == fromR + 2 * direction &&
        targetPiece == null &&
        board[fromR + direction][fromC] == null) {
      return true;
    }

    // Capture diagonally
    if ((toC == fromC + 1 || toC == fromC - 1) &&
        toR == fromR + direction &&
        targetPiece != null) {
      return true;
    }

    return false;
  }

  bool _isValidKnightMove(int fromR, int fromC, int toR, int toC) {
    final rowDiff = (fromR - toR).abs();
    final colDiff = (fromC - toC).abs();

    return (colDiff == 2 && rowDiff == 1) || (colDiff == 1 && rowDiff == 2);
  }

  bool _isValidBishopMove(
    List<List<Piece?>> board,
    int fromR,
    int fromC,
    int toR,
    int toC,
  ) {
    final rowDiff = (fromR - toR).abs();
    final colDiff = (fromC - toC).abs();

    if (rowDiff != colDiff) return false;

    final rowStep = toR > fromR ? 1 : -1;
    final colStep = toC > fromC ? 1 : -1;

    var currentR = fromR + rowStep;
    var currentC = fromC + colStep;

    while (currentR != toR && currentC != toC) {
      if (board[currentR][currentC] != null) {
        return false;
      }
      currentR += rowStep;
      currentC += colStep;
    }

    return true;
  }

  bool _isValidRookMove(
    List<List<Piece?>> board,
    int fromR,
    int fromC,
    int toR,
    int toC,
  ) {
    if (fromR != toR && fromC != toC) return false;

    if (fromR == toR) {
      final step = toC > fromC ? 1 : -1;
      var currentC = fromC + step;
      while (currentC != toC) {
        if (board[fromR][currentC] != null) {
          return false;
        }
        currentC += step;
      }
    } else {
      final step = toR > fromR ? 1 : -1;
      var currentR = fromR + step;
      while (currentR != toR) {
        if (board[currentR][fromC] != null) {
          return false;
        }
        currentR += step;
      }
    }

    return true;
  }

  bool _isValidQueenMove(
    List<List<Piece?>> board,
    int fromR,
    int fromC,
    int toR,
    int toC,
  ) {
    return _isValidBishopMove(board, fromR, fromC, toR, toC) ||
        _isValidRookMove(board, fromR, fromC, toR, toC);
  }

  bool _isValidKingMove(int fromR, int fromC, int toR, int toC) {
    final rowDiff = (toR - fromR).abs();
    final colDiff = (toC - fromC).abs();

    return rowDiff <= 1 && colDiff <= 1;
  }
}
