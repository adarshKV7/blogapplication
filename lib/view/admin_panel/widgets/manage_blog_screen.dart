// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageBlogsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Blogs'),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No blogs found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var blog = snapshot.data!.docs[index];
              var blogData = blog.data() as Map<String, dynamic>;
              String title = blogData['title'] ?? 'No Title';
              String content = blogData['content'] ?? 'No Content';

              return ListTile(
                leading: Icon(Icons.article),
                title: Text(title),
                subtitle: Text(content),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _deleteBlog(blog.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteBlog(String blogId) async {
    await FirebaseFirestore.instance.collection('blogs').doc(blogId).delete();
  }
}
