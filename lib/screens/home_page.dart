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
      title: 'Rangkuman Kalkulus',
      subtitle: 'Turunan, Integral, dan Limit',
      content: 'Ini adalah konten lengkap dari catatan kalkulus...',
      tag: 'Math',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Note(
      id: '2',
      title: 'Praktikum Fisika Dasar',
      subtitle: 'Membahas tentang Termodinamika',
      content: 'Ini adalah konten lengkap dari catatan fisika...',
      tag: 'Physics',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      reminder: DateTime.now().add(const Duration(days: 1)),
    ),
     Note(
      id: '3',
      title: 'Catatan Arsip Kimia',
      subtitle: 'Tentang senyawa organik',
      content: 'Catatan ini diarsipkan.',
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
  bool _isSearching = false;

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
    note.isTrashed = true;
    _updateFilteredNotes();
  }

  void _archiveNote(Note note) {
    note.isArchived = true;
    _updateFilteredNotes();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Berdasarkan Tag',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: selectedTag == 'All',
                    onSelected: (bool selected) {
                      setState(() {
                        selectedTag = 'All';
                        _updateFilteredNotes();
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ...availableTags.map((tag) => FilterChip(
                        label: Text(tag),
                        selected: selectedTag == tag,
                        onSelected: (bool selected) {
                          setState(() {
                            selectedTag = tag;
                            _updateFilteredNotes();
                          });
                          Navigator.pop(context);
                        },
                      )),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getColorForTag(String tag) {
    final hash = tag.hashCode;
    return Colors.primaries[hash % Colors.primaries.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: _isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Cari catatan...',
                  border: InputBorder.none,
                ),
                onChanged: (value) => _updateFilteredNotes(),
              )
            : const Text('SiCatat'),
        centerTitle: true,
        actions: _isSearching
            ? [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      searchController.clear();
                      _updateFilteredNotes();
                    });
                  },
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterSheet,
                ),
                PopupMenuButton<String>(
                  onSelected: (String value) {
                    setState(() {
                      sortOrder = value;
                      _sortNotes();
                    });
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                        value: 'desc', child: Text('Sort by Newest')),
                    const PopupMenuItem(
                        value: 'asc', child: Text('Sort by Oldest')),
                  ],
                ),
              ],
      ),
      drawer: AppDrawer(themeNotifier: widget.themeNotifier),
      body: filteredNotes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icon_sicatat.png',
                    height: 100,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Catatan masih kosong",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tekan tombol '+' untuk membuat catatan pertamamu.",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                return Dismissible(
                  key: Key(note.id),
                  background: Container(
                    color: Colors.red.shade400,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                    child: const Icon(Icons.delete_sweep, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.orange.shade400,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.archive, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      _archiveNote(note);
                    } else {
                      _moveToTrash(note);
                    }
                  },
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getColorForTag(note.tag).withAlpha(77),
                            _getColorForTag(note.tag).withAlpha(26),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(note.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(note.subtitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              if (note.reminder != null) ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(Icons.notifications,
                                        size: 16,
                                        color:
                                            Theme.of(context).primaryColor),
                                    const SizedBox(width: 6),
                                    Text(
                                      DateFormat('d MMM, h:mm a')
                                          .format(note.reminder!),
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColor,
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
                          label: Text(
                            note.tag,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          backgroundColor:
                              _getColorForTag(note.tag).withAlpha(179),
                          side: BorderSide.none,
                        ),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteDetailPage(note: note),
                            ),
                          );

                          if (result == 'archive') {
                            _archiveNote(note);
                          } else if (result == 'delete') {
                            _moveToTrash(note);
                          } else if (result is Note) {
                            final index = HomePage.notes.indexWhere((n) => n.id == result.id);
                            if (index != -1) {
                              HomePage.notes[index] = result;
                            }
                            _updateFilteredNotes();
                          }
                        },
                      ),
                    ),
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
}