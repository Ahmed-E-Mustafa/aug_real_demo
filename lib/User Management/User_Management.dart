import 'package:aug_demo/Notification/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserManagement extends StatefulWidget {
  @override
  _UserManagementState createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late bool isAdmin = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Users'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('pending_users')
            .snapshots(), // Listen for pending user requests
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          final pendingUsers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pendingUsers.length,
            itemBuilder: (context, index) {
              final userRequest = pendingUsers[index];
              return ListTile(
                title: Text(userRequest['email']),
                subtitle: Text(userRequest['name']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () {
                        _approveUser(userRequest.id,
                            userRequest.data() as Map<String, dynamic>);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _rejectUser(userRequest.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _approveUser(
      String userId, Map<String, dynamic> userData) async {
    try {
      // Add user to the 'users' collection with 'notified' field as false
      await _firestore.collection('users').doc(userId).set({
        'name': userData['name'],
        'email': userData['email'],
        'status': 'active', // Mark as active
        'notified': 'false', // Mark as not notified
      });

      // Remove user from 'pending_users' collection
      await _firestore.collection('pending_users').doc(userId).delete();

      if (isAdmin) {
        NotificationService.showNotification(
          id: 0,
          title: 'Account Approved!',
          body: 'Your account has been approved by the admin.',
        );
      }

      // Optionally, update Firestore to mark user as notified after notification
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'notified': 'false'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User approved and added to users collection.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to approve user: $e')));
    }
  }

  Future<void> _rejectUser(String userId) async {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rejection Reason'),
          content: TextField(
            controller: reasonController,
            decoration:
                const InputDecoration(labelText: 'Enter reason for rejection'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('pending_users')
                    .doc(userId)
                    .update({
                  'status': 'rejected',
                  'rejection_reason': reasonController.text,
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User request rejected.')),
                );
                Navigator.pop(context);
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser(String userId) async {
    try {
      // Delete the user from Firestore
      await _firestore.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('User deleted')));

      // Show prompt to admin
      _showUserDeletedPrompt();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to delete user: $e')));
    }
  }

  void _showUserDeletedPrompt() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('The user account has been successfully deleted.')),
    );
  }
}
