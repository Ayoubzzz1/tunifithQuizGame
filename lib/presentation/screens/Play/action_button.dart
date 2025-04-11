// components/action_button.dart
import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final bool isTimerRunning;
  final bool showResults;
  final int currentTeam;
  final int numTeams;
  final VoidCallback onStartTurn;
  final VoidCallback onEndTurn;
  final VoidCallback onNextTurn;

  const ActionButton({
    Key? key,
    required this.isTimerRunning,
    required this.showResults,
    required this.currentTeam,
    required this.numTeams,
    required this.onStartTurn,
    required this.onEndTurn,
    required this.onNextTurn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isTimerRunning && !showResults) {
      return ElevatedButton(
        onPressed: onStartTurn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow),
            SizedBox(width: 8),
            Text(
              'START TURN',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else if (isTimerRunning && !showResults) {
      return ElevatedButton(
        onPressed: onEndTurn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[700],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stop),
            SizedBox(width: 8),
            Text(
              'END TURN',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: onNextTurn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.arrow_forward),
            const SizedBox(width: 8),
            Text(
              currentTeam < numTeams
                  ? 'NEXT TEAM'
                  : 'NEXT ROUND',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }
}