// lib/screen/auth/sign_up/sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'sign_up_controller.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignUpController>(
      init: SignUpController(),
      builder: (c) {
        return Scaffold(
          appBar: AppBar(title: const Text('Sign Up')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: c.firstnameController,
                    decoration: InputDecoration(
                      labelText: 'First name',
                      errorText: c.firstError.isEmpty ? null : c.firstError,
                    ),
                    onChanged: c.onChanged,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: c.lastnameController,
                    decoration: InputDecoration(
                      labelText: 'Last name',
                      errorText: c.lastError.isEmpty ? null : c.lastError,
                    ),
                    onChanged: c.onChanged,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: c.emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: c.emailError.isEmpty ? null : c.emailError,
                    ),
                    onChanged: c.onChanged,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: c.passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: c.pwdError.isEmpty ? null : c.pwdError,
                    ),
                    onChanged: c.onChanged,
                  ),
                  const SizedBox(height: 24),
                  Obx(() => ElevatedButton(
                        onPressed: c.loading.value ? null : c.onSignUpBtnTap,
                        child: c.loading.value
                            ? const CircularProgressIndicator()
                            : const Text('Create account'),
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
