import 'dart:io';
import 'package:aug_demo/User%20Management/User_Management.dart';
import 'package:aug_demo/User%20Management/ViewUser.dart';
import 'package:aug_demo/Notification/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatelessWidget {
  final bool isAdmin, iSuperAdmin;
  const AdminDashboard({super.key, required this.isAdmin, required this.iSuperAdmin});

  // Function to upload the model to Firebase Storage and save model data to Firestore
  Future<void> _uploadModel(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    final user = FirebaseAuth.instance.currentUser;

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;

      if (file.path != null) {
        try {
          // Upload file to Firebase Storage
          final storageRef = FirebaseStorage.instance.ref().child('pending_models/${file.name}');
          final uploadTask = await storageRef.putFile(File(file.path!));
          final downloadUrl = await storageRef.getDownloadURL();

          print("Download URL: $downloadUrl");

          // Create model data to save in Firestore
          final modelData = {
            'file_name': file.name,
            'file_url': downloadUrl,
            'status': 'pending',
            'uploaded_by': user?.uid,
          };

          // Save model data to Firestore
          final modelRef = await FirebaseFirestore.instance.collection('models').add(modelData);

          // Notify Super Admin about the new model
          NotificationService.showNotification(
            id: 2,
            title: 'New Model for Approval!',
            body: 'A new 3D model has been uploaded for your approval.',
          );

          // Update Firestore with model status
          await modelRef.update({'status': 'pending'});

          // Show success dialog
          _showSuccessDialog(context, downloadUrl);

        } catch (e) {
          print("Error during upload: $e");
          _showErrorDialog(context);
        }
      } else {
        print('File path is null!');
        _showErrorDialog(context);
      }
    } else {
      print('No file selected.');
      _showErrorDialog(context);
    }
  }

  // Show success dialog after successful upload
  void _showSuccessDialog(BuildContext context, String downloadUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Successful'),
        content: Text('File uploaded successfully! Download URL: $downloadUrl'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Show error dialog if there's an issue during the upload
  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: const Text('An error occurred during the file upload. Please try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Function to handle user information submission
  Future<void> _submitUserInfo(String name, String email) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('pending_users').doc(user.uid).set({
        'name': name,
        'email': email,
        'status': 'pending',
      });
    }
  }

  // Function to show submission form for user information
  void _showSubmissionForm(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();

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
                  validator: (value) => value?.isEmpty ?? true ? 'Enter your name' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) => value?.isEmpty ?? true ? 'Enter your email' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _submitUserInfo(
                    _nameController.text,
                    _emailController.text,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: iSuperAdmin && isAdmin ? null : AppBar(
        centerTitle: true,
        title: const Text('Admin Dashboard'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/');
              } else {
                print('error');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Admin Dashboard',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _uploadModel(context),
              child: const Text('Upload 3D Model (.glb)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/user_manage'),
              child: const Text('View Pending Users'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/view_user'),
              child: const Text('View Active Users'),
            ),
            const SizedBox(height: 20),
            if (isAdmin)
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/super_admin_dashboard'),
                child: const Text('View Super Admin Dashboard'),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
