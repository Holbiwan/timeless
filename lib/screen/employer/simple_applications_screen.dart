import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/pref_keys.dart';

class SimpleApplicationsScreen extends StatefulWidget {
  const SimpleApplicationsScreen({super.key});

  @override
  State<SimpleApplicationsScreen> createState() => _SimpleApplicationsScreenState();
}

class _SimpleApplicationsScreenState extends State<SimpleApplicationsScreen> {
  @override
  Widget build(BuildContext context) {
    final String employerId = PreferencesService.getString(PrefKeys.employerId);
    final String currentUserId = PreferencesService.getString(PrefKeys.userId);
    final String actualEmployerId = employerId.isNotEmpty ? employerId : currentUserId;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000647),
        title: Text(
          'Applications Management',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF000647), Color(0xFF1A1A2E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage Applications',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'View and manage all applications received for your job postings',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Applications List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('applications')
                    .where('employerId', isEqualTo: actualEmployerId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 50),
                            const SizedBox(height: 16),
                            Text(
                              'Unable to load applications',
                              style: GoogleFonts.poppins(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'This might be because no applications have been submitted yet, or there\'s a database connection issue.',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF000647),
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.refresh, size: 18),
                              label: Text(
                                'Try Again',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF000647).withOpacity(0.2)),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.inbox_outlined,
                                  size: 60,
                                  color: Color(0xFF000647),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No Applications Yet',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Applications will appear here once candidates apply to your job postings',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final applications = snapshot.data!.docs;
                  
                  // Sort applications by timestamp (most recent first) on client side
                  applications.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aTimestamp = aData['timestamp'] as Timestamp?;
                    final bTimestamp = bData['timestamp'] as Timestamp?;
                    
                    if (aTimestamp == null && bTimestamp == null) return 0;
                    if (aTimestamp == null) return 1;
                    if (bTimestamp == null) return -1;
                    
