import 'package:flutter/material.dart';
import '../models/note.dart';

class AddNotePage extends StatefulWidget {
  final Note? note;
  const AddNotePage({super.key, this.note});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagController;
  String _selectedTag = '';
  bool _isEditing = false;
  DateTime? _createdAt;
  bool _isArchived = false;
  bool _isTrashed = false;

  final Set<String> _tags = {'Math', 'Physics', 'Chemistry'};

  @override
  void initState() {
    super.initState();
    _isEditing = widget.note != null;
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');
    _tagController = TextEditingController();

    if (_isEditing) {
      _selectedTag = widget.note!.tag;
      _createdAt = widget.note!.createdAt;
      _isArchived = widget.note!.isArchived;
      _isTrashed = widget.note!.isTrashed;
      _tags.add(_selectedTag);
    } else {
      _createdAt = DateTime.now();
      if (_tags.isNotEmpty) {
        _selectedTag = _tags.first;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      final note = Note(
        id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        tag: _selectedTag,
        createdAt: _createdAt!,
        updatedAt: DateTime.now(),
        isArchived: _isArchived,
        isTrashed: _isTrashed,
      );
      Navigator.pop(context, note);
    }
  }

  void _showEditTagDialog(String oldTag) {
    _tagController.text = oldTag;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Tag'),
          content: TextField(
            controller: _tagController,
            decoration: const InputDecoration(
              labelText: 'Tag Name',
              hintText: 'Enter new tag name',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _editTag(oldTag);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editTag(String oldTag) {
    final newTag = _tagController.text.trim();
    if (newTag.isNotEmpty && newTag != oldTag && !_tags.contains(newTag)) {
      setState(() {
        _tags.remove(oldTag);
        _tags.add(newTag);
        if (_selectedTag == oldTag) {
          _selectedTag = newTag;
        }
      });
    }
    _tagController.clear();
  }

  void _showAddTagDialog() {
    _tagController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Tag'),
          content: TextField(
            controller: _tagController,
            decoration: const InputDecoration(
              labelText: 'Tag Name',
              hintText: 'Enter new tag name',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addNewTag();
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addNewTag() {
    final newTag = _tagController.text.trim();
    if (newTag.isNotEmpty && !_tags.contains(newTag)) {
      setState(() {
        _tags.add(newTag);
        _selectedTag = newTag;
      });
    }
    _tagController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Note' : 'Add Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'Enter note title',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.title),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _titleController.clear(),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                if (value.length > 50) {
                  return 'Title should be less than 50 characters';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedTag,
                    decoration: const InputDecoration(
                      labelText: 'Tag',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_offer),
                    ),
                    items: _tags.map((String tag) {
                      return DropdownMenuItem(
                        value: tag,
                        child: Text(tag),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedTag = newValue;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a tag';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                PopupMenuButton<String>(
                  onSelected: (String value) {
                    if (value == 'add') {
                      _showAddTagDialog();
                    } else if (value.startsWith('edit:')) {
                      final oldTag = value.substring(5);
                      _showEditTagDialog(oldTag);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'add',
                        child:
                            Row(children: [Icon(Icons.add), Text('Add Tag')]),
                      ),
                      ..._tags.map((tag) => PopupMenuItem<String>(
                            value: 'edit:$tag',
                            child: Row(children: [
                              const Icon(Icons.edit),
                              Text('Edit $tag')
                            ]),
                          )),
                    ];
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                hintText: 'Enter note content',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 10,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter some content';
                }
                return null;
              },
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 16.0),
            if (_isEditing) ...[
              Text(
                'Created: ${widget.note!.createdAt.toString().split('.')[0]}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Last modified: ${widget.note!.updatedAt.toString().split('.')[0]}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}