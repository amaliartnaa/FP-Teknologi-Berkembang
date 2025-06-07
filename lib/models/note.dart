// note.dart (FINAL)
class Note {
  String id; // Diubah dari String? menjadi String
  String title;
  String content;
  String tag;
  DateTime createdAt;
  DateTime updatedAt;
  bool isArchived;
  bool isTrashed;

  Note({
    required this.id, // ID sekarang wajib diisi
    required this.title,
    required this.content,
    required this.tag,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
    this.isTrashed = false,
  });
  
  // ... (Sisa kode toMap dan fromMap tidak perlu diubah)
}