import 'package:flutter/material.dart';
import 'slider.dart';
import 'theme_questions_screen.dart';
import 'game_logic.dart';
import 'theme_selection.dart';

class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  int _numTeams = 2;
  int _numRounds = 10;

  List<String> _getSelectedThemes() {
    return ThemeSelectionManager.getSelectedThemes();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: const Text(
          'Game Setup',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(

        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor.withOpacity(0.9),
              Colors.white,
            ],
            stops: const [0.15, 0.3],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : screenWidth * 0.06,
              vertical: 16,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with animated icon
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(18),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      size: isSmallScreen ? 36 : 48,
                      color: theme.primaryColor,
                    ),
                  ),

                  // Number of teams section
                  _buildSectionHeader(
                    context,
                    'Number of Teams',
                    Icons.groups,
                  ),
                  const SizedBox(height: 12),

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
                  const SizedBox(height: 8),

                  _buildValueDisplay(
                    context,
                    '$_numTeams Teams',
                    Icons.groups,
                    isSmallScreen,
                  ),
                  const SizedBox(height: 32),

                  // Number of rounds section
                  _buildSectionHeader(
                    context,
                    'Number of Rounds',
                    Icons.repeat,
                  ),
                  const SizedBox(height: 12),

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
                  const SizedBox(height: 8),

                  _buildValueDisplay(
                    context,
                    '$_numRounds Rounds',
                    Icons.repeat,
                    isSmallScreen,
                  ),
                  const SizedBox(height: 32),

                  // Theme Questions button
                  _buildThemeButton(context, isSmallScreen),
                  const SizedBox(height: 32),

                  // Start game button
                  _buildStartButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 22,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildValueDisplay(
      BuildContext context, String text, IconData icon, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: isSmallScreen ? 22 : 24,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeButton(BuildContext context, bool isSmallScreen) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ThemeQuestionsScreen(),
          ),
        ).then((_) {
          setState(() {});
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.category_rounded,
                size: 22,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Theme Questions',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_getSelectedThemes().length} selected',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return ElevatedButton(
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
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 4,
        shadowColor: Colors.green[800],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.play_arrow_rounded, size: 26),
          SizedBox(width: 10),
          Text(
            'START GAME',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}