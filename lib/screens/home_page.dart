import 'package:flutter/material.dart';
import '../models/note.dart';
import 'add_note_page.dart';
import 'app_drawer.dart';
import 'note_detail_page.dart';

class HomePage extends StatefulWidget {
  static List<Note> notes = [
    Note(
      id: '1',
      title: 'Sample Math Note',
      content: 'This is a sample math note about calculus.',
      tag: 'Math',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Note(
      id: '2',
      title: 'Sample Physics Note',
      content: 'This is a sample physics note about thermodynamics.',
      tag: 'Physics',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Note(
      id: '3',
      title: 'Archived Note Example',
      content: 'This note is archived.',
      tag: 'Chemistry',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isArchived: true,
    ),
  ];

  final ValueNotifier<ThemeMode> themeNotifier;
  const HomePage({super.key, required this.themeNotifier});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> filteredNotes = [];
  String selectedTag = 'All';
  final TextEditingController searchController = TextEditingController();
  Set<String> availableTags = {};
  String sortOrder = 'desc';

  @override
  void initState() {
    super.initState();
    _updateFilteredNotes();
  }

  void _updateFilteredNotes() {
    setState(() {
      List<Note> activeNotes = HomePage.notes
          .where((note) => !note.isArchived && !note.isTrashed)
          .toList();

      List<Note> tagFiltered;
      if (selectedTag == 'All') {
        tagFiltered = activeNotes;
      } else {
        tagFiltered =
            activeNotes.where((note) => note.tag == selectedTag).toList();
      }

      final query = searchController.text.toLowerCase();
      if (query.isEmpty) {
        filteredNotes = tagFiltered;
      } else {
        filteredNotes = tagFiltered
            .where((note) =>
                note.title.toLowerCase().contains(query) ||
                note.content.toLowerCase().contains(query))
            .toList();
      }
      _updateAvailableTags(activeNotes);
      _sortNotes();
    });
  }

  void _updateAvailableTags(List<Note> activeNotes) {
    availableTags = activeNotes.map((note) => note.tag).toSet();
  }

  void _sortNotes() {
    if (sortOrder == 'asc') {
      filteredNotes.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    } else {
      filteredNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
  }

  Future<void> _addOrEditNote(Note? note) async {
    final result = await Navigator.push<Note>(
      context,
      MaterialPageRoute(
        builder: (context) => AddNotePage(note: note),
      ),
    );
    if (result != null) {
      if (note != null) {
        final index = HomePage.notes.indexWhere((n) => n.id == result.id);
        if (index != -1) {
          HomePage.notes[index] = result;
        }
      } else {
        HomePage.notes.add(result);
      }
      _updateFilteredNotes();
    }
  }

  void _moveToTrash(Note note) {
    setState(() {
      note.isTrashed = true;
      _updateFilteredNotes();
    });
    // SnackBar bisa ditambahkan di sini jika perlu
  }

  void _archiveNote(Note note) {
    setState(() {
      note.isArchived = true;
      _updateFilteredNotes();
    });
    // SnackBar bisa ditambahkan di sini jika perlu
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
                  decoration: InputDecoration(
                    hintText: 'Search notes...',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  onChanged: (value) => _updateFilteredNotes(),
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
                          _updateFilteredNotes();
                        });
                      },
                    ),
                    const SizedBox(width: 8.0),
                    ...availableTags.map((tag) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            selected: selectedTag == tag,
                            label: Text(tag),
                            onSelected: (bool selected) {
                              setState(() {
                                selectedTag = tag;
                                _updateFilteredNotes();
                              });
                            },
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                sortOrder = value;
                _sortNotes();
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'desc', child: Text('Sort by Newest')),
              const PopupMenuItem(value: 'asc', child: Text('Sort by Oldest')),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      drawer: AppDrawer(themeNotifier: widget.themeNotifier),
      body: filteredNotes.isEmpty
          ? const Center(
              child: Text("No notes found. Tap '+' to create one!",
                  style: TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
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
                    // --- PERBAIKAN LOGIKA ADA DI SINI ---
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteDetailPage(note: note),
                        ),
                      );

                      // Cek hasil yang dikembalikan dari NoteDetailPage
                      if (result == 'archive') {
                        _archiveNote(note);
                      } else if (result == 'delete') {
                        _moveToTrash(note);
                      } else if (result is Note) {
                        // Ini menangani kasus jika ada perubahan dari halaman edit
                        final index = HomePage.notes.indexWhere((n) => n.id == result.id);
                        if (index != -1) {
                            HomePage.notes[index] = result;
                            _updateFilteredNotes();
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
                leading: const Icon(Icons.archive),
                title: const Text('Archive'),
                onTap: () {
                  Navigator.pop(context);
                  _archiveNote(note);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Move to Trash',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _moveToTrash(note);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}