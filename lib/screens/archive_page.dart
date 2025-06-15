import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_crud_app/models/note.dart';
import 'package:notes_crud_app/screens/app_drawer.dart';
import 'package:notes_crud_app/services/firestore_service.dart';

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
  final FirestoreService _firestoreService = FirestoreService();

  void _unarchiveNote(Note note) {
    note.isArchived = false;
    _firestoreService.updateNote(note);
  }

  void _deleteNotePermanently(Note note) {
    _firestoreService.deleteNote(note.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archived Notes'),
      ),
      drawer: AppDrawer(
        themeNotifier: widget.themeNotifier, allNotes: const [],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('notes')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allNotes = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Note.fromMap({...data, 'id': doc.id});
          }).toList();

          final archivedNotes = allNotes
              .where((note) => note.isArchived && !note.isTrashed)
              .toList();

          if (archivedNotes.isEmpty) {
            return const Center(
              child: Text(
                'No archived notes.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: archivedNotes.length,
            itemBuilder: (context, index) {
              final note = archivedNotes[index];
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
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
