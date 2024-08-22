import 'package:blogapplication/view/blog_details_screen/blog_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blogapplication/controller/firebase_controller.dart';
import 'package:blogapplication/view/profile_screen/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseController _firebaseController = FirebaseController();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Blogs'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user.displayName ?? 'Anonymous'),
              accountEmail: Text(user.email ?? 'No Email'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                  user.photoURL ?? 'https://example.com/default-profile.png',
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/admin');
              },
            ),
            ListTile(
              leading: Icon(Icons.dark_mode),
              title: Text('Dark/Light Mode'),
              trailing: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (bool value) {
                  context.read<FirebaseController>().toggleTheme();
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No blogs available'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var blog = snapshot.data!.docs[index];
              String blogId = blog.id;
              Map<String, dynamic> blogData =
                  blog.data() as Map<String, dynamic>;

              String title = blogData['title'] ?? 'No Title';
              String content = blogData['content'] ?? 'No Content';
              String imageUrl = blogData['imageUrl'] ?? '';
              String date = blogData['date'] ?? 'No Date';
              String authorId = blogData['authorId'] ?? '';
              List<dynamic> likedBy = blogData['likedBy'] ?? [];
              int likesCount = likedBy.length;
              int commentsCount = blogData['comments']?.length ?? 0;
              bool isLiked =
                  likedBy.contains(FirebaseAuth.instance.currentUser!.uid);

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlogDetailScreen(
                          blogId: blogId,
                          title: title,
                          content: content,
                          imageUrl: imageUrl,
                          date: date,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: 150),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.blue,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageUrl.isNotEmpty)
                          Container(
                            constraints: BoxConstraints(maxHeight: 200),
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        SizedBox(height: 10),
                        Text(
                          title,
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Published on $date',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isLiked ? Colors.red : Colors.white),
                              onPressed: () async {
                                String userId =
                                    FirebaseAuth.instance.currentUser!.uid;
                                if (isLiked) {
                                  await _firebaseController.unlikeBlog(
                                      blogId, userId);
                                } else {
                                  await _firebaseController.likeBlog(
                                      blogId, userId);
                                }
                              },
                            ),
                            Text(
                              '$likesCount Likes',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(width: 10),
                            IconButton(
                              icon: Icon(Icons.comment, color: Colors.white),
                              onPressed: () {
                                _showCommentDialog(context, blogId);
                              },
                            ),
                            Text(
                              '$commentsCount Comments',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCommentDialog(BuildContext context, String blogId) {
    final TextEditingController _commentController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Comments',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('blogs')
                      .doc(blogId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    var blogData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    List<dynamic> comments = blogData['comments'] ?? [];

                    return ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        var comment = comments[index] as Map<String, dynamic>;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(comment['userPhotoUrl'] ?? ''),
                          ),
                          title: Text(comment['userName'] ?? 'Anonymous'),
                          subtitle: Text(comment['comment'] ?? ''),
                        );
                      },
                    );
                  },
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () async {
                        if (_commentController.text.isNotEmpty) {
                          await _firebaseController.addComment(
                            blogId,
                            _commentController.text,
                            user.uid,
                            user.displayName ?? 'Anonymous',
                            user.photoURL ??
                                'https://example.com/default-profile.png',
                          );
                          _commentController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
