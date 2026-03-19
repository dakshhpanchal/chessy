import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../services/engine_loader.dart';

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
      // Get the appropriate engine URL based on platform
      final engineUrl = _getEngineDownloadUrl();
      
      final response = await http.get(Uri.parse(engineUrl));
      if (response.statusCode == 200) {
        final dir = await getApplicationSupportDirectory();
        final engineFile = File('${dir.path}/${_getEngineFileName()}');
        await engineFile.writeAsBytes(response.bodyBytes);
        
        // Verify the download
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),
          Center(
            child: Icon(
              Icons.settings,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Chess Engine',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        _isEngineInstalled ? Icons.check_circle : Icons.error,
                        color: _isEngineInstalled ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isEngineInstalled
                              ? 'Engine is installed and ready'
                              : 'Engine not installed',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  if (_isDownloading) ...[
                    const SizedBox(height: 16),
                    LinearProgressIndicator(value: _downloadProgress),
                    const SizedBox(height: 8),
                    Text('Downloading... ${(_downloadProgress * 100).toInt()}%'),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isDownloading ? null : _downloadEngine,
                    icon: const Icon(Icons.download),
                    label: Text(_isEngineInstalled ? 'Reinstall Engine' : 'Install Engine'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'About',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.info),
                    title: Text('Version'),
                    subtitle: Text('1.0.0'),
                  ),
                  const Divider(),
                  const ListTile(
                    leading: Icon(Icons.update),
                    title: Text('Last Updated'),
                    subtitle: Text('December 2024'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.code),
                    title: const Text('Open Source'),
                    subtitle: const Text('View on GitHub'),
                    onTap: () {
                      // Open GitHub link
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
