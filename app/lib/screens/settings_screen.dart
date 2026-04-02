import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../services/engine_loader.dart';
import '../themes/theme_controller.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isEngineInstalled = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _checkEngineStatus();
  }

  Future<void> _checkEngineStatus() async {
    final loader = EngineLoader();
    final isLoaded = await loader.loadEngine();
    setState(() {
      _isEngineInstalled = isLoaded;
    });
  }

  Future<void> _downloadEngine() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final engineUrl = _getEngineDownloadUrl();
      final response = await http.get(Uri.parse(engineUrl));

      if (response.statusCode == 200) {
        final dir = await getApplicationSupportDirectory();
        final engineFile = File('${dir.path}/${_getEngineFileName()}');
        await engineFile.writeAsBytes(response.bodyBytes);

        if (await engineFile.exists()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Engine downloaded successfully!')),
          );
          await _checkEngineStatus();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  String _getEngineDownloadUrl() {
    if (Platform.isAndroid) return 'https://example.com/engines/stockfish_android.so';
    if (Platform.isIOS) return 'https://example.com/engines/stockfish_ios.dylib';
    if (Platform.isWindows) return 'https://example.com/engines/stockfish_win.dll';
    if (Platform.isMacOS) return 'https://example.com/engines/stockfish_mac.dylib';
    if (Platform.isLinux) return 'https://example.com/engines/stockfish_linux.so';
    return '';
  }

  String _getEngineFileName() {
    if (Platform.isAndroid) return 'libengine.so';
    if (Platform.isIOS) return 'libengine.dylib';
    if (Platform.isWindows) return 'engine.dll';
    if (Platform.isMacOS) return 'libengine.dylib';
    if (Platform.isLinux) return 'libengine.so';
    return 'engine';
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDark;

    final fg = isDark ? Colors.white : Colors.black;
    final bg = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("SETTINGS"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),

          // 🔥 THEME TOGGLE
          _sectionTitle("Appearance"),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: () => themeController.toggleTheme(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: fg, width: 1.5),
              ),
              child: Row(
                children: [
                  _toggleOption("LIGHT", !isDark, fg, bg),
                  _toggleOption("DARK", isDark, fg, bg),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // ⚙️ ENGINE
          _sectionTitle("Engine"),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        _isEngineInstalled ? Icons.check : Icons.close,
                        color: _isEngineInstalled ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isEngineInstalled
                              ? 'Engine ready'
                              : 'Not installed',
                        ),
                      ),
                    ],
                  ),

                  if (_isDownloading) ...[
                    const SizedBox(height: 16),
                    LinearProgressIndicator(value: _downloadProgress),
                  ],

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: _isDownloading ? null : _downloadEngine,
                    child: Text(
                      _isEngineInstalled ? "REINSTALL" : "INSTALL",
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // 📦 ABOUT
          _sectionTitle("About"),
          const SizedBox(height: 12),

          Card(
            child: Column(
              children: const [
                ListTile(
                  title: Text("Version"),
                  subtitle: Text("1.0.0"),
                ),
                Divider(),
                ListTile(
                  title: Text("Last Updated"),
                  subtitle: Text("March 2026"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  Widget _toggleOption(String label, bool active, Color fg, Color bg) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? fg : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? bg : fg,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
