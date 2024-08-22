// image_picker_widget.dart
// ignore_for_file: use_key_in_widget_constructors

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:blogapplication/controller/firebase_controller.dart';

class ImagePickerWidget extends StatelessWidget {
  final String? imageUrl;
  final Function(String?) onImageSelected;

  ImagePickerWidget({this.imageUrl, required this.onImageSelected});

  final FirebaseController _firebaseController = FirebaseController();

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      String? imageUrl =
          await _firebaseController.uploadImage(File(pickedFile.path));
      onImageSelected(imageUrl);
    }
    Navigator.pop(context);
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Pick from Gallery'),
            onTap: () => _pickImage(context, ImageSource.gallery),
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Take a Photo'),
            onTap: () => _pickImage(context, ImageSource.camera),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          imageUrl == null ? 'No image selected' : 'Image selected',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        ElevatedButton(
          onPressed: () => _showImageSourceActionSheet(context),
          child: Text('Pick Image'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
          ),
        ),
      ],
    );
  }
}
