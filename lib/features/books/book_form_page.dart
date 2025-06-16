import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bookcrossing_app/core/services/image_upload_service.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/book_service.dart';
import '../../core/models/book_model.dart';

class BookFormPage extends StatefulWidget {
  final String currentUserId;
  final BookService bookService;
  final BookModel? bookToEdit;

  const BookFormPage({
    super.key,
    required this.currentUserId,
    required this.bookService,
    this.bookToEdit,
  });

  @override
  State<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends State<BookFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _cities = [
    'Москва',
    'Санкт-Петербург',
    'Новосибирск',
    'Екатеринбург',
    'Россия',
  ];
  String _genre = 'Fiction';
  String _condition = 'Good';
  String _city = 'Россия';
  File? _image;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    final book = widget.bookToEdit;
    if (book != null) {
      _titleController.text = book.title;
      _authorController.text = book.author;
      _descriptionController.text = book.description;
      _genre = book.genre;
      _condition = book.condition;
      _existingImageUrl = book.imageUrl;
      _city = book.city ?? 'Россия';
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    String? imageUrl = _existingImageUrl;
    if (_image != null) {
      imageUrl = await ImageUploadService().uploadImageToImgBB(_image!);
    }

    final book =
        (widget.bookToEdit != null)
            ? widget.bookToEdit!.copyWith(
              title: _titleController.text,
              author: _authorController.text,
              genre: _genre,
              condition: _condition,
              description: _descriptionController.text,
              imageUrl: imageUrl,
              isAvailable: widget.bookToEdit!.isAvailable,
              city: _city,
            )
            : BookModel(
              id: UniqueKey().toString(),
              ownerId: widget.currentUserId,
              title: _titleController.text,
              author: _authorController.text,
              description: _descriptionController.text,
              imageUrl: imageUrl,
              genre: _genre,
              condition: _condition,
              createdAt: DateTime.now(),
              isAvailable: true,
              city: _city,
            );

    if (widget.bookToEdit != null) {
      await widget.bookService.updateBook(book);
    } else {
      await widget.bookService.addBook(book);
    }

    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    if (widget.bookToEdit != null) {
      await widget.bookService.deleteBook(widget.bookToEdit!.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.bookToEdit != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Book' : 'Add Book')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) => value!.isEmpty ? 'Enter title' : null,
                ),
                TextFormField(
                  controller: _authorController,
                  decoration: const InputDecoration(labelText: 'Author'),
                  validator: (value) => value!.isEmpty ? 'Enter author' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 4,
                ),
                DropdownButtonFormField<String>(
                  value: _city,
                  items:
                      _cities
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => _city = value!),
                  decoration: const InputDecoration(labelText: 'Город'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _genre,
                  items:
                      ['Fiction', 'Non-fiction', 'Sci-fi', 'Fantasy']
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => _genre = value!),
                  decoration: const InputDecoration(labelText: 'Genre'),
                ),
                DropdownButtonFormField<String>(
                  value: _condition,
                  items:
                      ['New', 'Good', 'Used']
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => _condition = value!),
                  decoration: const InputDecoration(labelText: 'Condition'),
                ),
                const SizedBox(height: 10),
                _image != null
                    ? Image.file(_image!, height: 100)
                    : (_existingImageUrl != null)
                    ? Image.network(_existingImageUrl!, height: 100)
                    : const Text('No image selected'),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Pick Image'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(isEditing ? 'Save Changes' : 'Submit'),
                ),
                if (isEditing)
                  TextButton(
                    onPressed: _delete,
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete Book'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
