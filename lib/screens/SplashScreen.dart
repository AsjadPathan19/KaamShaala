import 'dart:async';
import 'package:flutter/material.dart';
import 'package:work/services/auth_service.dart';

/// A splash screen that displays when the app starts
/// Shows the app logo and tagline for 2 seconds before navigating to the appropriate screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // Use Future.delayed instead of Timer for better performance
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_authService.currentUser != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with fade and slide animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Image.asset(
                      'assets/blue_color_job.jpeg',
                      height: 200,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // App name with fade animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    "KaamShaala",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Tagline with fade animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    "Kaam Milna Hua Aasaan",
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 40),
                // Loading indicator
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
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
