import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobListTestScreen extends StatelessWidget {
  const JobListTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobs = FirebaseFirestore.instance.collection("jobs");

    return Scaffold(
      appBar: AppBar(title: const Text("Jobs Test")),
      body: StreamBuilder<QuerySnapshot>(
        stream: jobs.orderBy("createdAt", descending: true).snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text("No jobs found"));
          }

          final docs = snap.data!.docs;
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(d["title"] ?? "Untitled"),
                subtitle: Text("${d["company"] ?? "—"} · ${d["location"] ?? ""}"),
                trailing: Text(
                  (d["createdAt"] is Timestamp)
                      ? (d["createdAt"] as Timestamp).toDate().toLocal().toString().split('.').first
                      : "",
                  style: const TextStyle(fontSize: 11),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