                    return bTimestamp.compareTo(aTimestamp);
                  });
                  
                  return ListView.builder(
                    itemCount: applications.length,
                    itemBuilder: (context, index) {
                      final applicationData = applications[index].data() as Map<String, dynamic>;
                      return _buildApplicationCard(applicationData);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    final String candidateName = application['candidateName'] ?? 
                                application['fullName'] ?? 
                                application['name'] ?? 
                                'Unknown Candidate';
    
    // Récupérer le titre du poste depuis les différents champs possibles
    String jobTitle = application['jobTitle'] ?? 
                     application['positionTitle'] ?? 
                     application['jobName'] ?? 
                     application['position'] ?? 
                     application['JobTitle'] ?? 
                     'Position not found';
                     
    // Si on a un jobId, essayer de récupérer le titre depuis l'annonce originale
    final String jobId = application['jobId'] ?? application['JobId'] ?? '';
    if (jobId.isNotEmpty && jobTitle == 'Position not found') {
      // TODO: Fetch from allPost collection using jobId
      jobTitle = 'Loading position...';
    }
    
    final String status = application['status'] ?? 'pending';
    final String candidateEmail = application['candidateEmail'] ?? 
                                  application['email'] ?? 
                                  '';
    
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'selected':
      case 'accepted':
        statusColor = const Color(0xFF000647);
        break;
      case 'refused':
      case 'rejected':
        statusColor = Colors.black;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with candidate name and status
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF000647).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF000647),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidateName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      jobTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (candidateEmail.isNotEmpty)
                      Text(
                        candidateEmail,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Action buttons
          Row(
            children: [
              if (status.toLowerCase() == 'pending') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateApplicationStatus(application, 'selected'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000647),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.check, size: 16),
                    label: Text(
                      'Selected',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateApplicationStatus(application, 'refused'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.close, size: 16),
                    label: Text(
                      'Refused',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                ),
              ],
              if (status.toLowerCase() != 'pending')
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewApplicationDetails(application),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000647),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: Text(
                      'View Details',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateApplicationStatus(Map<String, dynamic> application, String newStatus) async {
    try {
      // Find the application document ID
      final String employerId = PreferencesService.getString(PrefKeys.employerId);
      final String currentUserId = PreferencesService.getString(PrefKeys.userId);
      final String actualEmployerId = employerId.isNotEmpty ? employerId : currentUserId;
      
      // Essayer différents champs pour l'email du candidat
      final String candidateEmail = application['candidateEmail'] ?? 
                                   application['email'] ?? 
                                   application['userEmail'] ?? '';
                                   
      // Essayer différents champs pour le nom du candidat (fallback)
      final String candidateName = application['candidateName'] ?? 
                                   application['fullName'] ?? 
                                   application['name'] ?? '';
      
      // Utiliser l'ID du document si disponible
      final String docId = application['id'] ?? application['docId'] ?? '';
      
      QuerySnapshot querySnapshot;
      
      if (docId.isNotEmpty) {
        // Si on a l'ID du document, l'utiliser directement
        querySnapshot = await FirebaseFirestore.instance
            .collection('applications')
            .where(FieldPath.documentId, isEqualTo: docId)
            .limit(1)
            .get();
      } else if (candidateEmail.isNotEmpty) {
        // Sinon, chercher par email candidat et employerId
        querySnapshot = await FirebaseFirestore.instance
            .collection('applications')
            .where('employerId', isEqualTo: actualEmployerId)
            .where('candidateEmail', isEqualTo: candidateEmail)
            .limit(1)
            .get();
      } else if (candidateName.isNotEmpty) {
        // En dernier recours, chercher par nom du candidat
        querySnapshot = await FirebaseFirestore.instance
            .collection('applications')
            .where('employerId', isEqualTo: actualEmployerId)
            .where('candidateName', isEqualTo: candidateName)
            .limit(1)
            .get();
      } else {
        Get.snackbar(
          'Error',
          'Unable to update application: missing candidate information',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      if (querySnapshot.docs.isNotEmpty) {
        // Update the application status
        await querySnapshot.docs.first.reference.update({
          'status': newStatus,
          'statusUpdatedAt': FieldValue.serverTimestamp(),
          'updatedBy': actualEmployerId,
        });
        
        // Show success message
        String message = '';
        Color bgColor = const Color(0xFF000647);
        
        switch (newStatus.toLowerCase()) {
          case 'selected':
            message = 'Candidate has been selected successfully';
            bgColor = const Color(0xFF000647);
            break;
          case 'refused':
            message = 'Candidate has been refused';
            bgColor = Colors.black;
            break;
          default:
            message = 'Application status updated successfully';
        }
        
        Get.snackbar(
          'Status Updated',
          message,
          backgroundColor: bgColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        
        // Refresh the UI
        setState(() {});
      } else {
        Get.snackbar(
          'Error',
          'Unable to find this application in the database',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update application status: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _viewApplicationDetails(Map<String, dynamic> application) {
    final String candidateName = application['candidateName'] ?? 
                                application['fullName'] ?? 
                                application['name'] ?? 
                                'Unknown Candidate';
    
    final String candidateEmail = application['candidateEmail'] ?? 
                                  application['email'] ?? 
                                  'N/A';
    
    final String jobTitle = application['jobTitle'] ?? 
                            application['positionTitle'] ?? 
                            application['jobName'] ?? 
                            application['position'] ?? 
                            'Position not specified';
    final String status = application['status'] ?? 'pending';
    final String candidatePhone = application['candidatePhone'] ?? 'N/A';
    final String experience = application['experience'] ?? 'N/A';
    final String coverLetter = application['coverLetter'] ?? 'No cover letter provided';
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Application Details',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF000647),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Candidate Name', candidateName),
              _buildDetailRow('Email', candidateEmail),
              _buildDetailRow('Phone', candidatePhone),
              _buildDetailRow('Position Applied', jobTitle),
              _buildDetailRow('Experience', experience),
              _buildDetailRow('Status', status.toUpperCase()),
              const SizedBox(height: 10),
              Text(
                'Cover Letter:',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: const Color(0xFF000647),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  coverLetter,
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: const Color(0xFF000647)),
            ),
          ),
          if (status.toLowerCase() == 'pending') ...[
            ElevatedButton(
              onPressed: () {
                Get.back();
                _updateApplicationStatus(application, 'selected');
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF000647)),
              child: Text('Selected', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                _updateApplicationStatus(application, 'refused');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[600]),
              child: Text('Refused', style: GoogleFonts.poppins()),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: const Color(0xFF000647),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}