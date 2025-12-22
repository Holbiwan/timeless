import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/color_res.dart';

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  final String currentUserId = PreferencesService.getString(PrefKeys.userId);
  final String employerId = PreferencesService.getString(PrefKeys.employerId);
  final String companyName = PreferencesService.getString(PrefKeys.companyName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Jobs Ads'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: Get.back,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('allPost')
            .where('EmployerId', isEqualTo: employerId.isNotEmpty ? employerId : currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: ColorRes.royalBlue, size: 50),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final jobs = snapshot.data?.docs ?? [];
          
          // Sort job postings by creation date (most recent first)
          jobs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aDate = aData['createdAt'] as Timestamp?;
            final bDate = bData['createdAt'] as Timestamp?;
            
            if (aDate == null && bDate == null) return 0;
            if (aDate == null) return 1;
            if (bDate == null) return -1;
            
            return bDate.compareTo(aDate);
          });

          if (jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.work_off, color: Colors.grey, size: 80),
                  const SizedBox(height: 16),
                  const Text(
                    'No job postings published',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your first job posting!',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: Get.back,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Job Posting'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000647),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Statistiques en haut
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorRes.containerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorRes.containerColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'Total', 
                      jobs.length.toString(), 
                      Icons.work, 
                      color: const Color.fromARGB(255, 0, 6, 71),
                    ),
                    _buildStatCard(
                      'Active', 
                      jobs.where((job) => (job.data() as Map<String, dynamic>)['isActive'] == true).length.toString(),
                      Icons.trending_up,
                      color: Colors.green,
                    ),
                    _buildStatCard(
                      'Views', 
                      jobs.fold<int>(0, (sum, job) => sum + ((job.data() as Map<String, dynamic>)['viewsCount'] as int? ?? 0)).toString(),
                      Icons.visibility,
                      color: const Color.fromARGB(255, 0, 6, 71),
                    ),
                  ],
                ),
              ),
              
              // Liste des annonces
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index].data() as Map<String, dynamic>;
                    final docId = jobs[index].id;
                    
                    return _buildJobCard(job, docId);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? ColorRes.containerColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color ?? ColorRes.containerColor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, String docId) {
    final isActive = job['isActive'] == true;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isActive ?  const Color.fromARGB(255, 0, 6, 71) : Colors.grey,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec titre et statut
          Row(
            children: [
              Expanded(
                child: Text(
                  job['Position'] ?? 'Sans titre',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  job['Status'] ?? '',
                  style: TextStyle(
                    color: isActive ? const Color.fromARGB(255, 0, 6, 71) : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Informations principales
          Row(
            children: [
              Icon(Icons.category, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  job['category'] ?? 'Non spécifié',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  job['location'] ?? 'Non spécifié',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Salaire et type
          Row(
            children: [
              Icon(Icons.euro, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                job['salary'] ?? 'Non spécifié',
                style: const TextStyle(
                  color: Color.fromARGB(255, 0, 6, 71),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: job['remote'] == true ? Colors.blue.withOpacity(0.1) : ColorRes.appleGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  job['jobType'] ?? 'Non spécifié',
                  style: TextStyle(
                    color: job['remote'] == true ? Colors.blue : ColorRes.appleGreen,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Statistiques et actions
          Row(
            children: [
              // Statistiques
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.visibility, size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 2),
                    Text('${job['viewsCount'] ?? 0}', style: const TextStyle(fontSize: 11)),
                    const SizedBox(width: 8),
                    Icon(Icons.people, size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 2),
                    Text('${job['applicationsCount'] ?? 0}', style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _editJob(job, docId),
                    icon: const Icon(Icons.edit, size: 24),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  IconButton(
                    onPressed: () => _toggleJobStatus(docId, isActive),
                    icon: Icon(
                      isActive ? Icons.pause_circle : Icons.play_circle,
                      size: 24,
                      color: isActive ? Colors.orange : Colors.green,
                    ),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  IconButton(
                    onPressed: () => _deleteJob(docId, job['Position']),
                    icon: const Icon(Icons.delete, size: 24, color: Color.fromARGB(255, 0, 6, 71)),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editJob(Map<String, dynamic> job, String docId) {
    // TODO: Implémenter l'édition (pour l'instant, juste un message)
    Get.snackbar(
      'Fonctionnalité', 
      'Édition de "${job['Position']}" (à implémenter)',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void _toggleJobStatus(String docId, bool isCurrentlyActive) async {
    try {
      final newStatus = !isCurrentlyActive;
      
      await FirebaseFirestore.instance
          .collection('allPost')
          .doc(docId)
          .update({'isActive': newStatus, 'status': newStatus ? 'Active' : 'Paused'});
      
      Get.snackbar(
        'Status Updated', 
        'Job posting ${isCurrentlyActive ? 'paused' : 'reactivated'}',
        backgroundColor: const Color.fromARGB(255, 0, 6, 71 ),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur', 
        'Unable to update status: $e',
        backgroundColor: ColorRes.royalBlue,
        colorText: Colors.white,
      );
    }
  }

  void _deleteJob(String docId, String? jobTitle) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Job Posting'),
        content: Text('Are you sure you want to delete "${jobTitle ?? 'this job posting'}"?'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await FirebaseFirestore.instance
                    .collection('allPost')
                    .doc(docId)
                    .delete();
                
                Get.snackbar(
                  'Supprimée', 
                  'Job posting deleted successfully',
                  backgroundColor: const Color.fromARGB(255, 0, 6, 71),
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Erreur', 
                  'Unable to delete: $e',
                  backgroundColor: ColorRes.royalBlue,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: ColorRes.royalBlue)),
          ),
        ],
      ),
    );
  }
}