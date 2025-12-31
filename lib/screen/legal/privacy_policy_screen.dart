import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/common/widgets/back_button.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                      'Privacy Policy',
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
                            const Color(0xFFFF8C00),
                            const Color(0xFFFF8C00).withOpacity(0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF000647),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.privacy_tip,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Timeless Privacy Policy',
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
                      '1. Introduction',
                      'At Timeless, we are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our professional networking and job matching platform.',
                    ),
                    
                    _buildSection(
                      '2. Information We Collect',
                      'We collect information you provide directly to us, including:\n\n• Personal Information: Name, email address, phone number, date of birth\n• Professional Information: Work experience, education, skills, resume\n• Profile Information: Bio, preferences, career objectives\n• Communication Data: Messages, interactions with other users\n• Usage Data: How you use our platform, features accessed',
                    ),
                    
                    _buildSection(
                      '3. How We Use Your Information',
                      'We use your information to:\n\n• Provide and improve our services\n• Match you with relevant job opportunities or candidates\n• Facilitate communication between users\n• Send you updates and notifications\n• Analyze usage patterns to enhance user experience\n• Comply with legal obligations\n• Prevent fraud and ensure platform security',
                    ),
                    
                    _buildSection(
                      '4. Information Sharing',
                      'We may share your information with:\n\n• Employers and recruiters (with your consent)\n• Service providers who assist in platform operations\n• Legal authorities when required by law\n• Business partners for improved services\n\nWe never sell your personal information to third parties.',
                    ),
                    
                    _buildSection(
                      '5. Data Security',
                      'We implement robust security measures to protect your information:\n\n• Encryption of sensitive data\n• Regular security assessments\n• Limited access to personal information\n• Secure data storage and transmission\n• Regular backup and recovery procedures',
                    ),
                    
                    _buildSection(
                      '6. Your Rights and Choices',
                      'You have the right to:\n\n• Access and update your personal information\n• Delete your account and associated data\n• Control who can see your profile information\n• Opt out of marketing communications\n• Request data portability\n• Withdraw consent for data processing',
                    ),
                    
                    _buildSection(
                      '7. Data Retention',
                      'We retain your information for as long as your account is active or as needed to provide services. When you delete your account, we will delete your personal information within 30 days, except where retention is required by law.',
                    ),
                    
                    _buildSection(
                      '8. International Data Transfers',
                      'Your information may be transferred to and processed in countries other than your country of residence. We ensure appropriate safeguards are in place to protect your information during such transfers.',
                    ),
                    
                    _buildSection(
                      '9. Children\'s Privacy',
                      'Timeless is not intended for users under the age of 16. We do not knowingly collect personal information from children under 16. If we become aware of such collection, we will delete the information immediately.',
                    ),
                    
                    _buildSection(
                      '10. Updates to This Policy',
                      'We may update this Privacy Policy from time to time. We will notify you of any material changes by posting the new Privacy Policy on this page and updating the "Last updated" date.',
                    ),
                    
                    _buildSection(
                      '11. Contact Us',
                      'If you have any questions about this Privacy Policy, please contact us:\n\nEmail: privacy@timeless-app.com\nData Protection Officer: dpo@timeless-app.com\nWebsite: www.timeless-app.com\n\nTimeless Team\nYour privacy is our priority',
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Footer
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFF8C00).withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.security,
                            color: const Color(0xFFFF8C00),
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your privacy and security are our top priorities',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF000647),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'We are committed to protecting your personal information and maintaining transparency in our data practices.',
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