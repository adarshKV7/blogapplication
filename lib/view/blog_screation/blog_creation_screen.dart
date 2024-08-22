import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:blogapplication/controller/firebase_controller.dart';
import 'package:intl/intl.dart';

class BlogCreationScreen extends StatefulWidget {
  @override
  _BlogCreationScreenState createState() => _BlogCreationScreenState();
}

class _BlogCreationScreenState extends State<BlogCreationScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final FirebaseController _firebaseController = FirebaseController();
  final ImagePicker _picker = ImagePicker();

  DateTime? _selectedDate;
  File? _imageFile;
  String? _imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Blog'),
        backgroundColor: Colors.blueAccent,
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Blog Content',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate == null
                      ? 'Select Publish Date'
                      : 'Publish Date: ${DateFormat.yMMMd().format(_selectedDate!)}',
                ),
                ElevatedButton(
                  onPressed: _selectDate,
                  child: Text('Pick Date'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _imageSection(),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _publishBlog,
                child: Text('Publish'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageSection() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _imageFile != null
              ? Image.file(_imageFile!)
              : Text('No Image Selected'),
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
      ),
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

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _publishBlog() async {
    String title = _titleController.text;
    String content = _contentController.text;
    String date = _selectedDate != null
        ? DateFormat.yMMMd().format(_selectedDate!)
        : 'No date selected';

    if (_imageFile != null) {
      _imageUrl = await _firebaseController.uploadImage(_imageFile!);
    }

    await _firebaseController.createBlog(
      title,
      content,
      date,
      imageUrl: _imageUrl,
    );

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Blog Published: $title on $date'),
      backgroundColor: Colors.green,
    ));

    Navigator.pop(context);
  }
}
