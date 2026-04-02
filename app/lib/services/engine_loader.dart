import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class EngineLoader {
  static final EngineLoader _instance = EngineLoader._internal();
  factory EngineLoader() => _instance;
  EngineLoader._internal();

  ffi.DynamicLibrary? _library;
  late int Function(ffi.Pointer<ffi.Char>) evaluatePosition;
  bool get isLoaded => _library != null;

  Future<bool> loadEngine() async {
    try {
      if (kIsWeb) {
        debugPrint('Web platform: Engine not supported yet');
        return false;
      }

      // Skip engine loading if we're in a build environment without proper toolchain
      if (Platform.isLinux && !await _hasLinuxBuildTools()) {
        debugPrint('Linux build tools not available, skipping engine load');
        return false;
      }

      final enginePath = await _getEnginePath();
      if (enginePath == null) {
        debugPrint('Engine not found');
        return false;
      }

      _library = ffi.DynamicLibrary.open(enginePath);
      
      final evalFunction = _library!.lookup<
        ffi.NativeFunction<ffi.Int32 Function(ffi.Pointer<ffi.Char>)>
      >('eval');

      evaluatePosition = evalFunction.asFunction<int Function(ffi.Pointer<ffi.Char>)>();
      
      debugPrint('Engine loaded successfully from: $enginePath');
      return true;
    } catch (e) {
      debugPrint('Failed to load engine: $e');
      return false;
    }
  }

  Future<bool> _hasLinuxBuildTools() async {
    try {
      // Check if linker is available
      final result = await Process.run('which', ['ld']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  Future<String?> _getEnginePath() async {
    try {
      if (Platform.isAndroid) {
        // On Android, engine might be in assets or downloaded
        return 'libengine.so';
      } else if (Platform.isIOS) {
        return 'libengine.dylib';
      } else if (Platform.isMacOS) {
        return 'libengine.dylib';
      } else if (Platform.isLinux) {
        // Try multiple possible locations for Linux
        final paths = [
          'libengine.so',
          './libengine.so',
          '/usr/local/lib/libengine.so',
          '/usr/lib/libengine.so',
        ];
        
        for (final path in paths) {
          if (await File(path).exists()) {
            return path;
          }
        }
        return null;
      } else if (Platform.isWindows) {
        return 'engine.dll';
      }
    } catch (e) {
      debugPrint('Error getting engine path: $e');
    }
    return null;
  }

  Future<String?> downloadEngine({required String url}) async {
    // Implementation for downloading engine after installation
    // This would use http and file services
    return null;
  }
}
