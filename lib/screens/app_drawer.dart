import 'package:flutter/material.dart';
import 'home_page.dart';
import 'archive_page.dart';
import 'trash_page.dart';
import 'stats_page.dart';
import 'settings_page.dart';
import 'reminder_center_page.dart';

class AppDrawer extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const AppDrawer({
    super.key,
    required this.themeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    // Mendeteksi apakah kita sedang di HomePage atau tidak
    final bool isHomePage = ModalRoute.of(context)?.settings.name == '/';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'College Notes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              // Jika sudah di HomePage, cukup tutup drawer
              if (isHomePage) {
                Navigator.pop(context);
              } else {
                // Jika dari halaman lain, kembali ke Home dan hapus tumpukan
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(themeNotifier: themeNotifier),
                    // Beri nama rute agar bisa dideteksi
                    settings: const RouteSettings(name: '/'),
                  ),
                  (route) => false, // Hapus semua rute sebelumnya
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Pusat Pengingat'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              Navigator.push( // Gunakan push, bukan pushReplacement
                context,
                MaterialPageRoute(
                  builder: (context) => ReminderCenterPage(
                    allNotes: HomePage.notes,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.archive),
            title: const Text('Archive'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              Navigator.push( // Gunakan push
                context,
                MaterialPageRoute(
                  builder: (context) => ArchivePage(
                    themeNotifier: themeNotifier,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Trash'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              Navigator.push( // Gunakan push
                context,
                MaterialPageRoute(
                  builder: (context) => TrashPage(
                    themeNotifier: themeNotifier,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.pie_chart),
            title: const Text('Statistics'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              Navigator.push( // Gunakan push
                context,
                MaterialPageRoute(
                  builder: (context) => StatsPage(
                    themeNotifier: themeNotifier,
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              Navigator.push( // Gunakan push
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    themeNotifier: themeNotifier,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}