import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'game_over_screen.dart';
import 'timer_score_display.dart';
import 'question_display.dart';
import 'suggestions_list.dart';
import 'game_question.dart';
import 'suggestion.dart';

class GameScreen extends StatefulWidget {
  final int numTeams;
  final int numRounds;
  final List<String> selectedThemes;

  const GameScreen({
    Key? key,
    required this.numTeams,
    required this.numRounds,
    required this.selectedThemes,
  }) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Game state variables
  int _currentRound = 1;
  int _currentTeam = 1;
  bool _isLoading = true;
  bool _isTimerRunning = false;
  int _timeRemaining = 60;
  int _teamScore = 0;
  List<GameQuestion> _gameQuestions = [];
  GameQuestion? _currentQuestion;
  List<Suggestion> _currentSuggestions = [];
  List<int> _teamScores = [];
  int _questionIndex = 0;
  bool _showResults = false;
  bool _showProgressLine = false;
  bool _isLastTurn = false;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeTeamScores();
    _fetchQuestionsFromFirestore();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeTeamScores() {
    _teamScores = List.generate(widget.numTeams, (index) => 0);
  }

  Future<void> _fetchQuestionsFromFirestore() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance.collection('Quiz').get();
      final List<GameQuestion> allQuestions = [];

      for (var doc in snapshot.docs) {
        final themes = doc.data()['themes'] as List<dynamic>?;

        if (themes != null) {
          for (var themeData in themes) {
            final mainTheme = themeData['main_theme'] as String?;

            // Check if this theme is selected or if "Select All" was chosen
            if (mainTheme != null &&
                (widget.selectedThemes.contains(mainTheme) ||
                    widget.selectedThemes.contains('Select All'))) {

              final questions = themeData['questions'] as List<dynamic>?;

              if (questions != null) {
                for (var questionData in questions) {
                  final questionText = questionData['question'] as String?;
                  final documents = questionData['documents'] as List<dynamic>?;

                  if (questionText != null && documents != null) {
                    final suggestions = documents.map((doc) =>
                        Suggestion(
                          text: doc['suggestion'],
                          value: doc['value'],
                        )
                    ).toList();

                    allQuestions.add(GameQuestion(
                      theme: mainTheme,
                      question: questionText,
                      suggestions: suggestions,
                    ));
                  }
                }
              }
            }
          }
        }
      }

      // Shuffle questions to get random ones
      allQuestions.shuffle();

      // We need numTeams * numRounds questions in total
      final neededQuestions = widget.numTeams * widget.numRounds;

      // Take only the needed questions or all if not enough
      _gameQuestions = allQuestions.take(neededQuestions).toList();

      if (_gameQuestions.isEmpty) {
        // Handle no questions found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No questions found for selected themes')),
        );
      } else {
        // Set first question
        _setCurrentQuestion();
      }
    } catch (e) {
      print('Error fetching questions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading questions: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setCurrentQuestion() {
    if (_questionIndex < _gameQuestions.length) {
      setState(() {
        _currentQuestion = _gameQuestions[_questionIndex];
        _currentSuggestions = List<Suggestion>.from(_currentQuestion?.suggestions ?? []);
        _timeRemaining = 60;
        _teamScore = 0;
        _showResults = false;
        _isTimerRunning = false;
        _showProgressLine = false;

        // Check if this is the last turn in the game
        _isLastTurn = (_currentRound == widget.numRounds && _currentTeam == widget.numTeams);
      });
    } else {
      // No more questions - game over
      _showGameOver();
    }
  }

  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _endTurn();
      }
    });
  }

  void _selectSuggestion(int index) {
    if (!_isTimerRunning || _showResults) return;

    setState(() {
      final suggestion = _currentSuggestions[index];
      suggestion.selected = !suggestion.selected;

      // Update score accordingly
      if (suggestion.selected) {
        _teamScore += suggestion.value;
      } else {
        _teamScore -= suggestion.value;
      }
    });
  }

  void _endTurn() {
    _timer?.cancel();

    setState(() {
      _isTimerRunning = false;
      _showResults = true;

      // Update team score
      _teamScores[_currentTeam - 1] += _teamScore;

      // Show progress line except for the last turn
      _showProgressLine = !_isLastTurn;
    });
  }

  void _nextTurn() {
    // Move to next team or round
    setState(() {
      if (_currentTeam < widget.numTeams) {
        // Next team, same round
        _currentTeam++;
      } else {
        // Next round, first team
        _currentTeam = 1;
        _currentRound++;
      }

      // Next question
      _questionIndex++;
    });

    // Check if game is over
    if (_currentRound > widget.numRounds) {
      _showGameOver();
    } else {
      _setCurrentQuestion();
    }
  }

  void _showGameOver() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GameOverScreen(
          teamScores: _teamScores,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Round $_currentRound/${widget.numRounds} - Team $_currentTeam',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8),
              Colors.white,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _currentQuestion == null
                ? const Center(child: Text('No questions available'))
                : _showProgressLine
                ? _buildProgressLineScreen()
                : _buildGameScreen(),
          ),
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Column(
      children: [
        // Timer and score display
        TimerScoreDisplay(
          timeRemaining: _timeRemaining,
          teamScore: _teamScore,
        ),

        const SizedBox(height: 30),

        // Question
        QuestionDisplay(
          theme: _currentQuestion!.theme,
          question: _currentQuestion!.question,
        ),

        const SizedBox(height: 30),

        // Suggestions - only shown when timer is running or results are shown
        Expanded(
          child: _isTimerRunning || _showResults
              ? SuggestionsList(
            suggestions: _currentSuggestions,
            isTimerRunning: _isTimerRunning,
            showResults: _showResults,
            onSuggestionSelected: _selectSuggestion,
          )
              : const Center(
            child: Text(
              'Press Start to begin the round',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Action buttons - Start or Next Round
        if (!_isTimerRunning && !_showResults)
          Center(
            child: ElevatedButton(
              onPressed: _startTimer,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(60),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'START',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
            ),
          ),

        if (_showResults && _isLastTurn)
          ElevatedButton(
            onPressed: _nextTurn,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text(
              'See Results',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressLineScreen() {
    // Calculate highest score to determine max value for progress indicators
    int highestScore = _teamScores.reduce((a, b) => a > b ? a : b);
    highestScore = highestScore > 0 ? highestScore : 100; // Default max if all scores are 0

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Team Scores',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 40),

        // Team scores with progress bars
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.numTeams,
          itemBuilder: (context, index) {
            final teamNumber = index + 1;
            final teamScore = _teamScores[index];
            final progress = teamScore / highestScore;

            // Highlight current team that just played
            final bool isCurrentTeam = teamNumber == _currentTeam;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Team $teamNumber: $teamScore points',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: isCurrentTeam ? FontWeight.bold : FontWeight.normal,
                        color: isCurrentTeam ? Theme.of(context).primaryColor : Colors.black87,
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      // Background container
                      Container(
                        height: 24,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      // Animated progress container
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: progress),
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.easeOutQuart,
                            builder: (context, value, child) {
                              return Container(
                                height: 24,
                                width: constraints.maxWidth * value,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isCurrentTeam
                                        ? [Theme.of(context).primaryColor, Colors.blue]
                                        : [Colors.blueGrey, Colors.blueGrey.shade300],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: isCurrentTeam
                                      ? [
                                    BoxShadow(
                                      color: Theme.of(context).primaryColor.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                      : null,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 60),

        // Continue button
        ElevatedButton(
          onPressed: _nextTurn,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 8,
            shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
          child: Text(
            _currentTeam < widget.numTeams ? 'Next Team' : 'Next Round',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}