import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/play/game_setup.dart';
import 'presentation/screens/Play/theme_questions_screen.dart';
import 'presentation/screens/Play/music_service.dart'; // 🎶 Import your music service
import 'presentation/screens/Play/seetings.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Check if app has crashed repeatedly
    final prefs = await SharedPreferences.getInstance();
    int crashCount = prefs.getInt('crash_count') ?? 0;

    if (crashCount > 3) {
      // Reset all preferences if app crashed multiple times
      await prefs.clear();
      await prefs.setInt('crash_count', 0);
      print('Reset app due to multiple crashes');
    } else {
      // Increment crash counter (we'll reset it after successful load)
      await prefs.setInt('crash_count', crashCount + 1);
    }

    // Continue with Firebase and music initialization
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize music service with try-catch
    try {
      final musicService = MusicService();
      await musicService.initializeMusic();

      bool isMusicEnabled = prefs.getBool('isMusicEnabled') ?? true;
      if (isMusicEnabled) {
        await musicService.playMusic();
      }
    } catch (e) {
      print('Music initialization error: $e');
    }

    // Mark successful app start by resetting crash counter
    await prefs.setInt('crash_count', 0);

  } catch (e) {
    print('Initialization error: $e');
  }

  runApp(const TunisiaGuessGame());
}
class TunisiaGuessGame extends StatelessWidget {
  const TunisiaGuessGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tunisia Guess Game',
      theme: ThemeData(
        primaryColor: const Color(0xFFB71C1C),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB71C1C),
          secondary: const Color(0xFFFFFFFF),
        ),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/game_setup': (context) => const GameSetupScreen(),
        '/theme_questions': (context) => const ThemeQuestionsScreen(),
        '/settings': (context) => const SettingsScreen(), // Add settings route
      },
    );
  }
}