import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebaseController with ChangeNotifier {
  final CollectionReference _blogsCollection =
      FirebaseFirestore.instance.collection('blogs');

  Future<String> uploadImage(File imageFile) async {
    String fileName = imageFile.path.split('/').last;
    Reference storageRef =
        FirebaseStorage.instance.ref().child('blog_images/$fileName');
    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> createBlog(String title, String content, String date,
      {String? imageUrl}) async {
    String authorId = FirebaseAuth.instance.currentUser!.uid;
    await _blogsCollection.add({
      'title': title,
      'content': content,
      'date': date,
      'likes': 0,
      'likedBy': [],
      'comments': [],
      'imageUrl': imageUrl,
      'authorId': authorId,
    });
  }

  Future<void> updateBlog(String blogId, String title, String content,
      {String? imageUrl}) async {
    await _blogsCollection.doc(blogId).update({
      'title': title,
      'content': content,
      if (imageUrl != null) 'imageUrl': imageUrl,
    });
  }

  Future<void> deleteBlog(String blogId) async {
    await _blogsCollection.doc(blogId).delete();
  }

  Future<void> likeBlog(String blogId, String userId) async {
    final DocumentReference blogRef = _blogsCollection.doc(blogId);
    final DocumentSnapshot blogSnapshot = await blogRef.get();

    List<dynamic> likedBy = blogSnapshot['likedBy'];
    if (!likedBy.contains(userId)) {
      await blogRef.update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userId]),
      });
    }
  }

  Future<void> unlikeBlog(String blogId, String userId) async {
    final DocumentReference blogRef = _blogsCollection.doc(blogId);
    final DocumentSnapshot blogSnapshot = await blogRef.get();

    List<dynamic> likedBy = blogSnapshot['likedBy'];
    if (likedBy.contains(userId)) {
      await blogRef.update({
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([userId]),
      });
    }
  }

  Future<void> addComment(String blogId, String comment, String userId,
      String userName, String userPhotoUrl) async {
    await _blogsCollection.doc(blogId).update({
      'comments': FieldValue.arrayUnion([
        {
          'userId': userId,
          'userName': userName,
          'userPhotoUrl': userPhotoUrl,
          'comment': comment,
        }
      ]),
    });
  }

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
