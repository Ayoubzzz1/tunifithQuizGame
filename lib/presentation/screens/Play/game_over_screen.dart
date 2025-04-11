// game_over_screen.dart
import 'package:flutter/material.dart';

class GameOverScreen extends StatelessWidget {
  final List<int> teamScores;

  const GameOverScreen({
    Key? key,
    required this.teamScores,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Find winner(s)
    final int highestScore = teamScores.reduce((a, b) => a > b ? a : b);
    final List<int> winningTeams = [];

    for (int i = 0; i < teamScores.length; i++) {
      if (teamScores[i] == highestScore) {
        winningTeams.add(i + 1);
      }
    }

    final bool isTie = winningTeams.length > 1;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Colors.white,
            ],
            stops: const [0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Trophy icon for winner
                Icon(
                  Icons.emoji_events,
                  size: 100,
                  color: Colors.amber[700],
                ),

                const SizedBox(height: 24),

                // Game over title
                const Text(
                  'GAME OVER',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                // Winner announcement
                Text(
                  isTie
                      ? 'It\'s a tie between Teams ${winningTeams.join(' & ')}!'
                      : 'Team ${winningTeams.first} wins!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Scores card
                ScoresCard(
                  teamScores: teamScores,
                  highestScore: highestScore,
                ),

                const Spacer(),

                // Play again button
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.replay, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'PLAY AGAIN',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ScoresCard extends StatelessWidget {
  final List<int> teamScores;
  final int highestScore;

  const ScoresCard({
    Key? key,
    required this.teamScores,
    required this.highestScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'FINAL SCORES',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(
            teamScores.length,
                (index) => TeamScoreItem(
              teamNumber: index + 1,
              score: teamScores[index],
              isWinner: highestScore == teamScores[index],
            ),
          ),
        ],
      ),
    );
  }
}

class TeamScoreItem extends StatelessWidget {
  final int teamNumber;
  final int score;
  final bool isWinner;

  const TeamScoreItem({
    Key? key,
    required this.teamNumber,
    required this.score,
    required this.isWinner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Team $teamNumber',
            style: TextStyle(
              fontSize: 20,
              fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
              color: isWinner ? Theme.of(context).primaryColor : Colors.black87,
            ),
          ),
          Row(
            children: [
              if (isWinner)
                Icon(
                  Icons.star,
                  color: Colors.amber[700],
                  size: 24,
                ),
              const SizedBox(width: 8),
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isWinner ? Theme.of(context).primaryColor : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}