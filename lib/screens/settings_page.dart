import 'package:flutter/material.dart';
import '../models/note.dart';
import 'app_drawer.dart';
import 'login_page.dart'; // <-- DITAMBAHKAN: Untuk mengakses halaman login

class SettingsPage extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  final List<Note> notes;
  final Function(Note) onNoteUpdated;

  const SettingsPage({
    super.key,
    required this.themeNotifier,
    required this.notes,
    required this.onNoteUpdated,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // DITAMBAHKAN: Fungsi untuk menampilkan dialog konfirmasi logout
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
            ),
            TextButton(
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // Pindah ke halaman login dan hapus semua halaman sebelumnya
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginPage(themeNotifier: widget.themeNotifier)),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      drawer: AppDrawer(
        notes: widget.notes,
        onNoteUpdated: widget.onNoteUpdated,
        themeNotifier: widget.themeNotifier,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode),
            value: widget.themeNotifier.value == ThemeMode.dark,
            onChanged: (bool value) {
              setState(() {
                widget.themeNotifier.value =
                    value ? ThemeMode.dark : ThemeMode.light;
              });
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('About'),
            subtitle: Text('College Notes App v1.0'),
            leading: Icon(Icons.info),
          ),
          const Divider(), // <-- DITAMBAHKAN: Garis pemisah
          // DITAMBAHKAN: Menu untuk Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              _showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
    );
  }
}