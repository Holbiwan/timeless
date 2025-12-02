import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/common/widgets/back_button.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.white,
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
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
              'Timeless - Privacy Policy',
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
              '1. Information We Collect',
              'We collect information you provide directly to us, such as when you create an account, use our services, or contact us.',
            ),
            _buildSection(
              '2. How We Use Your Information',
              'We use the information we collect to provide, maintain, and improve our services.',
            ),
            _buildSection(
              '3. Information Sharing',
              'We do not share, sell, or rent your personal information to third parties.',
            ),
            _buildSection(
              '4. Data Security',
              'We implement appropriate technical and organizational measures to protect your personal information.',
            ),
            _buildSection(
              '5. Contact Us',
              'If you have any questions about this Privacy Policy, please contact us.',
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
