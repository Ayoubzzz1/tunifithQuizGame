import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Multiple animation controllers for complex effects
  late AnimationController _mainController;
  late AnimationController _pulsateController;
  late AnimationController _particlesController;

  // Animations
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  // Particles for background effects
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Initialize particles
    for (int i = 0; i < 30; i++) {
      _particles.add(Particle(
        position: Offset(
          _random.nextDouble() * 400 - 200,
          _random.nextDouble() * 800 - 400,
        ),
        size: _random.nextDouble() * 10 + 2,
        speed: _random.nextDouble() * 2 + 0.5,
        angle: _random.nextDouble() * pi * 2,
      ));
    }

    // Main animation controller
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Continuous pulsating effect
    _pulsateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Background particles controller
    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    // Logo scale animation with bouncy effect
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Subtle rotation for extra flair
    _rotateAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    // Continuous pulse animation for logo glow
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(_pulsateController);

    // Text slide-in animation
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Start animations
    _mainController.forward();

    // Navigate to home screen after delay with fade transition
    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulsateController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _particlesController,
        builder: (context, _) {
          // Update particles
          for (var particle in _particles) {
            particle.update(_particlesController.value);
          }

          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF8B0000), // Deep red
                  Color(0xFFB71C1C), // Tunisia red
                  Color(0xFF8B0000), // Deep red
                ],
              ),
            ),
            child: Stack(
              children: [
                // Background moving particles
                ...List.generate(_particles.length, (index) {
                  final particle = _particles[index];
                  return Positioned(
                    left: screenSize.width / 2 + particle.position.dx,
                    top: screenSize.height / 2 + particle.position.dy,
                    child: Opacity(
                      opacity: 0.6,
                      child: Container(
                        width: particle.size,
                        height: particle.size,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.4),
                              blurRadius: particle.size * 0.8,
                              spreadRadius: particle.size * 0.3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Decorative elements
                Positioned(
                  right: -50,
                  top: 100,
                  child: Opacity(
                    opacity: 0.1,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 100,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated logo with shadow and rotation
                      Transform.rotate(
                        angle: _rotateAnimation.value,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  height: 200,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF5252).withOpacity(0.5),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    height: 200,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Game title with slide-in effect
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _mainController,
                          child: const Text(
                            'Tunisia Guess Game',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 3),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),
                      // Subtitle with staggered fade-in
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 1),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _mainController,
                            curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
                          ),
                        ),
                        child: FadeTransition(
                          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _mainController,
                              curve: const Interval(0.4, 0.9),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Test your knowledge about Tunisia',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),
                      // Enhanced loading indicator
                      FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _mainController,
                            curve: const Interval(0.6, 1.0),
                          ),
                        ),
                        child: AnimatedBuilder(
                          animation: _pulsateController,
                          builder: (context, child) {
                            return Container(
                              width: 60,
                              height: 60,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),
                      // Loading text animation
                      FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _mainController,
                            curve: const Interval(0.7, 1.0),
                          ),
                        ),
                        child: _buildLoadingText(),
                      ),
                    ],
                  ),
                ),

                // Stylish corner decoration
                Positioned(
                  bottom: -50,
                  left: -50,
                  child: Opacity(
                    opacity: 0.2,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Animated loading text that changes
  Widget _buildLoadingText() {
    return AnimatedBuilder(
      animation: _pulsateController,
      builder: (context, child) {
        String text;
        if (_pulsateController.value < 0.3) {
          text = "Loading...";
        } else if (_pulsateController.value < 0.6) {
          text = "Preparing questions...";
        } else {
          text = "Get ready!";
        }

        return Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        );
      },
    );
  }
}

// Particle class for background effects
class Particle {
  Offset position;
  double size;
  double speed;
  double angle;

  Particle({
    required this.position,
    required this.size,
    required this.speed,
    required this.angle,
  });

  void update(double animationValue) {
    // Circular motion with outward drift
    final radius = position.distance;
    final newAngle = angle + (speed * 0.02);

    position = Offset(
      radius * cos(newAngle) * (1 + animationValue * 0.1),
      radius * sin(newAngle) * (1 + animationValue * 0.1),
    );

    angle = newAngle;
  }
}