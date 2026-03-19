class AppConstants {
  static const String appName = 'Chess Master';
  static const String appVersion = '1.0.0';
  
  static const int boardSize = 8;
  
  static const Map<String, String> pieceImages = {
    'wp': 'assets/pieces/wp.png',
    'wn': 'assets/pieces/wn.png',
    'wb': 'assets/pieces/wb.png',
    'wr': 'assets/pieces/wr.png',
    'wq': 'assets/pieces/wq.png',
    'wk': 'assets/pieces/wk.png',
    'bp': 'assets/pieces/bp.png',
    'bn': 'assets/pieces/bn.png',
    'bb': 'assets/pieces/bb.png',
    'br': 'assets/pieces/br.png',
    'bq': 'assets/pieces/bq.png',
    'bk': 'assets/pieces/bk.png',
  };

  static const Map<String, String> engineUrls = {
    'android': 'https://example.com/engines/stockfish_android.so',
    'ios': 'https://example.com/engines/stockfish_ios.dylib',
    'windows': 'https://example.com/engines/stockfish_win.dll',
    'macos': 'https://example.com/engines/stockfish_mac.dylib',
    'linux': 'https://example.com/engines/stockfish_linux.so',
  };
}
