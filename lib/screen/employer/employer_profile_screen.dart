import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeless/screen/employer/post_job_screen.dart';
import 'package:timeless/screen/employer/my_jobs_screen.dart';
import 'package:timeless/screen/manager_section/auth_manager/Sign_in/sign_in_screen.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:timeless/utils/color_res.dart';

class EmployerProfileScreen extends StatefulWidget {
  const EmployerProfileScreen({super.key});

  @override
  State<EmployerProfileScreen> createState() => _EmployerProfileScreenState();
}

class _EmployerProfileScreenState extends State<EmployerProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _companyCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _websiteCtrl.dispose();
    _locationCtrl.dispose();
    _aboutCtrl.dispose();
    super.dispose();
  }

  void _loadCompanyData() async {
    final userId = PrefService.getString(PrefKeys.userId);
    if (userId.isNotEmpty) {
      try {
        final companyDocs = await FirebaseFirestore.instance
            .collection("Auth")
            .doc("Manager")
            .collection("register")
            .doc(userId)
            .collection("company")
            .get();

        if (companyDocs.docs.isNotEmpty) {
          final data = companyDocs.docs.first.data();
          setState(() {
            _companyCtrl.text = data['name'] ?? '';
            _websiteCtrl.text = data['website'] ?? '';
            _locationCtrl.text = data['location'] ?? '';
            _aboutCtrl.text = data['description'] ?? '';
          });
        }
      } catch (e) {
        debugPrint('Erreur chargement données: $e');
      }
    }
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = PrefService.getString(PrefKeys.userId);
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Erreur: Utilisateur non connecté')),
      );
      return;
    }

    try {
      // Préparer les données de l'entreprise
      final companyData = {
        'name': _companyCtrl.text.trim(),
        'website': _websiteCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'description': _aboutCtrl.text.trim(),
        'UpdatedAt': FieldValue.serverTimestamp(),
      };

      // Mettre à jour dans Firebase
      final companyRef = FirebaseFirestore.instance
          .collection("Auth")
          .doc("Manager")
          .collection("register")
          .doc(userId)
          .collection("company");

      final existingDocs = await companyRef.get();
      
      if (existingDocs.docs.isNotEmpty) {
        // Mettre à jour le document existant
        await companyRef.doc(existingDocs.docs.first.id).update(companyData);
      } else {
        // Créer un nouveau document
        await companyRef.add({
          ...companyData,
          'CreatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Mettre à jour les préférences locales
      await PrefService.setValue(PrefKeys.companyName, _companyCtrl.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Profil sauvegardé avec succès!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Erreur sauvegarde profil: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _logout() async {
    // Déconnexion Firebase
    await FirebaseAuth.instance.signOut();
    
    // Effacer toutes les préférences de session
    await PrefService.setValue(PrefKeys.rol, "");
    await PrefService.setValue(PrefKeys.totalPost, 0);
    await PrefService.setValue(PrefKeys.company, false);
    await PrefService.setValue(PrefKeys.userId, "");
    await PrefService.setValue(PrefKeys.companyName, "");
    
    // Rediriger vers l'écran de connexion employeur
    Get.offAll(() => const SignInScreenM());
  }

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employer profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: Get.back,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _companyCtrl,
                  decoration: _dec('Company name', hint: 'Ex: Timeless SAS'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _websiteCtrl,
                  decoration: _dec('Website', hint: 'https://example.com'),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _locationCtrl,
                  decoration: _dec('Location', hint: 'City, Country'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _aboutCtrl,
                  minLines: 4,
                  maxLines: 6,
                  decoration: _dec('About the company'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorRes.containerColor,
                    ),
                    child: const Text('Save profile'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => Get.to(() => const PostJobScreen()),
                    icon: const Icon(Icons.add_box_outlined),
                    label: const Text('Post a job'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => Get.to(() => const MyJobsScreen()),
                    icon: const Icon(Icons.work, color: Colors.blue),
                    label: const Text('My Jobs Ads', style: TextStyle(color: Colors.blue)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('Retour à la connexion', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
