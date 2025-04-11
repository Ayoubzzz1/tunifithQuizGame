// components/timer_score_display.dart
import 'package:flutter/material.dart';

class TimerScoreDisplay extends StatelessWidget {
  final int timeRemaining;
  final int teamScore;

  const TimerScoreDisplay({
    Key? key,
    required this.timeRemaining,
    required this.teamScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTimeLow = timeRemaining < 10;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Timer with enhanced styling
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isTimeLow
                ? Colors.red.shade50
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isTimeLow
                    ? Colors.red.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isTimeLow
                  ? Colors.red.withOpacity(0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: isTimeLow ? (1 + (value * 0.2)) : 1,
                    child: child,
                  );
                },
                child: Icon(
                  Icons.timer,
                  color: isTimeLow
                      ? Colors.red
                      : Colors.blueGrey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$timeRemaining s',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isTimeLow
                      ? Colors.red
                      : Colors.blueGrey.shade800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        // Score counter with enhanced styling
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.shade100,
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.2),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.amber, Colors.orange],
                ).createShader(bounds),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$teamScore',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.amber.withOpacity(0.3),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}