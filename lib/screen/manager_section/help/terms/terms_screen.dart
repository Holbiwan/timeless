import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/common/widgets/back_button.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.white,
      appBar: AppBar(
        title: Text(
          'Terms of Service',
          style: GoogleFonts.poppins(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timeless - Terms of Service',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorRes.black,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Last updated: ${DateTime.now().year}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            _buildSection(
              '1. Acceptance of Terms',
              'By using the Timeless application, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our service.',
            ),
            _buildSection(
              '2. Description of Service',
              'Timeless is a job search and recruitment platform that connects job seekers with employers. Our service provides tools for job searching, application management, and professional networking.',
            ),
            _buildSection(
              '3. User Accounts',
              'You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. You agree to provide accurate and complete information when creating your account.',
            ),
            _buildSection(
              '4. Privacy Policy',
              'Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and protect your information.',
            ),
            _buildSection(
              '5. User Content',
              'You retain ownership of any content you submit through Timeless, including resumes, profiles, and messages. By submitting content, you grant Timeless a license to use, display, and distribute your content as necessary to provide our services.',
            ),
            _buildSection(
              '6. Prohibited Uses',
              'You may not use Timeless for any unlawful purpose or in violation of these terms. This includes, but is not limited to, harassment, spam, or posting false information.',
            ),
            _buildSection(
              '7. Limitation of Liability',
              'Timeless is provided "as is" without warranties of any kind. We shall not be liable for any damages arising from your use of the service.',
            ),
            _buildSection(
              '8. Contact Information',
              'If you have any questions about these Terms of Service, please contact us at support@timeless.com',
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                '© ${DateTime.now().year} Timeless. All rights reserved.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ColorRes.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
