import 'package:flutter/material.dart';
import 'package:notes_crud_app/screens/archive_page.dart';
import 'package:notes_crud_app/screens/home_page.dart';
import 'package:notes_crud_app/screens/reminder_center_page.dart';
import 'package:notes_crud_app/screens/settings_page.dart';
import 'package:notes_crud_app/screens/stats_page.dart';
import 'package:notes_crud_app/screens/trash_page.dart';
import 'package:notes_crud_app/screens/reminder_center_page.dart';
import 'package:notes_crud_app/models/note.dart';

class AppDrawer extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  final List<Note> allNotes;

  const AppDrawer({
    super.key,
    required this.themeNotifier,
    required this.allNotes,
  });

  @override
  Widget build(BuildContext context) {
    final bool isHomePage = ModalRoute.of(context)?.settings.name == '/';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade300,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icon_sicatat.png',
                  height: 60,
                ),
                const SizedBox(height: 8),
                const Text(
                  'SiCatat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              if (isHomePage) {
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
          
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Reminder Center'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReminderCenterPage(allNotes: allNotes),
                ),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.archive),
            title: const Text('Archive'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
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
              Navigator.pop(context);
              Navigator.push(
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
              Navigator.pop(context);
              Navigator.push(
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
              Navigator.pop(context);
              Navigator.push(
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
