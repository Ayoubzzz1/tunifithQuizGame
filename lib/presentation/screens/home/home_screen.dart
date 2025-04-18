import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../Play/game_setup.dart';
import '../Play/custom_button.dart';
// ... your existing imports
import '../Play/seetings.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();


  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }


  void _showSocialLinkMessage(String platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening $platform page')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 0.6],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Hero(
                    tag: 'logo',
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 150,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                const Center(
                  child: Text(
                    'Tunisia Guess Game',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),

                // Play button
                CustomButton.menu(
                  title: 'Play',
                  icon: Icons.play_circle_filled,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const GameSetupScreen(),
                      ),
                    );
                  },
                  color: Colors.green[700]!,
                ),

                const SizedBox(height: 24),

                // Rules button
                CustomButton.menu(
                  title: 'Rules',
                  icon: Icons.rule,
                  onTap: () {
                    // TODO: Navigate to rules screen
                  },
                  color: Colors.blue[700]!,
                ),

                // Inside your HomeScreen class, update the settings button onTap method:
                const SizedBox(height: 24),
// Settings button
                CustomButton.menu(
                  title: 'Settings',
                  icon: Icons.settings,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  color: Colors.orange[700]!,
                ),

                const SizedBox(height: 24),

                // SoundButton example — new component




                // Social buttons
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton.social(
                        icon: Icons.facebook,
                        color: const Color(0xFF1877F2),
                        onTap: () => _showSocialLinkMessage('Facebook'),
                      ),
                      const SizedBox(width: 24),
                      CustomButton.social(
                        icon: Icons.camera_alt,
                        color: const Color(0xFFE1306C),
                        onTap: () => _showSocialLinkMessage('Instagram'),
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
