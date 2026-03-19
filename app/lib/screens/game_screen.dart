import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/piece.dart';
import '../services/game_service.dart';
import '../services/chess_engine_service.dart';
import '../widgets/chess_board.dart';
import '../widgets/evaluation_bar.dart';
import '../widgets/game_controls.dart';

class GameScreen extends StatefulWidget {
  final String mode;

  const GameScreen({super.key, required this.mode});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameService _gameService;
  late ChessEngineService _engineService;
  bool _isEngineInitialized = false;

  @override
  void initState() {
    super.initState();
    _gameService = GameService();
    _engineService = ChessEngineService();
    _initializeEngine();
  }

  Future<void> _initializeEngine() async {
    final initialized = await _engineService.initialize();
    setState(() {
      _isEngineInitialized = initialized;
    });
    
    if (!initialized && widget.mode != 'offline') {
      _showEngineError();
    }
  }

  void _showEngineError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Engine Not Available'),
          content: const Text(
            'Chess engine could not be loaded. You can still play offline '
            'without engine analysis.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState()..currentMode = _getModeFromString(widget.mode),
      child: Consumer<GameState>(
        builder: (context, state, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_getAppBarTitle(state)),
              backgroundColor: state.currentTurn == PieceColor.white
                  ? Colors.white
                  : Colors.black,
              foregroundColor: state.currentTurn == PieceColor.white
                  ? Colors.black
                  : Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                if (state.isEngineThinking)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: state.isEngineThinking
                      ? null
                      : () {
                          state.reset();
                          _gameService.updateEvaluation(state, _engineService);
                        },
                  tooltip: 'New Game',
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
                    Expanded(
                      flex: 3,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: ChessBoard(gameService: _gameService),
                        ),
                      ),
                    ),

                    const SizedBox(width: 40),

                    // Controls and Evaluation
                    Expanded(
                      flex: 1,
                      child: GameControls(
                        gameService: _gameService,
                        engineService: _engineService,
                        engineAvailable: _isEngineInitialized,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  GameMode _getModeFromString(String mode) {
    switch (mode) {
      case 'offline':
        return GameMode.offline;
      case 'engine':
        return GameMode.engine;
      default:
        return GameMode.offline;
    }
  }

  String _getAppBarTitle(GameState state) {
    if (state.isEngineThinking) return 'Engine Thinking...';
    if (state.status == GameStatus.check) return 'Check!';
    if (state.status == GameStatus.checkmate) return 'Checkmate!';
    if (state.status == GameStatus.stalemate) return 'Stalemate!';
    
    return state.currentTurn == PieceColor.white
        ? "White's Turn"
        : "Black's Turn";
  }
}
