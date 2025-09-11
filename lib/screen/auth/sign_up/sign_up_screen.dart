// lib/screen/auth/sign_up/sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:timeless/screen/auth/sign_up/sign_up_controller.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final SignUpController ctrl = Get.put(SignUpController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final isLoading = ctrl.loading.value;
          return SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: ctrl.firstnameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'First name'),
                  onChanged: (_) => ctrl.firstNameValidation(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ctrl.lastnameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Last name'),
                  onChanged: (_) => ctrl.lastNameValidation(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ctrl.emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Email'),
                  onChanged: (_) => ctrl.emailValidation(),
                ),
                const SizedBox(height: 12),

                // Password avec oeil + copier
                GetBuilder<SignUpController>(
                  id: 'showPassword',
                  builder: (_) {
                    return TextField(
                      controller: ctrl.passwordController,
                      obscureText: ctrl.show,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: ctrl.show ? 'Show' : 'Hide',
                              icon: Icon(
                                ctrl.show
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: ctrl.chang,
                            ),
                            IconButton(
                              tooltip: 'Copy',
                              icon: const Icon(Icons.copy),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(
                                      text: ctrl.passwordController.text),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Password copied')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      onChanged: (_) => ctrl.passwordValidation(),
                    );
                  },
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => ctrl.onSignUpBtnTap(),
                    child: isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create account'),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
