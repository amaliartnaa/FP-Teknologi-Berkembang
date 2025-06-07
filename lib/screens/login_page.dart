// login_page.dart

import 'package:flutter/material.dart';
import 'register_page.dart';
import '../screens/home_page.dart';
import '../main.dart'; 

class LoginPage extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const LoginPage({super.key, required this.themeNotifier});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    try {
      // PERBAIKAN: Langsung panggil method tanpa menyimpan ke variabel
      MyApp.users.firstWhere(
        (user) => user.email == email && user.password == password,
      );

      // Jika pengguna ditemukan, lanjutkan ke HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              HomePage(themeNotifier: widget.themeNotifier),
        ),
      );
    } catch (e) {
      // Jika tidak ditemukan (firstWhere akan error), tampilkan pesan gagal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login gagal. Periksa email/password.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email')),
            TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _login, child: const Text('Login')),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RegisterPage(
                        themeNotifier: widget.themeNotifier),
                  ),
                );
              },
              child: const Text('Belum punya akun? Daftar di sini'),
            )
          ],
        ),
      ),
    );
  }
}