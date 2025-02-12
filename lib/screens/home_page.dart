import 'package:flutter/material.dart';
import '../models/note.dart';
import 'add_note_page.dart';
import 'note_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> notes = [];
  List<Note> filteredNotes = [];
  String selectedTag = 'All';
  TextEditingController searchController = TextEditingController();
  Set<String> availableTags = {'Math', 'Physics', 'Chemistry', 'Biology'};

  @override
  void initState() {
    super.initState();
    // Initialize with sample data (or load from storage)
    notes = [
      Note(
        id: '1',
        title: 'Sample Math Note',
        content: 'This is a sample math note',
        tag: 'Math',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Note(
        id: '2',
        title: 'Sample Physics Note',
        content: 'This is a sample physics note',
        tag: 'Physics',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    filteredNotes = notes;
    _updateAvailableTags();
  }

  void _updateAvailableTags() {
    setState(() {
      availableTags = notes.map((note) => note.tag).toSet();
    });
  }

  void filterNotes(String query) {
    setState(() {
      final lowerCaseQuery = query.toLowerCase(); // Store lowercase query

      if (selectedTag == 'All') {
        filteredNotes = notes
            .where((note) =>
                note.title.toLowerCase().contains(lowerCaseQuery) ||
                note.content.toLowerCase().contains(lowerCaseQuery))
            .toList();
      } else {
        filteredNotes = notes
            .where((note) =>
                note.tag == selectedTag &&
                (note.title.toLowerCase().contains(lowerCaseQuery) ||
                    note.content.toLowerCase().contains(lowerCaseQuery)))
            .toList();
      }
    });
  }

  Future<void> _addOrEditNote(Note? note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNotePage(note: note),
      ),
    );

    if (result != null && result is Note) {
      setState(() {
        if (note != null) {
          // Editing existing note
          final index = notes.indexWhere((n) => n.id == note.id);
          if (index != -1) {
            notes[index] = result;
          }
        } else {
          // Adding new note
          result.id = DateTime.now().toString(); // Simple ID generation
          notes.add(result);
        }
        _updateAvailableTags(); // Update available tags
        filterNotes(searchController.text);
      });
    }
  }

  Future<void> _deleteNote(Note note) async {
    setState(() {
      notes.removeWhere((n) => n.id == note.id);
      _updateAvailableTags(); // Update available tags after deletion
      if (!availableTags.contains(selectedTag) && selectedTag != 'All') {
        selectedTag =
            'All'; // Reset to 'All' if the selected tag no longer exists
      }
      filterNotes(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('College Notes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search notes...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) =>
                      filterNotes(value), // Directly call filterNotes
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    FilterChip(
                      selected: selectedTag == 'All',
                      label: const Text('All'),
                      onSelected: (bool selected) {
                        setState(() {
                          selectedTag = 'All';
                          filterNotes(searchController.text);
                        });
                      },
                    ),
                    const SizedBox(width: 8.0),
                    ...availableTags
                        .map((tag) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                selected: selectedTag == tag,
                                label: Text(tag),
                                onSelected: (bool selected) {
                                  setState(() {
                                    selectedTag = tag;
                                    filterNotes(searchController.text);
                                  });
                                },
                              ),
                            ))
                        .toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredNotes.length,
        itemBuilder: (context, index) {
          final note = filteredNotes[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(note.title),
              subtitle: Text(
                note.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Chip(label: Text(note.tag)),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteDetailPage(note: note),
                  ),
                );

                if (result != null) {
                  if (result == 'delete') {
                    _deleteNote(note);
                  } else if (result is Note) {
                    setState(() {
                      final index = notes.indexWhere((n) => n.id == result.id);
                      if (index != -1) {
                        notes[index] = result;
                        _updateAvailableTags();
                        filterNotes(searchController.text);
                      }
                    });
                  }
                }
              },
              onLongPress: () => _showNoteOptions(context, note),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNote(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showNoteOptions(BuildContext context, Note note) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _addOrEditNote(note);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Note'),
                        content: const Text(
                            'Are you sure you want to delete this note?'),
                        actions: [
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            child: const Text('Delete',
                                style: TextStyle(color: Colors.red)),
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteNote(note);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
