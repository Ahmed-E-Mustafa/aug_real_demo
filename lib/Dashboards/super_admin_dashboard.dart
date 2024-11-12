import 'package:aug_demo/Notification/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';

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

class SuperAdminDashboard extends StatelessWidget {
  const SuperAdminDashboard({super.key});

Future<void> _approveModel(DocumentSnapshot model) async {
  final modelRef = FirebaseFirestore.instance.collection('models').doc(model.id);
  await modelRef.update({'status': 'approved'});

  final adminId = model['uploaded_by'];
  final modelName = model['file_name'];

  // Notify the admin about the approval
  NotificationService.showNotification(
    id: 1,
    title: 'Model Approved!',
    body: 'Your model "$modelName" has been approved by the Super Admin.',
  );

  FirebaseFirestore.instance.collection('notifications').add({
    'admin_id': adminId,
    'message': 'Your model "$modelName" has been approved.',
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Shimmer.fromColors(
          baseColor: const Color.fromARGB(255, 198, 74, 101),
          highlightColor: Colors.lightBlueAccent,
          period: const Duration(seconds: 1),
          child: const Text(
            'Super Admin Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/');
              } else {
                print("error");
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Color.fromARGB(255, 78, 96, 200), Color.fromARGB(255, 163, 82, 178)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('models')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final pendingModels = snapshot.data!.docs;
          return ListView.builder(
            itemCount: pendingModels.length,
            itemBuilder: (context, index) {
              final model = pendingModels[index];
              return ListTile(
                title: Text(
                  model['file_name'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                ),
                subtitle: const Text('Status: Pending', style: TextStyle(color: Colors.grey)),
                trailing: IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _approveModel(model),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
