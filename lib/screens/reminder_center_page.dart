// lib/screens/reminder_center_page.dart (Lengkap & Diperbaiki)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_crud_app/models/note.dart';
import 'package:notes_crud_app/screens/note_detail_page.dart';
import 'package:notes_crud_app/services/firestore_service.dart';

class ReminderCenterPage extends StatelessWidget {
  // Constructor sekarang tidak butuh parameter
  const ReminderCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusat Pengingat'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('notes')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildEmptyState();
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allNotes = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Note.fromMap({...data, 'id': doc.id});
          }).toList();

          final notesWithReminders = allNotes
              .where((note) =>
                  note.reminder != null &&
                  note.reminder!.isAfter(DateTime.now()) &&
                  !note.isTrashed &&
                  !note.isArchived)
              .toList();

          notesWithReminders
              .sort((a, b) => a.reminder!.compareTo(b.reminder!));

          if (notesWithReminders.isEmpty) {
            return _buildEmptyState();
          }

          return _buildRemindersList(context, notesWithReminders);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Belum ada pengingat aktif',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Atur pengingat pada catatanmu!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersList(BuildContext context, List<Note> notes) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: Icon(
              Icons.notifications_active,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(note.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              'Due: ${DateFormat('EEE, d MMM yyyy - h:mm a').format(note.reminder!)}',
            ),
            trailing: Chip(label: Text(note.tag)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteDetailPage(note: note),
                ),
              );
            },
          ),
        );
      },
    );
  }
}