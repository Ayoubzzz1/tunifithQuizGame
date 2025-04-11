import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'game_over_screen.dart';
import 'timer_score_display.dart';
import 'question_display.dart';
import 'suggestions_list.dart';
import 'action_button.dart';
import 'game_question.dart';
import 'suggestion.dart';
import 'game_setup.dart';
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
                : Column(
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

                // Suggestions
                Expanded(
                  child: SuggestionsList(
                    suggestions: _currentSuggestions,
                    isTimerRunning: _isTimerRunning,
                    showResults: _showResults,
                    onSuggestionSelected: _selectSuggestion,
                  ),
                ),

                const SizedBox(height: 16),

                // Action button
                ActionButton(
                  isTimerRunning: _isTimerRunning,
                  showResults: _showResults,
                  currentTeam: _currentTeam,
                  numTeams: widget.numTeams,
                  onStartTurn: _startTimer,
                  onEndTurn: _endTurn,
                  onNextTurn: _nextTurn,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}