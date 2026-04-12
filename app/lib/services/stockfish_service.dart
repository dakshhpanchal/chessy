import 'dart:async';
import 'dart:convert';
import 'dart:io';

class StockfishService {
  Process? _process;
  StreamSubscription<String>? _listener;

  final _outputController = StreamController<String>.broadcast();

  Stream<String> get output => _outputController.stream;

  Future<void> start() async {
    _process = await Process.start(
      '/usr/games/stockfish',
      [],
    );

    _listener = _process!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
      _outputController.add(line);
    });

    send('uci');
  }

  void send(String command) {
    _process?.stdin.writeln(command);
  }

  void stop() {
    send('quit');
    _listener?.cancel();
    _process?.kill();
  }
}