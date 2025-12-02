import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GoogleSignupScreen extends StatelessWidget {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;

  const GoogleSignupScreen({
    super.key,
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Google Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('UID: $uid'),
            const SizedBox(height: 8),
            Text('Email: $email'),
            const SizedBox(height: 8),
            Text('First name: $firstName'),
            const SizedBox(height: 8),
            Text('Last name:  $lastName'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Ici tu peux pousser vers ton vrai flow (enregistrement Firestore, etc.)
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Get.offAllNamed('/dashboard');
                  }
                },
                child: const Text('Continue'),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ==== Helpers inclus pour éviter d’anciennes erreurs sur ce fichier ====
  // Si ton ancienne UI les appelle encore, ils existent.
  Widget texFieldColumn({
    required String title,
    required String hintText,
    required ValueChanged<String> onChanged,
    required String error,
    required TextEditingController txtController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 10),
          child: Text(title),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextFormField(
            controller: txtController,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              border: const OutlineInputBorder(),
              errorText: error.isEmpty ? null : error,
              enabledBorder: enableBorder(),
              focusedBorder: enableBorder(),
              errorBorder: errorBorder(),
            ),
          ),
        ),
      ],
    );
  }

  InputBorder errorBorder() =>
      const OutlineInputBorder(borderSide: BorderSide(width: 1.2));

  InputBorder enableBorder() =>
      const OutlineInputBorder(borderSide: BorderSide(width: 1));
}
