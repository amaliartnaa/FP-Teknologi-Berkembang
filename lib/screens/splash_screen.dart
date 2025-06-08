import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notes_crud_app/screens/login_page.dart';

class SplashScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  const SplashScreen({super.key, required this.themeNotifier});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LoginPage(themeNotifier: widget.themeNotifier),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon_sicatat.png',
              height: 120.0,
            ),
            const SizedBox(height: 16),
            const Text(
              'SiCatat',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}