// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:blogapplication/view/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PersonalDetailsScreen extends StatefulWidget {
  final String email;

  const PersonalDetailsScreen({Key? key, required this.email})
      : super(key: key);

  @override
  _PersonalDetailsScreenState createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  TextEditingController nameController = TextEditingController();
  XFile? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = selectedImage;
    });
  }

  Future<void> _takePhoto() async {
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = selectedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Complete Your Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                prefixIcon: Icon(Icons.person),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(height: 20),
            _image == null
                ? Text("No Image Selected")
                : Image.file(
                    File(_image!.path),
                    height: 150,
                  ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.camera),
                  label: Text("Take Photo"),
                  onPressed: _takePhoto,
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: Icon(Icons.photo),
                  label: Text("Select from Gallery"),
                  onPressed: _pickImage,
                ),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              child: Text('Save & Continue'),
              onPressed: () {
                // Perform save operation for the name and image.
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
