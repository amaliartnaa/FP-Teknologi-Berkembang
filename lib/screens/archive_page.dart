import 'package:flutter/material.dart';
import '../models/note.dart';
import 'app_drawer.dart';
import 'home_page.dart';

class ArchivePage extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const ArchivePage({
    super.key,
    required this.themeNotifier,
  });

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  List<Note> get _archivedNotes =>
      HomePage.notes.where((note) => note.isArchived && !note.isTrashed).toList();

  void _unarchiveNote(Note note) {
    setState(() {
      final index = HomePage.notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        HomePage.notes[index].isArchived = false;
      }
    });
  }

  void _deleteNotePermanently(Note note) {
    setState(() {
      HomePage.notes.removeWhere((n) => n.id == note.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archived Notes'),
      ),
      drawer: AppDrawer(
        themeNotifier: widget.themeNotifier,
      ),
      body: _archivedNotes.isEmpty
          ? const Center(
              child: Text(
                'No archived notes.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _archivedNotes.length,
              itemBuilder: (context, index) {
                final note = _archivedNotes[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(note.title),
                    subtitle: Text(
                      note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'unarchive') {
                          _unarchiveNote(note);
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(context, note);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'unarchive',
                          child: Text('Unarchive'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete Permanently',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Note Permanently?'),
          content:
              const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child:
                  const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.pop(context);
                _deleteNotePermanently(note);
              },
            ),
          ],
        );
      },
    );
  }
}