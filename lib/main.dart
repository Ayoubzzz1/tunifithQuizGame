import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize music service
    try {
      final musicService = MusicService();
      await musicService.initializeMusic();

      bool isMusicEnabled = true; // Default to true
      if (isMusicEnabled) {
        await musicService.playMusic();
      }
    } catch (e) {
      print('Music initialization error: $e');
    }

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
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
