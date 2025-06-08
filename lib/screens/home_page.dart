import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import 'add_note_page.dart';
import 'app_drawer.dart';
import 'note_detail_page.dart';

class HomePage extends StatefulWidget {
  static List<Note> notes = [
    Note(
      id: '1',
      title: 'Sample Math Note',
      subtitle: 'Calculus basics and formulas',
      content: 'This is a sample math note about calculus.',
      tag: 'Math',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Note(
      id: '2',
      title: 'Sample Physics Note',
      subtitle: 'Introduction to Thermodynamics',
      content: 'This is a sample physics note about thermodynamics.',
      tag: 'Physics',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      reminder: DateTime.now().add(const Duration(days: 1)),
    ),
     Note(
      id: '3',
      title: 'Archived Note Example',
      subtitle: 'This subtitle is for the archived note',
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
                note.subtitle.toLowerCase().contains(query))
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
  }

  void _archiveNote(Note note) {
    setState(() {
      note.isArchived = true;
      _updateFilteredNotes();
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
                    hintText: 'Cari catatan...',
                    prefixIcon: Icon(Icons.search),
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
                      label: const Text('All'),
                      selected: selectedTag == 'All',
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
                            label: Text(tag),
                            selected: selectedTag == tag,
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
              child: Text("Tidak ada catatan. Tekan '+' untuk membuat.",
                  style: TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(note.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                          if (note.reminder != null) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.notifications, size: 16, color: Theme.of(context).primaryColor),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat('d MMM, h:mm a').format(note.reminder!),
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    trailing: Chip(
                      label: Text(note.tag),
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer.withAlpha(128),
                      side: BorderSide.none,
                    ),
                    onTap: () async {
                       final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteDetailPage(note: note),
                        ),
                      );

                      if (result == 'archive' || result == 'delete' || result is Note) {
                         _updateFilteredNotes();
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