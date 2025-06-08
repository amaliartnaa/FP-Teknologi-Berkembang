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
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';

    Widget buildTile({
      required IconData icon,
      required String title,
      required String routeName,
      required VoidCallback onTap,
    }) {
      final isSelected = currentRoute == routeName;

      return ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          title,
          style: const TextStyle(color: Colors.black),
        ),
        tileColor: isSelected ? const Color(0xFFE0D7FF) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
      );
    }

    return Drawer(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: <Widget>[
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Hi, Ratna Amalia!',
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 30),
          buildTile(
            icon: Icons.home,
            title: 'Home',
            routeName: '/',
            onTap: () {
              if (currentRoute == '/') {
                Navigator.pop(context);
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(themeNotifier: themeNotifier),
                    settings: const RouteSettings(name: '/'),
                  ),
                      (route) => false,
                );
              }
            },
          ),
          buildTile(
            icon: Icons.notifications_active_outlined,
            title: 'Pusat Pengingat',
            routeName: '/reminder',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReminderCenterPage(
                    allNotes: HomePage.notes,
                  ),
                  settings: const RouteSettings(name: '/reminder'),
                ),
              );
            },
          ),
          buildTile(
            icon: Icons.archive,
            title: 'Archive',
            routeName: '/archive',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArchivePage(themeNotifier: themeNotifier),
                  settings: const RouteSettings(name: '/archive'),
                ),
              );
            },
          ),
          buildTile(
            icon: Icons.delete,
            title: 'Trash',
            routeName: '/trash',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrashPage(themeNotifier: themeNotifier),
                  settings: const RouteSettings(name: '/trash'),
                ),
              );
            },
          ),
          buildTile(
            icon: Icons.pie_chart,
            title: 'Statistics',
            routeName: '/stats',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatsPage(themeNotifier: themeNotifier),
                  settings: const RouteSettings(name: '/stats'),
                ),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(),
          ),
          buildTile(
            icon: Icons.settings,
            title: 'Settings',
            routeName: '/settings',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(themeNotifier: themeNotifier),
                  settings: const RouteSettings(name: '/settings'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}