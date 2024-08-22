// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:blogapplication/view/admin_panel/widgets/content%20report_screen.dart';
import 'package:blogapplication/view/admin_panel/widgets/manage_blog_screen.dart';
import 'package:blogapplication/view/admin_panel/widgets/manage_user_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPanelScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, Admin!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildAdminOption(
                    context,
                    icon: Icons.person,
                    title: 'Manage Users',
                    description: 'View and manage registered users.',
                    onTap: () => _navigateToManageUsers(context),
                  ),
                  _buildAdminOption(
                    context,
                    icon: Icons.article,
                    title: 'Manage Blogs',
                    description: 'View and moderate blog posts.',
                    onTap: () => _navigateToManageBlogs(context),
                  ),
                  _buildAdminOption(
                    context,
                    icon: Icons.report,
                    title: 'Content Reports',
                    description: 'Review reported content.',
                    onTap: () => _navigateToContentReports(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminOption(BuildContext context,
      {required IconData icon,
      required String title,
      required String description,
      required VoidCallback onTap}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.deepOrange,
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _navigateToManageUsers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageUsersScreen(),
      ),
    );
  }

  void _navigateToManageBlogs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageBlogsScreen(),
      ),
    );
  }

  void _navigateToContentReports(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentReportsScreen(),
      ),
    );
  }
}
