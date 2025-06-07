class Note {
  String? id;
  String title;
  String content;
  String tag;
  DateTime createdAt;
  DateTime updatedAt;
  bool isArchived;
  bool isTrashed;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.tag,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
    this.isTrashed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tag': tag,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isArchived': isArchived,
      'isTrashed': isTrashed,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      tag: map['tag'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isArchived: map['isArchived'] ?? false,
      isTrashed: map['isTrashed'] ?? false,
    );
  }
}