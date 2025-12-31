import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/common/widgets/back_button.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.white,
      appBar: AppBar(
        title: Text(
          'FAQ',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: backButton(onTap: () => Navigator.pop(context)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFaqItem(
            'How do I create an account?',
            'You can create an account by clicking the Sign Up button on the welcome screen and following the instructions.',
          ),
          _buildFaqItem(
            'How do I reset my password?',
            'Click on "Forgot Password" on the login screen and follow the instructions sent to your email.',
          ),
          _buildFaqItem(
            'How do I contact support?',
            'You can contact our support team through the Help section or email us directly.',
          ),
          _buildFaqItem(
            'Is my data secure?',
            'Yes, we use industry-standard security measures to protect your personal information.',
          ),
          _buildFaqItem(
            'Can I delete my account?',
            'Yes, you can delete your account from the Settings > Account section.',
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColorRes.black,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
