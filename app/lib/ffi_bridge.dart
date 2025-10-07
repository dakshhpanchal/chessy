import 'dart:ffi';
import 'dart:io';

typedef c_add_func = Int32 Function(Int32 a, Int32 b);

typedef dart_add_func = int Function(int a, int b);

DynamicLibrary _openLibrary() {
  if (Platform.isAndroid) {
    return DynamicLibrary.open('libchess_engine.so');
  } else if (Platform.isWindows) {
    return DynamicLibrary.open('chess_engine.dll');
  } else if (Platform.isMacOS) {
    return DynamicLibrary.open('libchess_engine.dylib');
  } else if (Platform.isLinux) {
    return DynamicLibrary.open('libengine.so');
  } else {
    throw UnsupportedError('This platform is not supported');
  }
}

final DynamicLibrary _lib = _openLibrary();

final dart_add_func addNumbers = _lib
    .lookup<NativeFunction<c_add_func>>('add_numbers')
    .asFunction();
