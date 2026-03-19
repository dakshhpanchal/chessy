import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../utils/fen_converter.dart';
import 'engine_loader.dart';

class ChessEngineService {
  final EngineLoader _engineLoader = EngineLoader();
  bool get isAvailable => _engineLoader.isLoaded;

  Future<bool> initialize() async {
    return await _engineLoader.loadEngine();
  }

  double evaluatePosition(GameState state) {
    if (!isAvailable) return 0.0;

    try {
      final fen = FenConverter.boardToFen(state);
      final fenPointer = fen.toNativeUtf8().cast<Char>();
      final eval = _engineLoader.evaluatePosition(fenPointer);
      malloc.free(fenPointer);
      return eval / 100.0;
    } catch (e) {
      debugPrint('Evaluation error: $e');
      return 0.0;
    }
  }

  // This would be expanded with actual engine move calculation
  Future<String?> getBestMove(GameState state) async {
    if (!isAvailable) return null;
    
    // Implementation would call engine's search function
    // For now, return a placeholder
    await Future.delayed(const Duration(seconds: 1));
    return null; // Return UCI move string like "e2e4"
  }
}
