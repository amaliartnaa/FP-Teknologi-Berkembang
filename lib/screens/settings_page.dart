import 'package:flutter/material.dart';
import '../models/note.dart'; // <-- DITAMBAHKAN: Perbaikan untuk error
import 'app_drawer.dart';

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
          )
        ],
      ),
    );
  }
}