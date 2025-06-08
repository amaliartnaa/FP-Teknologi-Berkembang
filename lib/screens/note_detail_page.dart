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
          title: const Text('Pindahkan ke Sampah?'),
          content: const Text('Anda yakin ingin memindahkan catatan ini ke sampah?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, 'delete');
              },
              child: const Text('Pindahkan',
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
        title: const Text('Detail Catatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: 'Archive',
            onPressed: () {
              Navigator.pop(context, 'archive');
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
              if (result != null && context.mounted) {
                Navigator.pop(context, result);
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              note.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 8.0),
            SelectableText(
              note.subtitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16.0),
            Chip(label: Text(note.tag)),
            const SizedBox(height: 16.0),

            if (note.reminder != null) ...[
              Card(
                color: Theme.of(context).primaryColor.withAlpha(26),
                elevation: 0,
                child: ListTile(
                  leading: Icon(Icons.notifications_active, color: Theme.of(context).primaryColor),
                  title: const Text('Pengingat diatur untuk:'),
                  subtitle: Text(
                    DateFormat('EEEE, d MMMM y, h:mm a').format(note.reminder!),
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
            ],

            const Divider(),
            const SizedBox(height: 16.0),
            SelectableText(
              note.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.5),
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