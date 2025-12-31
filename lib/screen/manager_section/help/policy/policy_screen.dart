import 'package:flutter/material.dart';
import 'package:timeless/screen/legal/privacy_policy_screen.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to the new modern Privacy Policy screen
    return const PrivacyPolicyScreen();
  }
}