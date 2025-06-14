// lib/screens/stats_page.dart (Lengkap & Diperbaiki)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes_crud_app/models/note.dart';
import 'package:notes_crud_app/screens/app_drawer.dart';
import 'package:notes_crud_app/services/firestore_service.dart';

class StatsPage extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const StatsPage({
    super.key,
    required this.themeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      drawer: AppDrawer(
        themeNotifier: themeNotifier,
      ),
      // Ganti body dengan StreamBuilder
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
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

          // Lakukan kalkulasi di sini
          final int totalNotes = allNotes
              .where((n) => !n.isTrashed && !n.isArchived)
              .length;
          final int archivedNotes =
              allNotes.where((n) => n.isArchived).length;
          final int trashedNotes = allNotes.where((n) => n.isTrashed).length;

          final Map<String, int> tagCounts = {};
          for (final note in allNotes.where((n) => !n.isTrashed)) {
            tagCounts.update(note.tag, (value) => value + 1,
                ifAbsent: () => 1);
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildStatCard(
                context,
                icon: Icons.note,
                title: 'Active Notes',
                value: totalNotes.toString(),
                color: Colors.blue,
              ),
              _buildStatCard(
                context,
                icon: Icons.archive,
                title: 'Archived Notes',
                value: archivedNotes.toString(),
                color: Colors.orange,
              ),
              _buildStatCard(
                context,
                icon: Icons.delete,
                title: 'Trashed Notes',
                value: trashedNotes.toString(),
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                'Notes per Tag',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Divider(),
              if (tagCounts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('No tags found.'),
                )
              else
                ...tagCounts.entries.map((entry) {
                  return ListTile(
                    leading: const Icon(Icons.local_offer_outlined),
                    title: Text(entry.key),
                    trailing: Text(
                      entry.value.toString(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String value,
      required Color color}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(value, style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}