import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/position.dart';
import '../models/piece.dart';
import '../utils/move_validator.dart';
import 'chess_engine_service.dart';

class GameService {
  final MoveValidator _moveValidator = MoveValidator();

  // Fixed: Added GameState parameter
  void handleSquareTap(GameState state, int row, int col) {
    if (state.isEngineThinking) return;

    final piece = state.board[row][col];

    if (state.selectedPosition == null) {
      // Select piece if it's the current player's turn
      if (piece != null && piece.color == state.currentTurn) {
        state.selectedPosition = Position(row, col);
        state.validMoves = _getValidMoves(state, row, col);
        state.notifyListeners();
      }
    } else {
      _handleMove(state, row, col);
    }
  }

  void _handleMove(GameState state, int row, int col) {
    final fromR = state.selectedPosition!.row;
    final fromC = state.selectedPosition!.col;

    // Cancel selection if tapping same square
    if (fromR == row && fromC == col) {
      state.selectedPosition = null;
      state.validMoves = [];
      state.notifyListeners();
      return;
    }

    // Select new piece if it's the same color
    final targetPiece = state.board[row][col];
    if (targetPiece != null && targetPiece.color == state.currentTurn) {
      state.selectedPosition = Position(row, col);
      state.validMoves = _getValidMoves(state, row, col);
      state.notifyListeners();
      return;
    }

    // Try to make a move
    if (_isValidMove(state, fromR, fromC, row, col)) {
      _makeMove(state, fromR, fromC, row, col);
    } else {
      state.selectedPosition = null;
      state.validMoves = [];
      state.notifyListeners();
    }
  }

  void _makeMove(GameState state, int fromR, int fromC, int toR, int toC) {
    // Move piece
    state.board[toR][toC] = state.board[fromR][fromC];
    state.board[fromR][fromC] = null;

    // Clear selection
    state.selectedPosition = null;
    state.validMoves = [];

    // Switch turns
    state.currentTurn = state.currentTurn == PieceColor.white
        ? PieceColor.black
        : PieceColor.white;

    state.notifyListeners();
  }

  List<Position> _getValidMoves(GameState state, int row, int col) {
    final moves = <Position>[];
    for (var r = 0; r < 8; r++) {
      for (var c = 0; c < 8; c++) {
        if (_isValidMove(state, row, col, r, c)) {
          moves.add(Position(r, c));
        }
      }
    }
    return moves;
  }

  bool _isValidMove(GameState state, int fromR, int fromC, int toR, int toC) {
    return _moveValidator.isValidMove(
      state.board,
      fromR,
      fromC,
      toR,
      toC,
    );
  }

  void updateEvaluation(GameState state, ChessEngineService engineService) {
    if (engineService.isAvailable) {
      final eval = engineService.evaluatePosition(state);
      state.evaluation = eval;
      state.notifyListeners();
    }
  }

  void resetGame(GameState state) {
    state.reset();
  }
}
