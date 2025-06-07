// app_drawer.dart (FINAL)
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'archive_page.dart';
import 'trash_page.dart';
import 'stats_page.dart';
import 'settings_page.dart';

class AppDrawer extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const AppDrawer({
    super.key,
    required this.themeNotifier,
  });

  @override
  Widget build(BuildContext context) {
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HomePage(themeNotifier: themeNotifier)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.archive),
            title: const Text('Archive'),
            onTap: () {
              Navigator.pushReplacement(
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
              Navigator.pushReplacement(
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
              Navigator.pushReplacement(
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
              Navigator.pushReplacement(
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