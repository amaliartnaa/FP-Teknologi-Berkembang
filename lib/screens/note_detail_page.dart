import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p; // <-- Impor paket path
import '../models/note.dart';
import 'add_note_page.dart';

class NoteDetailPage extends StatelessWidget {
  final Note note;

  const NoteDetailPage({super.key, required this.note});

  // Fungsi helper untuk memberi warna pada tag, sama seperti di HomePage
  Color _getColorForTag(String tag) {
    final hash = tag.hashCode;
    return Colors.primaries[hash % Colors.primaries.length];
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pindahkan ke Sampah?'),
          content:
              const Text('Anda yakin ingin memindahkan catatan ini ke sampah?'),
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
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN JUDUL DAN TAG ---
            Chip(
              label: Text(
                note.tag,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: _getColorForTag(note.tag).withOpacity(0.8),
              side: BorderSide.none,
            ),
            const SizedBox(height: 16.0),
            SelectableText(
              note.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            if (note.subtitle.isNotEmpty)
              SelectableText(
                note.subtitle,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.grey.shade600),
              ),
            const SizedBox(height: 24.0),
            const Divider(),
            const SizedBox(height: 24.0),

            // --- BAGIAN KONTEN ---
            SelectableText(
              note.content,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16.0),
            
            // =======================================================
            // === AWAL DARI KODE BARU UNTUK MENAMPILKAN LAMPIRAN ===
            // =======================================================

            // --- Tampilkan Gambar Terlampir ---
            if (note.imagePaths != null && note.imagePaths!.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              const Divider(),
              const SizedBox(height: 16.0),
              const Text('Gambar Terlampir:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12.0),
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: note.imagePaths!.map((imagePath) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      File(imagePath),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),
            ],

            // --- Tampilkan File Terlampir Lainnya ---
            if (note.otherFilePaths != null && note.otherFilePaths!.isNotEmpty) ...[
              if (note.imagePaths == null || note.imagePaths!.isEmpty) ... [
                  const SizedBox(height: 16.0),
                  const Divider(),
                  const SizedBox(height: 16.0),
              ],
              const Text('File Terlampir:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: note.otherFilePaths!.map((filePath) {
                  final fileName = p.basename(filePath);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.insert_drive_file, color: Colors.blueGrey),
                        const SizedBox(width: 12.0),
                        Expanded(child: Text(fileName, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),
            ],

            // =====================================================
            // === AKHIR DARI KODE BARU UNTUK MENAMPILKAN LAMPIRAN ===
            // =====================================================


            const Divider(),
            const SizedBox(height: 16.0),

            // --- BAGIAN INFORMASI TAMBAHAN (DI BAWAH) ---
            if (note.reminder != null) ...[
              _buildInfoRow(
                context,
                icon: Icons.notifications_active,
                text: 'Pengingat: ${DateFormat('EEE, d MMM y, h:mm a').format(note.reminder!)}',
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8.0),
            ],
            _buildInfoRow(
              context,
              icon: Icons.calendar_today_outlined,
              text: 'Dibuat: ${DateFormat('d MMM y, h:mm a').format(note.createdAt)}',
            ),
            const SizedBox(height: 8.0),
            _buildInfoRow(
              context,
              icon: Icons.edit_calendar_outlined,
              text: 'Diedit: ${DateFormat('d MMM y, h:mm a').format(note.updatedAt)}',
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk membuat baris info dengan ikon
  Widget _buildInfoRow(BuildContext context, {required IconData icon, required String text, Color? color}) {
    final textColor = color ?? Colors.grey.shade600;
    return Row(
      children: [
        Icon(icon, size: 16, color: textColor),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: textColor, fontSize: 13))),
      ],
    );
  }
}