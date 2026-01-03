import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/screen/job_detail_screen/job_detail_controller.dart';
import 'package:timeless/screen/job_detail_screen/job_detail_widget/job_detail_widget.dart';
import 'package:timeless/screen/savejobs/save_job_screen.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/string.dart';

class JobDetailScreen extends StatelessWidget {
  JobDetailScreen({super.key});
  final JobDetailsController controller = Get.put(JobDetailsController());
  var args = Get.arguments;

  @override
  Widget build(BuildContext context) {
    // Safe data access
    final doc = args['saved'] as DocumentSnapshot;
    final data = doc.data() as Map<String, dynamic>;
    final position = data['Position'] ?? 'Unknown Position';
    final company = data['CompanyName'] ?? 'Unknown Company';
    final salary = data['salary'] ?? '0';
    final location = data['location'] ?? 'Unknown Location';
    final type = data['type'] ?? data['jobType'] ?? 'Full-time';
    final description = data['description'] ?? 'No description provided.';
    final requirementsList = data['RequirementsList'] as List<dynamic>? ?? []; // Safely cast to List<dynamic>

    return Scaffold(
      backgroundColor: Colors.grey[50], // Consistent with Job Offers screen
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header (Similar to Job Offers Header)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black,
                    Colors.black.withOpacity(0.9),
                    const Color(0xFF000647),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: const Color(0xFF000647).withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Always pop for detail screens
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Job Details',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Bookmark Button (Re-styled for consistency)
                  GetBuilder<JobDetailsController>(
                    id: "bookmark",
                    builder: (con) {
                      final bookmarks = data['BookMarkUserList'] as List? ?? [];
                      final isBookmarked = bookmarks.contains(PreferencesService.getString(PrefKeys.userId));
                      return GestureDetector(
                        onTap: () {
                          // Bookmark logic (copied from original, needs doc.id)
                          List updatedBookmarks = List.from(bookmarks);
                          if (isBookmarked) {
                            updatedBookmarks.remove(PreferencesService.getString(PrefKeys.userId));
                          } else {
                            updatedBookmarks.add(PreferencesService.getString(PrefKeys.userId));
                          }
                          FirebaseFirestore.instance
                              .collection('allPost')
                              .doc(doc.id)
                              .update({"BookMarkUserList": updatedBookmarks});
                          con.update(['bookmark']);
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Job Info Card (Position, Company)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.grey[100]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            position,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF000647),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            company,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Key Details Card (Salary, Type, Location)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.grey[100]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(Icons.monetization_on, 'Salary', '$salary€', Colors.black), // Black salary
                          const Divider(height: 24),
                          _buildDetailRow(Icons.work, 'Type', type, const Color(0xFF000647)),
                          const Divider(height: 24),
                          _buildDetailRow(Icons.location_on, 'Location', location, Colors.blue),
                        ],
                      ),
                    ),

                    // Description
                    Text(
                      'Description',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF000647),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.grey[100]!),
                      ),
                      child: Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),

                    // Requirements
                    Text(
                      Strings.requirements,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF000647),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.grey[100]!),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: requirementsList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle_outline, size: 18, color: const Color(0xFF000647)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    requirementsList[index].toString(),
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // Apply Now Button (Smaller and consistent)
            Container(
              height: 50, // Reduced height
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF000647), // Dark Blue
                    const Color(0xFF000647).withOpacity(0.8), // Slightly lighter Dark Blue
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF000647).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: MaterialButton(
                onPressed: () {
                  Get.toNamed(AppRes.jobApplicationScreen, arguments: {
                    'job': data,
                    'docId': doc.id,
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.zero,
                child: Text(
                  "Apply Now",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14, // Reduced font size
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for detail rows
  Widget _buildDetailRow(IconData icon, String title, String value, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF000647),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}