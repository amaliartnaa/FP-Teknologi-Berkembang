// firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_crud_app/models/note.dart';

class FirestoreService {
  // Membuat referensi ke koleksi 'notes' di Firestore
  final CollectionReference notesCollection =
      FirebaseFirestore.instance.collection('notes');

  // CREATE: Menambahkan note baru
  Future<void> addNote(Note note) {
    return notesCollection.add(note.toMap());
  }

  // READ: Mendapatkan semua notes sebagai stream (untuk data real-time)
  Stream<QuerySnapshot> getNotesStream() {
    return notesCollection.orderBy('updatedAt', descending: true).snapshots();
  }

  // UPDATE: Memperbarui note yang ada
  Future<void> updateNote(Note note) {
    return notesCollection.doc(note.id).update(note.toMap());
  }

  // DELETE: Menghapus note
  Future<void> deleteNote(String noteId) {
    return notesCollection.doc(noteId).delete();
  }
}