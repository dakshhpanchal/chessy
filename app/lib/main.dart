import 'package:flutter/material.dart';
import 'ffi_bridge.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final result = addNumbers(7, 8);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('C++ FFI Test')),
        body: Center(
          child: Text(
            'C++ says: 7 + 8 = $result',
            style: const TextStyle(fontSize: 22),
          ),
        ),
      ),
    );
  }
}
