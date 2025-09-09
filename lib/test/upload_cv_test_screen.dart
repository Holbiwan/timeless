import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class UploadCvTestScreen extends StatefulWidget {
  const UploadCvTestScreen({super.key});

  @override
  State<UploadCvTestScreen> createState() => _UploadCvTestScreenState();
}

class _UploadCvTestScreenState extends State<UploadCvTestScreen> {
  String status = "No file uploaded yet";

  Future<void> _uploadCV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => status = "You must be logged in!");
        return;
      }

      final ref = FirebaseStorage.instance
          .ref()
          .child("users/${user.uid}/cv/${result.files.single.name}");

      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      setState(() => status = "Uploaded! URL:\n$url");
    } catch (e) {
      setState(() => status = "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload CV Test")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(status, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadCV,
              child: const Text("Select & Upload CV (PDF)"),
            ),
          ],
        ),
      ),
    );
  }
}
