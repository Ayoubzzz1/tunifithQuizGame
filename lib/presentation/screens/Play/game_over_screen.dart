import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class GameOverScreen extends StatefulWidget {
  final List<int> teamScores;

  const GameOverScreen({Key? key, required this.teamScores}) : super(key: key);

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    WidgetsBinding.instance.addPostFrameCallback((_) => _confettiController.play());
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int highestScore = widget.teamScores.reduce((a, b) => a > b ? a : b);
    final List<int> winningTeams = [];

    for (int i = 0; i < widget.teamScores.length; i++) {
      if (widget.teamScores[i] == highestScore) {
        winningTeams.add(i + 1);
      }
    }

    final bool isTie = winningTeams.length > 1;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1D2671), Color(0xFFC33764)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Hero(
                      tag: "trophy",
                      child: Icon(
                        Icons.emoji_events_rounded,
                        size: 100,
                        color: Colors.amber.shade400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.yellowAccent, Colors.white],
                      ).createShader(bounds),
                      child: const Text(
                        'GAME OVER',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(seconds: 1),
                      child: Text(
                        isTie
                            ? 'It\'s a tie between Teams ${winningTeams.join(' & ')}!'
                            : 'Team ${winningTeams.first} wins!',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ScoresCard(
                      teamScores: widget.teamScores,
                      highestScore: highestScore,
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.replay),
                      label: const Text(
                        'PLAY AGAIN',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 15,
              minBlastForce: 5,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.1,
              colors: const [Colors.green, Colors.orange, Colors.purple, Colors.pink, Colors.blue],
            ),
          ),
        ],
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF1F1F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.groups, color: isWinner ? Colors.green : Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Team $teamNumber',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                  color: isWinner ? Colors.green : Colors.black87,
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (isWinner)
                Icon(Icons.star_rounded, color: Colors.amber.shade600),
              const SizedBox(width: 6),
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isWinner ? Colors.green[800] : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
