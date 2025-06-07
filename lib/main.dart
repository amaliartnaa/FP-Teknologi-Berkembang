// main.dart

import 'package:flutter/material.dart';
import 'screens/login_page.dart';

// DITAMBAHKAN: "Database" sederhana untuk menyimpan pengguna
class User {
  final String email;
  final String password;
  User({required this.email, required this.password});
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // DITAMBAHKAN: List statis untuk menyimpan semua pengguna yang terdaftar
  static List<User> users = [];

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeNotifier,
      builder: (context, ThemeMode currentMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Aplikasi Catatan',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: currentMode,
          home: LoginPage(themeNotifier: themeNotifier),
        );
      },
    );
  }
}