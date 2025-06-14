import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_crud_app/models/note.dart';
import 'package:notes_crud_app/screens/app_drawer.dart';
import 'package:notes_crud_app/services/firestore_service.dart';

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
  final FirestoreService _firestoreService = FirestoreService();

  void _restoreNote(Note note) {
    note.isTrashed = false;
    _firestoreService.updateNote(note);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note restored.')));
  }

  void _deleteNotePermanently(Note note) {
    _firestoreService.deleteNote(note.id);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note deleted permanently')));
  }

  void _emptyTrash(List<Note> trashedNotes) {
    for (final note in trashedNotes) {
      _firestoreService.deleteNote(note.id);
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Trash has been emptied')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
        themeNotifier: widget.themeNotifier,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('notes')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allNotes = snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return Note.fromMap({...data, 'id': doc.id});
          }).toList();

          final trashedNotes = allNotes.where((note) => note.isTrashed).toList();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Trash'),
              actions: [
                if (trashedNotes.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_sweep),
                    tooltip: 'Empty Trash',
                    onPressed: () => _showEmptyTrashConfirmation(context, trashedNotes),
                  ),
              ],
            ),
            body: trashedNotes.isEmpty
                ? const Center(
                    child: Text(
                      'Trash is empty.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: trashedNotes.length,
                    itemBuilder: (context, index) {
                      final note = trashedNotes[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(note.title),
                          subtitle: Text(
                            note.subtitle,
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
        },
      ),
    );
  }

  void _showEmptyTrashConfirmation(BuildContext context, List<Note> trashedNotes) {
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
                _emptyTrash(trashedNotes);
              },
            ),
          ],
        );
      },
    );
  }
}