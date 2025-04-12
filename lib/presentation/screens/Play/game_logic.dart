import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:ui';
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

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
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

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _timerController;
  late AnimationController _pageTransitionController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _timerAnimation;

  // Background decoration elements
  final List<Map<String, dynamic>> _decorElements = List.generate(
    12,
        (index) => {
      'size': 8.0 + (index % 5) * 4.0,
      'posX': index * 35.0,
      'posY': (index * 45) % 800,
      'opacity': 0.05 + (index % 10) * 0.01,
      'rotation': index * 0.2,
    },
  );

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeTeamScores();
    _fetchQuestionsFromFirestore();

    // Initialize animation controllers
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );

    _pageTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    // Setup animations
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _timerAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_timerController);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _timerController.dispose();
    _pageTransitionController.dispose();
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
      // Reset and restart page transition animation
      _pageTransitionController.reset();
      _pageTransitionController.forward();
    } else {
      // No more questions - game over
      _showGameOver();
    }
  }

  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
    });

    // Reset and start timer animation
    _timerController.reset();
    _timerController.forward();

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
    _timerController.stop();

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
    final primaryColor = Theme.of(context).primaryColor;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              ),
              child: Text(
                'Round $_currentRound/${widget.numRounds}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              ),
              child: Text(
                'Team $_currentTeam',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: primaryColor.withOpacity(0.3),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: primaryColor,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading Game...',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      )
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor,
              primaryColor.withOpacity(0.8),
              Colors.white.withOpacity(0.9),
            ],
            stops: const [0.0, 0.4, 0.9],
          ),
        ),
        child: Stack(
          children: [
            // Background decoration elements
            ...List.generate(_decorElements.length, (index) {
              final element = _decorElements[index];
              return Positioned(
                left: element['posX'],
                top: element['posY'],
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: element['rotation'] + (_pulseController.value * 0.05),
                      child: Opacity(
                        opacity: element['opacity'],
                        child: Container(
                          width: element['size'],
                          height: element['size'],
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(element['size'] / 2),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),

            // Main Content
            SafeArea(
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _pageTransitionController,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: FadeTransition(
                  opacity: _pageTransitionController,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.04,
                      vertical: screenSize.height * 0.02,
                    ),
                    child: _currentQuestion == null
                        ? Center(
                      child: Text(
                        'No questions available',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 16,
                        ),
                      ),
                    )
                        : Column(
                      children: [
                        // Timer and score display
                        _buildEnhancedTimerScoreDisplay(),

                        SizedBox(height: screenSize.height * 0.025),

                        // Question display
                        _buildEnhancedQuestionDisplay(),

                        SizedBox(height: screenSize.height * 0.02),

                        // Suggestions list
                        Expanded(
                          child: _buildEnhancedSuggestionsList(),
                        ),

                        SizedBox(height: screenSize.height * 0.015),

                        // Action button
                        _buildEnhancedActionButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedTimerScoreDisplay() {
    final primaryColor = Theme.of(context).primaryColor;

    return Card(
      elevation: 0,
      color: Colors.transparent,
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Timer section - now circular
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(4),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.withOpacity(0.1),
                    ),
                  ),
                  // Progress circle
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      value: _timeRemaining / 60,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _timeRemaining > 10 ? Colors.green : Colors.red,
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                  // Timer text
                  Text(
                    '$_timeRemaining',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _isTimerRunning && _timeRemaining <= 10
                          ? Colors.red
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Score section
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 18,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: Text(
                      '$_teamScore pts',
                      key: ValueKey<int>(_teamScore),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildEnhancedQuestionDisplay() {
    if (_currentQuestion == null) return const SizedBox();

    final primaryColor = Theme.of(context).primaryColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _currentQuestion!.theme,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Question text
              Text(
                _currentQuestion!.question,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedSuggestionsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          itemCount: _currentSuggestions.length,
          itemBuilder: (context, index) {
            final suggestion = _currentSuggestions[index];
            final isSelected = suggestion.selected;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: MaterialButton(
                padding: EdgeInsets.zero,
                onPressed: _isTimerRunning && !_showResults
                    ? () => _selectSuggestion(index)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.5)
                          : Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Suggestion text only (no selection indicator)
                      Expanded(
                        child: Text(
                          suggestion.text,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),

                      // Score value
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${suggestion.value}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  Widget _buildEnhancedActionButton() {
    // Button text and color based on game state
    String buttonText;
    Color buttonColor;
    IconData buttonIcon;
    VoidCallback onPressed;

    if (!_isTimerRunning && !_showResults) {
      // Start turn button
      buttonText = "START TURN";
      buttonColor = Colors.green[600]!;
      buttonIcon = Icons.play_arrow;
      onPressed = _startTimer;
    } else if (_isTimerRunning) {
      // End turn button
      buttonText = "END TURN";
      buttonColor = Colors.red[600]!;
      buttonIcon = Icons.stop;
      onPressed = _endTurn;
    } else {
      // Next turn button
      buttonText = _currentTeam < widget.numTeams ? "NEXT TEAM" : "NEXT ROUND";
      buttonColor = Colors.blue[600]!;
      buttonIcon = _currentTeam < widget.numTeams ? Icons.group : Icons.refresh;
      onPressed = _nextTurn;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.95, end: 1.0),
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        height: 44,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              buttonColor,
              buttonColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.white.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    buttonIcon,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    buttonText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}