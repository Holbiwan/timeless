// lib/test/seed_jobs_from_asset.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';

/// Importe assets/jobs.json dans la collection "jobs"
Future<void> importJobsFromAsset() async {
  final db = FirebaseFirestore.instance;

  // 1) Charger le JSON depuis les assets
  final raw = await rootBundle.loadString('assets/jobs.json');
  final List<dynamic> items = json.decode(raw);

  // 2) Préparer un batch (rapide et atomique)
  final batch = db.batch();
  final col = db.collection('jobs');

  for (final item in items) {
    final data = Map<String, dynamic>.from(item as Map);

    // On force createdAt depuis le serveur Firestore
    // (le ".sv": "timestamp" de ton JSON est ignoré côté Flutter)
    data['createdAt'] = FieldValue.serverTimestamp();

    final docRef = col.doc(); // ID auto
    batch.set(docRef, data);
  }

  // 3) Envoyer
  await batch.commit();
}
