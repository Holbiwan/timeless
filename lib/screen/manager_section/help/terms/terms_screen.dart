import 'package:flutter/material.dart';
import 'package:timeless/screen/legal/terms_of_service_screen.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to the new modern Terms of Service screen
    return const TermsOfServiceScreen();
  }
}