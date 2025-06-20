import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_crud_app/services/firestore_service.dart';
import 'package:notes_crud_app/services/notification_service.dart';
import '../models/note.dart';
import 'add_note_page.dart';
import 'app_drawer.dart';
import 'note_detail_page.dart';

class HomePage extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  const HomePage({super.key, required this.themeNotifier});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();

  List<Note> allNotes = [];
  List<Note> filteredNotes = [];
  String selectedTag = 'All';
  final TextEditingController searchController = TextEditingController();
  Set<String> availableTags = {};
  String sortOrder = 'desc';
  bool _isSearching = false;
  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {});
    });
  }

  void _filterAndSortNotes(List<Note> notes) {
    List<Note> activeNotes =
        notes.where((note) => !note.isArchived && !note.isTrashed).toList();

    availableTags = activeNotes.map((note) => note.tag).toSet();

    if (!availableTags.contains(selectedTag) && selectedTag != 'All') {
      selectedTag = 'All';
    }

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

    if (sortOrder == 'asc') {
      filteredNotes.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    } else {
      filteredNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
  }

  Future<void> _addOrEditNote(Note? note) async {
    await Navigator.push<Note>(
      context,
      MaterialPageRoute(
        builder: (context) => AddNotePage(note: note),
      ),
    );
  }

  void _moveToTrash(Note note) {
    // Batalkan notifikasi terlebih dahulu
    final int notificationId = note.id.hashCode;
    NotificationService().cancelNotification(notificationId);
    
    // Baru update status catatan di Firestore
    note.isTrashed = true;
    _firestoreService.updateNote(note);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan dipindahkan ke sampah.')),
    );
  }

  void _archiveNote(Note note) {
    note.isArchived = true;
    _firestoreService.updateNote(note);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan diarsipkan.')),
    );
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
                onChanged: (value) => setState(() {}),
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
      drawer: AppDrawer(themeNotifier: widget.themeNotifier, allNotes: allNotes),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('notes')
            .snapshots(),
          builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          allNotes = snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return Note.fromMap({
              ...data,
              'id': doc.id,
            });
          }).toList();

          _filterAndSortNotes(allNotes);

          if (filteredNotes.isEmpty) {
            return Center(
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
                    "Catatan tidak ditemukan",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Coba kata kunci lain atau buat catatan baru.",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
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
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                            if (note.reminder != null) ...[
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.notifications,
                                      size: 16,
                                      color: Theme.of(context).primaryColor),
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
                        }
                      },
                    ),
                  ),
                ),
              );
            },
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
