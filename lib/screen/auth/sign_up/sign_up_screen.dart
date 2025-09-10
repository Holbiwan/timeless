// lib/screen/auth/sign_up/sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/screen/auth/sign_in_screen/sign_in_controller.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  // contrôleurs de texte
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final signInCtrl = Get.find<SignInScreenController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'First name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed:
                      signInCtrl.loading.value
                          ? null
                          : () async {
                            await signInCtrl.registerWithEmail(
                              firstName: firstNameController.text.trim(),
                              lastName: lastNameController.text.trim(),
                              email: emailController.text.trim(),
                              password: passwordController.text,
                            );
                          },
                  child:
                      signInCtrl.loading.value
                          ? const CircularProgressIndicator()
                          : const Text('Create account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
