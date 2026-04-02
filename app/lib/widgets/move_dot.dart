import 'package:flutter/material.dart';

class MoveDot extends StatelessWidget {
  final bool isCapture;

  const MoveDot({super.key, required this.isCapture});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: isCapture ? 36 : 20,
        height: isCapture ? 36 : 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCapture ? Colors.transparent : Colors.green.withOpacity(0.3),
          border: isCapture
              ? Border.all(
                  color: Colors.red.withOpacity(0.6),
                  width: 3,
                )
              : null,
        ),
      ),
    );
  }
}
