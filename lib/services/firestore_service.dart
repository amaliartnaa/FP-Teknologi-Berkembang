import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_crud_app/models/note.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _userNotesCollection {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _db.collection('users').doc(uid).collection('notes');
  }

  Future<DocumentReference> addNote(Note note) {
    return _userNotesCollection.add(note.toMap());
  }

  Stream<QuerySnapshot> getNotesStream() {
    return _userNotesCollection.orderBy('updatedAt', descending: true).snapshots();
  }

  Future<void> updateNote(Note note) {
    return _userNotesCollection.doc(note.id).update(note.toMap());
  }

  Future<void> deleteNote(String noteId) {
    return _userNotesCollection.doc(noteId).delete();
  }
}
