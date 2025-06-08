// lib/screens/reminder_center_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import 'note_detail_page.dart';

class ReminderCenterPage extends StatefulWidget {
  // Terima daftar semua catatan dari HomePage
  final List<Note> allNotes;

  const ReminderCenterPage({super.key, required this.allNotes});

  @override
  State<ReminderCenterPage> createState() => _ReminderCenterPageState();
}

class _ReminderCenterPageState extends State<ReminderCenterPage> {
  // Buat list baru untuk menampung hasil saringan
  List<Note> _notesWithReminders = [];

  @override
  void initState() {
    super.initState();
    // Saring dan urutkan catatan saat halaman pertama kali dibuka
    _filterAndSortReminders();
  }

  void _filterAndSortReminders() {
    setState(() {
      // Ambil hanya catatan yang punya reminder dan waktunya masih di masa depan
      _notesWithReminders = widget.allNotes
          .where((note) => note.reminder != null && note.reminder!.isAfter(DateTime.now()))
          .toList();

      // Urutkan berdasarkan tanggal reminder terdekat
      _notesWithReminders.sort((a, b) => a.reminder!.compareTo(b.reminder!));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusat Pengingat'),
        centerTitle: true,
      ),
      // Tampilkan UI berbeda tergantung apakah ada pengingat atau tidak
      body: _notesWithReminders.isEmpty
          ? _buildEmptyState() // Tampilkan pesan kosong jika tidak ada reminder
          : _buildRemindersList(), // Tampilkan daftar jika ada reminder
    );
  }

  // Widget untuk tampilan kosong
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Belum ada pengingat aktif',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Atur pengingat pada catatanmu!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan daftar pengingat
  Widget _buildRemindersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _notesWithReminders.length,
      itemBuilder: (context, index) {
        final note = _notesWithReminders[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: Icon(
              Icons.notifications_active,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              // Format tanggal agar mudah dibaca
              'Due: ${DateFormat('EEE, d MMM yyyy - h:mm a').format(note.reminder!)}',
            ),
            trailing: Chip(label: Text(note.tag)),
            onTap: () {
              // Saat diklik, pergi ke halaman detail catatan tersebut
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteDetailPage(note: note),
                ),
              );
            },
          ),
        );
      },
    );
  }
}