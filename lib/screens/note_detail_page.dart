import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import 'add_note_page.dart';

class NoteDetailPage extends StatelessWidget {
  final Note note;

  const NoteDetailPage({super.key, required this.note});

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Move to Trash?'),
          content:
              const Text('Are you sure you want to move this note to trash?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, 'delete'); // Return 'delete' string
              },
              child: const Text('Move to Trash',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, MMMM d, y').format(note.updatedAt);
    final formattedTime = DateFormat('h:mm a').format(note.updatedAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: 'Archive',
            onPressed: () {
              Navigator.pop(context, 'archive'); // Return 'archive' string
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNotePage(note: note),
                ),
              );
              if (result != null) {
                if (!context.mounted) return; // <-- PERBAIKAN
                Navigator.pop(context, result); // Return the updated Note object
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Move to Trash',
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              note.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8.0),
            Chip(label: Text(note.tag)),
            const SizedBox(height: 16.0),
            const Divider(),
            const SizedBox(height: 16.0),
            SelectableText(
              note.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Last updated: $formattedDate at $formattedTime',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}