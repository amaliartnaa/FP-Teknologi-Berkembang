import 'package:flutter/material.dart';
import 'package:notes_crud_app/models/note.dart';
import 'package:notes_crud_app/screens/app_drawer.dart'; // <-- Perbaikan di sini
import 'package:notes_crud_app/screens/home_page.dart';

class TrashPage extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const TrashPage({
    super.key,
    required this.themeNotifier,
  });

  @override
  State<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  List<Note> get _trashedNotes =>
      HomePage.notes.where((note) => note.isTrashed).toList();

  void _restoreNote(Note note) {
    setState(() {
      final index = HomePage.notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        HomePage.notes[index].isTrashed = false;
      }
    });
  }

  void _deleteNotePermanently(Note note) {
    setState(() {
      HomePage.notes.removeWhere((n) => n.id == note.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note deleted permanently')));
  }

  void _emptyTrash() {
    setState(() {
      HomePage.notes.removeWhere((note) => note.isTrashed);
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Trash has been emptied')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        actions: [
          if (_trashedNotes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Empty Trash',
              onPressed: () => _showEmptyTrashConfirmation(context),
            ),
        ],
      ),
      drawer: AppDrawer(
        themeNotifier: widget.themeNotifier,
      ),
      body: _trashedNotes.isEmpty
          ? const Center(
              child: Text(
                'Trash is empty.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _trashedNotes.length,
              itemBuilder: (context, index) {
                final note = _trashedNotes[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(note.title),
                    subtitle: Text(
                      note.subtitle, // Menampilkan subtitle
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'restore') {
                          _restoreNote(note);
                        } else if (value == 'delete') {
                          _deleteNotePermanently(note);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'restore',
                          child: Text('Restore'),
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

  void _showEmptyTrashConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Empty Trash?'),
          content: const Text(
              'All notes in the trash will be permanently deleted. This action cannot be undone.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Empty Trash',
                  style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.pop(context);
                _emptyTrash();
              },
            ),
          ],
        );
      },
    );
  }
}