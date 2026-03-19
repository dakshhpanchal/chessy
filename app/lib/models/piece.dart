enum PieceType { pawn, knight, bishop, rook, queen, king }
enum PieceColor { white, black }

class Piece {
  final PieceType type;
  final PieceColor color;

  const Piece(this.type, this.color);

  factory Piece.fromCode(String code) {
    if (code.isEmpty) throw ArgumentError('Empty piece code');
    
    final color = code[0] == 'w' ? PieceColor.white : PieceColor.black;
    final type = _typeFromChar(code[1]);
    return Piece(type, color);
  }

  static PieceType _typeFromChar(String char) {
    switch (char) {
      case 'p': return PieceType.pawn;
      case 'n': return PieceType.knight;
      case 'b': return PieceType.bishop;
      case 'r': return PieceType.rook;
      case 'q': return PieceType.queen;
      case 'k': return PieceType.king;
      default: throw ArgumentError('Invalid piece type: $char');
    }
  }

  String toCode() {
    final colorChar = color == PieceColor.white ? 'w' : 'b';
    final typeChar = _typeToChar(type);
    return '$colorChar$typeChar';
  }

  String _typeToChar(PieceType type) {
    switch (type) {
      case PieceType.pawn: return 'p';
      case PieceType.knight: return 'n';
      case PieceType.bishop: return 'b';
      case PieceType.rook: return 'r';
      case PieceType.queen: return 'q';
      case PieceType.king: return 'k';
    }
  }

  String get assetPath => 'assets/pieces/${toCode()}.png';

  bool get isWhite => color == PieceColor.white;
  bool get isBlack => color == PieceColor.black;
}
