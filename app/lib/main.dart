import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'themes/theme_controller.dart';
import 'app.dart';
import 'services/stockfish_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final engine = StockfishService();
  await engine.start();

  engine.output.listen((line) {
    print(line);
  });

  // simple engine test
  engine.send('position startpos');
  engine.send('go depth 10');

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const ChessApp(),
    ),
  );
}