import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PendingModelsScreen extends StatelessWidget {
  const PendingModelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Models')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('models')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final models = snapshot.data!.docs;

          return ListView.builder(
            itemCount: models.length,
            itemBuilder: (context, index) {
              final model = models[index];
              return ListTile(
                title: Text(model['file_name']),
                subtitle: const Text('Status: Pending'),
              );
            },
          );
        },
      ),
    );
  }
}

class ApprovedModelsScreen extends StatelessWidget {
  const ApprovedModelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approved Models')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('models')
            .where('status', isEqualTo: 'approved')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final models = snapshot.data!.docs;

          return ListView.builder(
            itemCount: models.length,
            itemBuilder: (context, index) {
              final model = models[index];
              return ListTile(
                title: Text(model['file_name']),
                subtitle: const Text('Status: Approved'),
              );
            },
          );
        },
      ),
    );
  }
}
