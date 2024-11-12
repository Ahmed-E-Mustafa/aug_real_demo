import 'package:flutter/material.dart';
import 'user_dashboard.dart';
import 'admin_dashboard.dart';
import 'super_admin_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toastification/toastification.dart';


class Dashboard extends StatelessWidget {
  final bool isAdmin, iSuperAdmin;

  const Dashboard({super.key, required this.isAdmin, required this.iSuperAdmin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: iSuperAdmin || isAdmin
          ? null
          : AppBar(
              centerTitle: true,
              title: const Text('User Dashboard'),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'logout') {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, '/');
                    } else if (value == 'submitInfo') {
                      _showSubmissionForm(context);
                    }
                  },
                  itemBuilder: (context) => [
                    if (!isAdmin && !iSuperAdmin)
                      const PopupMenuItem(
                        value: 'submitInfo',
                        child: Text('Submit Info for Approval'),
                      ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ],
                ),
              ],
            ),
      body: isAdmin
          ? const AdminDashboard(isAdmin: true, iSuperAdmin: false)
          : iSuperAdmin
              ? const SuperAdminDashboard()
              : const UserDashboard(),
    );
  }

  void _showSubmissionForm(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    dynamic _icons;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Submit Your Information'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Enter your name' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Enter your email' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _submitUserInfo(
                    context,
                    _nameController.text,
                    _emailController.text,
                    _icons,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitUserInfo(BuildContext context, String name, String email, icons) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('pending_users').doc(user.uid).set({
        'name': name,
        'email': email,
        'status': 'pending',
      });

      // Display success toast
      toastification.show(
        context: context,
        title: Text('Submission Successful!'),
        description: Text('Your information has been submitted for approval.'),
        icon: Icon(Icons.check_circle), // Wrap IconData in Icon widget
        backgroundColor: Colors.green,
      );
    }
  }
}
