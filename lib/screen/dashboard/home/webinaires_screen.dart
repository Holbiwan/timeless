import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class WebinairesScreen extends StatelessWidget {
  const WebinairesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF000647),
        title: Text(
          'Webinaires',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming webinars',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF000647),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Participate in employment and training webinars',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16), // Reduced from 24
            
            // Information footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.video_call,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Click on a webinar to register or access the replay.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Webinars marked “Live” are upcoming.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16), // Reduced from 32
            
            // Webinar Emploi & Credit Management
            _buildWebinarCard(
              title: 'Webinar "Emploi & Credit Management"',
              date: '20 January 2026',
              organizer: 'AFDCC',
              description: 'Découvrez les opportunités d\'emploi dans le secteur du Credit Management',
              url: 'https://www.afdcc.fr/produit/manifestations/20-janvier-2026-save-the-date-webinar-emploi-credit-management/',
              icon: Icons.business_center,
              color: const Color(0xFF000647),
              isLive: true,
            ),
            
            const SizedBox(height: 16),
            
            // GHR Webinaire Social
            _buildWebinarCard(
              title: 'Préparez 2026 avec un webinaire social',
              date: 'À venir - 2026',
              organizer: 'GHR',
              description: 'Flashback 2025 et préparation des enjeux sociaux de 2026',
              url: 'https://www.ghr.fr/social/actualites/flashback-2025-preparez-2026-avec-notre-webinaire-social',
              icon: Icons.group,
              color: const Color(0xFF1565C0),
              isLive: false,
            ),
            

          ],
        ),
      ),
    );
  }

  Widget _buildWebinarCard({
    required String title,
    required String date,
    required String organizer,
    required String description,
    required String url,
    required IconData icon,
    required Color color,
    required bool isLive,
  }) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isLive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'EN DIRECT',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Date
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: color,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  date,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Organizer
            Row(
              children: [
                Icon(
                  Icons.business,
                  color: Colors.grey[600],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Par $organizer',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Description
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            
            // Action button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isLive ? Icons.how_to_reg : Icons.play_circle_fill,
                    color: color,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isLive ? 'Register' : 'See details',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ouvrir le lien',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}