class Note {
  String id;
  String title;
  String subtitle;
  String content;
  String tag;
  DateTime createdAt;
  DateTime updatedAt;
  bool isArchived;
  bool isTrashed;
  DateTime? reminder;
  List<String>? imagePaths;
  List<String>? otherFilePaths;

  Note({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.tag,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
    this.isTrashed = false,
    this.reminder,
    this.imagePaths,
    this.otherFilePaths,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'tag': tag,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isArchived': isArchived,
      'isTrashed': isTrashed,
      'reminder': reminder?.toIso8601String(),
      'imagePaths': imagePaths,
      'otherFilePaths': otherFilePaths,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      subtitle: map['subtitle'] ?? '',
      content: map['content'],
      tag: map['tag'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isArchived: map['isArchived'] ?? false,
      isTrashed: map['isTrashed'] ?? false,
      reminder:
      map['reminder'] != null ? DateTime.parse(map['reminder']) : null,
      imagePaths: map['imagePaths'] != null ? List<String>.from(map['imagePaths']) : null,
      otherFilePaths: map['otherFilePaths'] != null ? List<String>.from(map['otherFilePaths']) : null,
    );
  }
}
