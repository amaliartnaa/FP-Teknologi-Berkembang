import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

class User {
  final String name;
  final String email;
  final String password;
  User({required this.name, required this.email, required this.password});
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.white,

            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),

            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.deepPurple),
              ),
            ),

            cardTheme: CardThemeData(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.deepPurple.shade400,
              foregroundColor: Colors.white,
            ),

            textTheme: Typography.blackMountainView.copyWith(
              bodyLarge: const TextStyle(fontFamily: 'monospace'),
              bodyMedium: const TextStyle(fontFamily: 'monospace'),
              bodySmall: const TextStyle(fontFamily: 'monospace'),
              titleLarge: const TextStyle(fontFamily: 'monospace'),
              titleMedium: const TextStyle(fontFamily: 'monospace'),
              titleSmall: const TextStyle(fontFamily: 'monospace'),
            ),

            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontFamily: 'monospace'),
              ),
            ),

            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            chipTheme: ChipThemeData(
              labelStyle: const TextStyle(fontFamily: 'monospace', color: Colors.black,),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            textTheme: Typography.blackMountainView.copyWith(
              bodyLarge: const TextStyle(fontFamily: 'monospace'),
              bodyMedium: const TextStyle(fontFamily: 'monospace'),
              bodySmall: const TextStyle(fontFamily: 'monospace'),
              titleLarge: const TextStyle(fontFamily: 'monospace'),
              titleMedium: const TextStyle(fontFamily: 'monospace'),
              titleSmall: const TextStyle(fontFamily: 'monospace'),
            ),

            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontFamily: 'monospace'),
              ),
            ),

            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            chipTheme: ChipThemeData(
              labelStyle: const TextStyle(fontFamily: 'monospace'),
              // backgroundColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          themeMode: currentMode,
          home: SplashScreen(themeNotifier: themeNotifier),
        );
      },
    );
  }
}