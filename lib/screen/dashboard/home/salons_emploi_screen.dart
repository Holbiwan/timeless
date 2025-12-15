import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SalonsEmploiScreen extends StatelessWidget {
  const SalonsEmploiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF000647),
        title: Text(
          'Salons Emploi',
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
              'Upcoming Job Fairs',
              style: GoogleFonts.poppins(
                fontSize: 18, // Reduced from 22
                fontWeight: FontWeight.bold,
                color: const Color(0xFF000647),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discover the job events you won\'t want to miss',
              style: GoogleFonts.poppins(
                fontSize: 12, // Reduced from 14
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // Salon du Travail et de la Mobilité Professionnelle
            _buildSalonCard(
              title: 'Salon du Travail et de la Mobilité Professionnelle',
              date: '22 & 23 January 2026',
              location: 'Grande Halle de la Villette, Paris',
              url: 'https://paris.salondutravail.fr/',
              icon: Icons.work,
              color: const Color(0xFF000647),
            ),
            
            const SizedBox(height: 16),
            
            // Salon Your Future
            _buildSalonCard(
              title: 'Salon Your Future',
              date: '23 & 24 January 2026',
              location: 'Parc des Princes, Paris',
              url: 'https://www.your-future.fr/',
              icon: Icons.rocket_launch,
              color: const Color(0xFF1565C0),
            ),
            
            const SizedBox(height: 16),

            // Salon Formations Coding & Informatique
            _buildSalonCard(
              title: 'Salon Formations Coding & Informatique',
              date: 'Samedi 17 January 2026',
              location: 'ESPACE CHAMPERRET - HALL A, 75017 Paris',
              url: 'https://www.studyrama.com/salons/salon-studyrama-des-formations-gaming-et-coding-paris-201',
              icon: Icons.code,
              color: const Color(0xFF0D47A1),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSalonCard({
    required String title,
    required String date,
    required String location,
    required String url,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12), // Reduced from 20
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
                  padding: const EdgeInsets.all(8), // Reduced from 12
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20, // Reduced from 24
                  ),
                ),
                const SizedBox(width: 8), // Reduced from 12
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 13, // Reduced from 14
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 0, 6, 71),
                      ),
                    ),
                  ),
                // ...
                Text(
                  date,
                  style: GoogleFonts.poppins(
                    fontSize: 13, // Reduced from 14
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(255, 0, 6, 71),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.grey[600],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    location,
                    style: GoogleFonts.poppins(
                      fontSize: 13, // Reduced from 14
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8), // Reduced from 12
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Click for more information',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 0, 6, 71), // Changed color
                ),
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