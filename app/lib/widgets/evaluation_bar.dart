import 'package:flutter/material.dart';

class EvaluationBar extends StatelessWidget {
  final double evaluation;

  const EvaluationBar({super.key, required this.evaluation});

  @override
  Widget build(BuildContext context) {
    double clampedEval = evaluation.clamp(-10.0, 10.0);
    double percentage = (clampedEval + 10.0) / 20.0;

    Color barColor = _getBarColor(evaluation);

    return Container(
      width: 30,
      height: 400,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade800),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.grey.shade700, Colors.white],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: percentage * 400,
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: barColor.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              height: 1,
              width: double.infinity,
              color: Colors.grey.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBarColor(double eval) {
    if (eval > 2.0) return Colors.green[400]!;
    if (eval > 0.5) return Colors.lightGreen;
    if (eval < -2.0) return Colors.red[700]!;
    if (eval < -0.5) return Colors.red[400]!;
    return Colors.grey;
  }
}
