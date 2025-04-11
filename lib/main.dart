import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 🔥 Firebase core import
import 'firebase_options.dart'; // 🛠️ Auto-generated config

import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/play/game_setup.dart';
import 'presentation/screens/Play/theme_questions_screen.dart'; // Import the theme questions screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // ✅ Firebase initialization
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
        primaryColor: const Color(0xFFB71C1C), // Tunisia red
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB71C1C),
          secondary: const Color(0xFFFFFFFF), // White
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
      },
    );
  }
}
