import 'package:flutter/material.dart';
import '../Play//game_setup.dart'; // Add this import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _showSocialLinkMessage(String platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening $platform page')),
    );
    // Later you can implement actual link opening after adding url_launcher dependency
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Game logo
                Center(
                  child: Hero(
                    tag: 'logo',
                    child: Image.asset(
                      'assets/images/splash_logo.png',
                      height: 150,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Game title
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
                _buildMenuButton(
                  title: 'Play',
                  icon: Icons.play_circle_filled,
                  onTap: () {
                    // Navigate to the game setup screen
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
                _buildMenuButton(
                  title: 'Rules',
                  icon: Icons.rule,
                  onTap: () {
                    // Navigate to rules screen
                    // Navigator.of(context).pushNamed('/rules');
                  },
                  color: Colors.blue[700]!,
                ),
                const SizedBox(height: 24),
                // Settings button
                _buildMenuButton(
                  title: 'Settings',
                  icon: Icons.settings,
                  onTap: () {
                    // Navigate to settings screen
                    // Navigator.of(context).pushNamed('/settings');
                  },
                  color: Colors.orange[700]!,
                ),
                const Spacer(),
                // Social media links
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        icon: Icons.facebook,
                        color: const Color(0xFF1877F2),
                        onTap: () => _showSocialLinkMessage('Facebook'),
                      ),
                      const SizedBox(width: 24),
                      _buildSocialButton(
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

  Widget _buildMenuButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: color,
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 30,
          color: color,
        ),
      ),
    );
  }
}