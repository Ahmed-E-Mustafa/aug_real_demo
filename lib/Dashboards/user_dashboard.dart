import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Notification/notification_service.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  bool isApproved = false;
  bool isPending = false;
  String rejectionReason = '';
  bool isNotified = false;

  @override
  void initState() {
    super.initState();
    _checkApprovalStatus();
  }

  // Check the approval status of the user
  Future<void> _checkApprovalStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // User is approved
        setState(() {
          isApproved = userDoc['status'] == 'active';
          isNotified = userDoc['notified'] == 'false';
        });

        // Show notification only once if user is approved and hasn't been notified
        if (isApproved && isNotified) {

                    NotificationService.showNotification(
            id: 0,
            title: 'Account Approved!',
            body: 'Your account has been approved by the admin.',
          );
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'notified': 'true'});

          NotificationService.showNotification(
            id: 0,
            title: 'Account Approved!',
            body: 'Your account has been approved by the admin.',
          );
        }
      } else {
        // Check in pending_users if not found in 'users'
        final pendingUserDoc = await FirebaseFirestore.instance
            .collection('pending_users')
            .doc(user.uid)
            .get();

        setState(() {
          if (pendingUserDoc.exists) {
            isPending = pendingUserDoc['status'] == 'pending';
            if (pendingUserDoc['status'] == 'rejected') {
              rejectionReason = pendingUserDoc['rejection_reason'] ?? 'No reason provided';
            }
          }
        });

        // Notify user of pending approval
        if (isPending) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Approval is pending. Expected resolution in 24 hours.'),
            ),
          );
        } else if (rejectionReason.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Approval rejected: $rejectionReason. Please resubmit.'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to your Dashboard!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            if (isApproved)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/ar_object'); // Navigate to AR demo
                },
                child: const Text('Open AR Demo'),
              ),
            if (!isApproved && !isPending)
              ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: const Text('Account Not Approved'),
              ),
            const SizedBox(height: 20),
            if (isPending)
              const Text('Your approval is pending. Please wait...'),
            if (rejectionReason.isNotEmpty)
              Text('Your account was rejected: $rejectionReason. Please resubmit.'),
          ],
        ),
      ),
    );
  }

  // Logout function
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen
  }
}
