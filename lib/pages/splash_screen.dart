import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _isTouched = false;
  double _logoOpacity = 0.0;
  double _logoScale = 0.8;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _logoOpacity = 1.0;
        _logoScale = 1.0;
      });
    });
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/main');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToHome,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: _logoOpacity,
                duration: const Duration(seconds: 1),
                child: AnimatedScale(
                  scale: _logoScale,
                  duration: const Duration(seconds: 1),
                  child: Icon(
                    Icons.account_balance_wallet,
                    size: 100,
                    color: Colors.teal.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome to Pocket Tracer',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Touch anywhere to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
