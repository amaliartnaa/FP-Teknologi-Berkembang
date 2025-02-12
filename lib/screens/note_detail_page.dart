import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import 'add_note_page.dart';

class NoteDetailPage extends StatelessWidget {
  final Note note;

  const NoteDetailPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    // Format the updatedAt timestamp
    final formattedDate = DateFormat('EEEE, MMMM d, y').format(note.updatedAt); // Example: "Tuesday, October 10, 2023"
    final formattedTime = DateFormat('h:mm a').format(note.updatedAt); // Example: "10:30 AM"

    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNotePage(note: note),
                ),
              );
              if (result != null) {
                Navigator.pop(context, result); // Return the updated Note object
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete Note'),
                    content: const Text(
                        'Are you sure you want to delete this note?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), // Simplified
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context, 'delete'); // Return 'delete' string
                        },
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red)), // Styled delete button
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Keeps content from overflowing
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8.0),
            Chip(label: Text(note.tag)),
            const SizedBox(height: 16.0),
            Text(note.content),
            const SizedBox(height: 16.0),
            // Display formatted date and time
            Text(
              'Last updated:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              formattedDate,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              formattedTime,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}