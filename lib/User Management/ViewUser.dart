import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewUser extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Users'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(), // Assumes 'users' collection contains user data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final status = user['status'] == 'active';

              return ListTile(
                leading: CircleAvatar(
                  child: Text(user['name'][0].toUpperCase()), // Initial of the name
                ),
                title: Text(user['name']),
                subtitle: Text(user['email']),
                trailing: status
                    ?const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            'Active',
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      )
                    : const Text('Inactive', style: TextStyle(color: Colors.red)),
              );
            },
          );
        },
      ),
    );
  }
}
