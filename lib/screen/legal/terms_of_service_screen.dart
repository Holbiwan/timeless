import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/common/widgets/back_button.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  backButton(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Terms of Service',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF000647),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header avec logo concept
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF000647),
                            const Color(0xFF000647).withOpacity(0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF8C00),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.gavel,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Timeless Terms of Service',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Last updated: ${DateTime.now().year}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildSection(
                      '1. Acceptance of Terms',
                      'By accessing and using Timeless, you accept and agree to be bound by the terms and provision of this agreement. Timeless is a professional networking and job matching platform designed to connect talented professionals with exciting career opportunities.',
                    ),

                    _buildSection(
                      '2. Description of Service',
                      'Timeless provides a comprehensive platform for job seekers and employers. Our services include:\n\n• Job posting and application management\n• Professional profile creation and optimization\n• Advanced matching algorithms\n• Secure messaging between candidates and employers\n• Career development resources\n• Skills assessment and verification',
                    ),

                    _buildSection(
                      '3. User Accounts and Responsibilities',
                      'To use certain features of Timeless, you must register for an account. You are responsible for:\n\n• Providing accurate and complete information\n• Maintaining the confidentiality of your account\n• All activities that occur under your account\n• Notifying us immediately of any unauthorized use',
                    ),

                    _buildSection(
                      '4. Acceptable Use',
                      'You agree not to:\n\n• Post false, misleading, or inappropriate content\n• Harass, abuse, or harm other users\n• Violate any applicable laws or regulations\n• Attempt to gain unauthorized access to our systems\n• Use the service for any commercial purpose without permission\n• Spam or send unsolicited communications',
                    ),

                    _buildSection(
                      '5. Privacy and Data Protection',
                      'Your privacy is important to us. We collect and use your information in accordance with our Privacy Policy. By using Timeless, you consent to the collection and use of your information as described in our Privacy Policy.',
                    ),

                    _buildSection(
                      '6. Intellectual Property',
                      'Timeless and its content, features, and functionality are owned by Timeless and are protected by international copyright, trademark, and other intellectual property laws. You may not modify, distribute, or create derivative works based on our service.',
                    ),

                    _buildSection(
                      '7. Termination',
                      'We may terminate or suspend your account and access to the service immediately, without prior notice, for any reason, including if you breach these Terms of Service.',
                    ),

                    _buildSection(
                      '8. Disclaimer of Warranties',
                      'Timeless is provided "as is" without warranties of any kind. We do not guarantee that the service will be uninterrupted, secure, or error-free.',
                    ),

                    _buildSection(
                      '9. Limitation of Liability',
                      'In no event shall Timeless be liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of the service.',
                    ),

                    _buildSection(
                      '10. Contact Information',
                      'If you have any questions about these Terms of Service, please contact us at:\n\nEmail: legal@timeless-app.com\nWebsite: www.timeless-app.com\n\nTimeless Team\nBuilding the future of professional networking',
                    ),

                    const SizedBox(height: 32),

                    // Footer
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF000647).withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: const Color(0xFFFF8C00),
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Thank you for being part of the Timeless community!',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF000647),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Together, we\'re building the future of professional networking.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
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
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF000647),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
