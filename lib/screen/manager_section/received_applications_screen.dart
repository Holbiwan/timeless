import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/pref_keys.dart';

class ReceivedApplicationsScreen extends StatelessWidget {
  const ReceivedApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String companyName = PrefService.getString(PrefKeys.companyName);
    
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Received Applications',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: ColorRes.brightYellow,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Apply')
            .where('companyName', isEqualTo: companyName)
            .orderBy('appliedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: ColorRes.brightYellow),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final application = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return _buildApplicationCard(application);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Applications Yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Applications will appear here when candidates apply to your job posts.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorRes.brightYellow.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with candidate info
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: ColorRes.brightYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.person,
                  color: ColorRes.darkBlue,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application['userName'] ?? 'Unknown Candidate',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ColorRes.textPrimary,
                      ),
                    ),
                    Text(
                      application['email'] ?? 'No email',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: ColorRes.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorRes.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'NEW',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: ColorRes.successColor,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Job position applied for
          Text(
            'Applied for: ${application['jobTitle'] ?? 'Unknown Position'}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ColorRes.darkBlue,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Application date
          Text(
            'Applied: ${_formatDate(application['appliedAt'])}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: ColorRes.textSecondary,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Open candidate profile or CV
                    Get.snackbar(
                      'View Profile',
                      'Opening candidate profile...',
                      backgroundColor: ColorRes.brightYellow,
                      colorText: Colors.black,
                    );
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: Text(
                    'View Profile',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorRes.brightYellow,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Start chat with candidate
                    Get.snackbar(
                      'Contact',
                      'Starting conversation with candidate...',
                      backgroundColor: ColorRes.darkBlue,
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.chat, size: 16),
                  label: Text(
                    'Contact',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorRes.darkBlue,
                    side: const BorderSide(color: ColorRes.darkBlue),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown date';
    
    try {
      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        return 'Unknown date';
      }
      
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }
}