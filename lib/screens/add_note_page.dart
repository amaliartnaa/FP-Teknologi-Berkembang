import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_crud_app/models/note.dart';
import 'package:notes_crud_app/screens/set_reminder_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';

class AddNotePage extends StatefulWidget {
  final Note? note;
  const AddNotePage({super.key, this.note});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _contentController;
  late TextEditingController _tagController;
  String _selectedTag = '';
  bool _isEditing = false;
  DateTime? _createdAt;
  bool _isArchived = false;
  bool _isTrashed = false;
  DateTime? _reminder;
  List<String> _imagePaths = [];
  List<String> _otherFilePaths = [];

  final Set<String> _tags = {'Math', 'Physics', 'Chemistry'};

  @override
  void initState() {
    super.initState();
    _isEditing = widget.note != null;
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _subtitleController =
        TextEditingController(text: widget.note?.subtitle ?? '');
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');
    _tagController = TextEditingController();

    if (_isEditing) {
      _selectedTag = widget.note!.tag;
      _createdAt = widget.note!.createdAt;
      _isArchived = widget.note!.isArchived;
      _isTrashed = widget.note!.isTrashed;
      _reminder = widget.note!.reminder;
      _imagePaths = List<String>.from(widget.note!.imagePaths ?? []);
      _otherFilePaths = List<String>.from(widget.note!.otherFilePaths ?? []);
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
    _subtitleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      final note = Note(
        id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        subtitle: _subtitleController.text.trim(),
        content: _contentController.text.trim(),
        tag: _selectedTag,
        createdAt: _createdAt!,
        updatedAt: DateTime.now(),
        isArchived: _isArchived,
        isTrashed: _isTrashed,
        reminder: _reminder,
        imagePaths: _imagePaths,
        otherFilePaths: _otherFilePaths,
      );
      Navigator.pop(context, note);
    }
  }

  Future<void> _navigateToSetReminderPage() async {
    final result = await Navigator.push<DateTime>(
      context,
      MaterialPageRoute(
        builder: (context) => SetReminderPage(initialDate: _reminder),
      ),
    );
    if (mounted && result != null) {
      setState(() {
        _reminder = result;
      });
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

  Future<void> _showAttachmentSourceDialog() async {
    print('Trying to show attachment source dialog...');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Lampiran'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Akses Kamera (Gambar)'),
                onTap: () {
                  print('User selected Camera.');
                  Navigator.pop(context);
                  _pickAndInsertImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Akses Media File (Gambar)'),
                onTap: () {
                  print('User selected Media File (Gallery).');
                  Navigator.pop(context);
                  _pickAndInsertImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Akses File Lain (PDF, DOC, PPTX)'),
                onTap: () {
                  print('User selected Other Files.');
                  Navigator.pop(context);
                  _pickAndInsertOtherFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndInsertImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        try {
          final appDocDir = await getApplicationDocumentsDirectory();
          final String fileName = p.basename(pickedFile.path);
          final String newPath = p.join(appDocDir.path, fileName);

          final File newImage = await File(pickedFile.path).copy(newPath);

          setState(() {
            _imagePaths.add(newImage.path);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gambar berhasil ditambahkan!')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan gambar: $e')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat memilih gambar: $e')),
      );
    }
  }

  Future<void> _pickAndInsertOtherFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        final pickedFile = result.files.single;
        try {
          final appDocDir = await getApplicationDocumentsDirectory();
          final String fileName = pickedFile.name;
          final String newPath = p.join(appDocDir.path, fileName);

          final File newFile = await File(pickedFile.path!).copy(newPath);

          setState(() {
            _otherFilePaths.add(newFile.path);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File ${fileName} berhasil ditambahkan!')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan file: $e')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat memilih file: $e')),
      );
    }
  }

  void _removeImage(String imagePath) {
    setState(() {
      _imagePaths.remove(imagePath);
    });
    print('Image path removed: $imagePath. Current image paths: $_imagePaths');
  }

  void _removeOtherFile(String filePath) {
    setState(() {
      _otherFilePaths.remove(filePath);
    });
    print('File path removed: $filePath. Current other file paths: $_otherFilePaths');
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
              decoration: const InputDecoration(labelText: 'Judul'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Judul tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _subtitleController,
              decoration: const InputDecoration(labelText: 'Sub Judul'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Sub Judul tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedTag,
                    decoration: const InputDecoration(
                      labelText: 'Tag',
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
            const Divider(),
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Atur Pengingat'),
              subtitle: Text(
                _reminder == null
                    ? 'Tidak diatur'
                    : DateFormat('EEE, d MMM y, h:mm a').format(_reminder!),
              ),
              trailing: _reminder != null
                  ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _reminder = null;
                  });
                },
              )
                  : null,
              onTap: _navigateToSetReminderPage,
            ),
            const Divider(),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Konten'),
              maxLines: 10,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Konten tidak boleh kosong';
                }
                return null;
              },
            ),
            if (_imagePaths.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              const Text('Gambar Terlampir:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _imagePaths.map((imagePath) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(
                          File(imagePath),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading image from path: $imagePath');
                            print('Error: $error');
                            print('Stack Trace: $stackTrace');
                            return Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, size: 40),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _removeImage(imagePath),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
            if (_otherFilePaths.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              const Text('File Terlampir:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _otherFilePaths.map((filePath) {
                  final fileName = p.basename(filePath);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.insert_drive_file, color: Colors.blue),
                        const SizedBox(width: 8.0),
                        Expanded(child: Text(fileName)),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red, size: 20),
                          onPressed: () => _removeOtherFile(filePath),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
            if (_isEditing) ...[
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'Created: ${widget.note!.createdAt.toString().split('.')[0]}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Last modified: ${widget.note!.updatedAt.toString().split('.')[0]}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAttachmentSourceDialog,
        mini: true,
        child: const Icon(Icons.attach_file),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
    );
  }
}