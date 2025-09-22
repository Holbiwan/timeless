import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/color_res.dart';

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  final String currentUserId = PrefService.getString(PrefKeys.userId);
  final String companyName = PrefService.getString(PrefKeys.companyName);

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
            .where('EmployerId', isEqualTo: currentUserId)
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
                  const Icon(Icons.error, color: Colors.red, size: 50),
                  const SizedBox(height: 16),
                  Text('Erreur: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final jobs = snapshot.data?.docs ?? [];
          
          // Trier les annonces par date de création (les plus récentes en premier)
          jobs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aDate = aData['CreatedAt'] as Timestamp?;
            final bDate = bData['CreatedAt'] as Timestamp?;
            
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
                    'Aucune annonce publiée',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Créez votre première annonce !',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: Get.back,
                    icon: const Icon(Icons.add),
                    label: const Text('Créer une annonce'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorRes.containerColor,
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
                    _buildStatCard('Total', jobs.length.toString(), Icons.work),
                    _buildStatCard(
                      'Actives', 
                      jobs.where((job) => job['Status'] == 'Active').length.toString(),
                      Icons.trending_up,
                      color: Colors.green,
                    ),
                    _buildStatCard(
                      'Vues', 
                      jobs.fold<int>(0, (sum, job) => sum + (job['Views'] as int? ?? 0)).toString(),
                      Icons.visibility,
                      color: Colors.blue,
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
    final isActive = job['Status'] == 'Active';
    
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
          color: isActive ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
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
                  job['Status'] ?? 'Inconnu',
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.grey,
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
                  job['Category'] ?? 'Non spécifié',
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
                style: TextStyle(
                  color: ColorRes.containerColor,
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
                  job['type'] ?? 'Non spécifié',
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
                    Icon(Icons.visibility, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 2),
                    Text('${job['Views'] ?? 0}', style: const TextStyle(fontSize: 11)),
                    const SizedBox(width: 8),
                    Icon(Icons.people, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 2),
                    Text('${job['Applications'] ?? 0}', style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _editJob(job, docId),
                    icon: const Icon(Icons.edit, size: 18),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  IconButton(
                    onPressed: () => _toggleJobStatus(docId, isActive),
                    icon: Icon(
                      isActive ? Icons.pause_circle : Icons.play_circle,
                      size: 18,
                      color: isActive ? ColorRes.appleGreen : Colors.green,
                    ),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  IconButton(
                    onPressed: () => _deleteJob(docId, job['Position']),
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
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
      final newStatus = isCurrentlyActive ? 'Paused' : 'Active';
      
      await FirebaseFirestore.instance
          .collection('allPost')
          .doc(docId)
          .update({'Status': newStatus});
      
      Get.snackbar(
        'Statut modifié', 
        'Annonce ${isCurrentlyActive ? 'mise en pause' : 'réactivée'}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur', 
        'Impossible de modifier le statut: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _deleteJob(String docId, String? jobTitle) {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer l\'annonce'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${jobTitle ?? 'cette annonce'}" ?'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Annuler'),
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
                  'Annonce supprimée avec succès',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Erreur', 
                  'Impossible de supprimer: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}