import 'package:flutter/material.dart';
import '../models/note.dart';
import 'app_drawer.dart';

class StatsPage extends StatelessWidget {
  final List<Note> notes;
  final Function(Note) onNoteUpdated;
  final ValueNotifier<ThemeMode> themeNotifier;

  const StatsPage({
    super.key,
    required this.notes,
    required this.onNoteUpdated,
    required this.themeNotifier,
  });

  Map<String, int> _getNoteCountByTag() {
    final Map<String, int> tagCount = {};
    for (final note in notes.where((n) => !n.isTrashed)) {
      tagCount.update(note.tag, (value) => value + 1, ifAbsent: () => 1);
    }
    return tagCount;
  }

  @override
  Widget build(BuildContext context) {
    final totalNotes = notes.where((n) => !n.isTrashed && !n.isArchived).length;
    final archivedNotes = notes.where((n) => n.isArchived).length;
    final trashedNotes = notes.where((n) => n.isTrashed).length;
    final tagCounts = _getNoteCountByTag();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      drawer: AppDrawer(
        notes: notes,
        onNoteUpdated: onNoteUpdated,
        themeNotifier: themeNotifier,
      ),
      body: ListView(
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