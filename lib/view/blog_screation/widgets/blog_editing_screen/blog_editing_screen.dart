import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:blogapplication/controller/firebase_controller.dart';

class BlogEditScreen extends StatefulWidget {
  final String blogId;
  final String title;
  final String content;
  final String? existingImageUrl;

  BlogEditScreen({
    required this.blogId,
    required this.title,
    required this.content,
    this.existingImageUrl,
  });

  @override
  _BlogEditScreenState createState() => _BlogEditScreenState();
}

class _BlogEditScreenState extends State<BlogEditScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FirebaseController _firebaseController = FirebaseController();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.title;
    _contentController.text = widget.content;
    _imageUrl = widget.existingImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Blog'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Blog Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Blog Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
              ),
            ),
            SizedBox(height: 20),
            _imageSection(),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _updateBlog,
                child: Text('Update Blog'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageSection() {
    return Column(
      children: [
        _imageFile != null
            ? SizedBox(
                height: 200,
                child: Image.file(
                  _imageFile!,
                  fit: BoxFit.cover,
                ),
              )
            : (_imageUrl != null
                ? SizedBox(
                    height: 200,
                    child: Image.network(
                      _imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Text('No Image Selected')),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: Icon(Icons.photo),
              label: Text('Gallery'),
            ),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: Icon(Icons.camera),
              label: Text('Camera'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateBlog() async {
    String title = _titleController.text;
    String content = _contentController.text;

    if (_imageFile != null) {
      _imageUrl = await _firebaseController.uploadImage(_imageFile!);
    }

    await _firebaseController.updateBlog(
      widget.blogId,
      title,
      content,
      imageUrl: _imageUrl,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Blog Updated: $title'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }
}
