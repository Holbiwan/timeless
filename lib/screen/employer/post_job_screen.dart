// ignore_for_file: deprecated_member_use, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
import 'package:timeless/utils/pref_keys.dart';
// ignore: unused_import
import 'package:timeless/utils/color_res.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _salaryMinCtrl = TextEditingController();
  final TextEditingController _salaryMaxCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();

  String? _category = 'Data';
  String? _jobType = 'CDI';
  bool _remote = true;
  Map<String, dynamic>? _employerData;

  @override
  void initState() {
    super.initState();
    _loadEmployerData();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _salaryMinCtrl.dispose();
    _salaryMaxCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadEmployerData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('employers')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            _employerData = doc.data();
          });
        }
      }
    } catch (e) {
      debugPrint('Erreur chargement données employeur: $e');
    }
  }

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      );

  void _publish() async {
    if (!_formKey.currentState!.validate()) return;
    if (_employerData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Données employeur non chargées'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;

      // Préparer les données de l'annonce avec les vraies données employeur
      final jobData = {
        'Position': _titleCtrl.text.trim(),
        'category': _category, // Correspond aux filtres existants
        'location': _locationCtrl.text.trim(),
        'salaryMin': _salaryMinCtrl.text.trim(),
        'salaryMax': _salaryMaxCtrl.text.trim(),
        'salary': '${_salaryMinCtrl.text}-${_salaryMaxCtrl.text}',
        'jobType': _jobType, // CDI, CDD, Stage, etc.
        'remote': _remote,
        'workMode': _remote ? 'Remote' : 'On-site',
        'description': _descriptionCtrl.text.trim(),
        // Données de l'employeur depuis Firestore
        'CompanyName': _employerData!['companyName'],
        'employerId': user.uid,
        'employerEmail': _employerData!['email'],
        'siretCode': _employerData!['siretCode'],
        'apeCode': _employerData!['apeCode'],
        'companyInfo': _employerData!['companyInfo'],
        // Métadonnées
        'isActive': true,
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
        'applicationsCount': 0,
        'viewsCount': 0,
        'logoUrl':
            _employerData!['logoUrl'] ?? 'https://i.imgur.com/bdlYq1p.png',
      };

      // Sauvegarder dans Firebase
      await FirebaseFirestore.instance.collection('allPost').add(jobData);

      debugPrint(
          '✅ JOB PUBLISHED TO FIREBASE: ${_titleCtrl.text} by ${_employerData!['companyName']}');

      // Afficher popup de confirmation moderne
      await _showSuccessDialog();

      Get.back();
    } catch (e) {
      debugPrint('❌ Erreur publication Firebase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isLoading = false;

  Future<void> _showSuccessDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(50),
              ),
              child:
                  Icon(Icons.check_circle, color: Colors.green[700], size: 24),
            ),
            const SizedBox(width: 12),
            const Text('🎉 Annonce publiée !'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📋 Poste: ${_titleCtrl.text}',
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('🏢 Entreprise: ${_employerData!['companyName']}',
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('📍 Lieu: ${_locationCtrl.text}',
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(
                      '💰 Salaire: ${_salaryMinCtrl.text}-${_salaryMaxCtrl.text}€',
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
                'Votre offre est maintenant visible par tous les candidats !',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Parfait !'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const categories = <String>[
      'Data',
      'UX/UI',
      'Security',
    ];

    const jobTypes = <String>['CDI', 'CDD', 'Stage', 'Freelance', 'Intérim'];

    // Afficher un loader si les données employeur se chargent
    if (_employerData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Créer une annonce')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Chargement de vos informations employeur...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a job'),
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
                  controller: _titleCtrl,
                  decoration: _dec('Job title', hint: 'Ex: Flutter Developer'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: _dec('Catégorie'),
                        value: _category,
                        items: categories
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _category = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: _dec('Type de contrat'),
                        value: _jobType,
                        items: jobTypes
                            .map((t) =>
                                DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (v) => setState(() => _jobType = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _locationCtrl,
                  decoration: _dec('Location', hint: 'Paris, Remote, …'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _salaryMinCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _dec('Salary min', hint: '€'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _salaryMaxCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _dec('Salary max', hint: '€'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  title: const Text('Remote friendly'),
                  value: _remote,
                  onChanged: (v) => setState(() => _remote = v),
                  activeColor: ColorRes.containerColor,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionCtrl,
                  minLines: 6,
                  maxLines: 10,
                  decoration: _dec('Description'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.publish, color: Colors.white),
                    onPressed: _isLoading ? null : _publish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000647),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                    ),
                    label: Text(
                      _isLoading ? 'Publication...' : 'Publier l\'annonce',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
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
