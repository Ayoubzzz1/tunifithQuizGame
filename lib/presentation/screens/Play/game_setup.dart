import 'package:flutter/material.dart';
import 'slider.dart';
import 'theme_questions_screen.dart';
import 'game_logic.dart';
import 'theme_selection.dart';
import 'dart:ui';

class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> with SingleTickerProviderStateMixin {
  int _numTeams = 2;
  int _numRounds = 10;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  // Background decoration elements
  final List<Map<String, dynamic>> _bgElements = List.generate(
    15,
        (index) => {
      'size': 10.0 + (index % 5) * 6.0,
      'posX': index * 25.0,
      'posY': (index * 35) % 700,
      'opacity': 0.05 + (index % 10) * 0.01,
    },
  );

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Method to get the selected themes from the ThemeSelectionManager
  List<String> _getSelectedThemes() {
    return ThemeSelectionManager.getSelectedThemes();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final primaryColor = Theme.of(context).primaryColor;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Game Setup',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20 * textScale,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: primaryColor.withOpacity(0.3),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Animated background elements
          ...List.generate(_bgElements.length, (index) {
            final element = _bgElements[index];
            return Positioned(
              left: element['posX'],
              top: element['posY'],
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animationController.value * 0.05 * index,
                    child: Opacity(
                      opacity: element['opacity'],
                      child: Container(
                        width: element['size'],
                        height: element['size'],
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(element['size'] / 2),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),

          // Main gradient background
          Container(
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
          ),

          // Glassmorphism card effect
          SafeArea(
            child: FadeTransition(
              opacity: _fadeInAnimation,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: screenHeight * 0.01),

                      // Header with settings icon
                      _buildHeaderSection(screenWidth),

                      SizedBox(height: screenHeight * 0.03),

                      // Settings card with glassmorphism effect
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: EdgeInsets.all(screenWidth * 0.04),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.7),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Team selection section
                                _buildTeamSelection(screenWidth),

                                Divider(
                                  color: primaryColor.withOpacity(0.2),
                                  thickness: 1,
                                  height: screenHeight * 0.03,
                                ),

                                // Rounds selection section
                                _buildRoundSelection(screenWidth),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.025),

                      // Theme questions button (animated on press)
                      _buildThemeQuestionsButton(context, primaryColor),

                      SizedBox(height: screenHeight * 0.025),

                      // Animated start game button
                      _buildStartGameButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            Icons.settings_outlined,
            size: screenWidth * 0.09,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamSelection(double screenWidth) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.groups,
              size: 18,
              color: primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Number of Teams',
              style: TextStyle(
                fontSize: 16 * textScale,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Teams slider
        SliderWithLabels(
          value: _numTeams.toDouble(),
          min: 2,
          max: 6,
          divisions: 4,
          onChanged: (value) {
            setState(() {
              _numTeams = value.round();
            });
          },
        ),

        // Team number indicator chip
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              '$_numTeams Teams',
              style: TextStyle(
                fontSize: 14 * textScale,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoundSelection(double screenWidth) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.repeat,
              size: 18,
              color: primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Number of Rounds',
              style: TextStyle(
                fontSize: 16 * textScale,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Rounds slider
        SliderWithLabels(
          value: _numRounds.toDouble(),
          min: 5,
          max: 20,
          divisions: 3,
          onChanged: (value) {
            int roundedValue = (value / 5).round() * 5;
            setState(() {
              _numRounds = roundedValue;
            });
          },
          showIntermediateLabels: true,
          intermediateValues: [10, 15],
        ),

        // Round number indicator chip
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              '$_numRounds Rounds',
              style: TextStyle(
                fontSize: 14 * textScale,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeQuestionsButton(BuildContext context, Color primaryColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ThemeQuestionsScreen(),
            ),
          ).then((_) {
            setState(() {});
          });
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: primaryColor.withOpacity(0.1),
        highlightColor: primaryColor.withOpacity(0.05),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.9),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.help_outline,
                  size: 18,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Theme Questions',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_getSelectedThemes().length} selected',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                color: primaryColor.withOpacity(0.7),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartGameButton(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (value * 0.05),
          child: child,
        );
      },
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GameScreen(
                numTeams: _numTeams,
                numRounds: _numRounds,
                selectedThemes: _getSelectedThemes(),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00A36C),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          shadowColor: const Color(0xFF00A36C).withOpacity(0.5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Subtle animated glow
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Container(
                  width: double.infinity,
                  height: 20,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2 * value),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                );
              },
            ),
            // Button content
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated play icon
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: const Icon(Icons.play_arrow, size: 24),
                    );
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  'START GAME',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}