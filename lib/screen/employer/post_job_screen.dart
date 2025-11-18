import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/pref_keys.dart';
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

  String? _category = 'Engineering';
  bool _remote = true;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _salaryMinCtrl.dispose();
    _salaryMaxCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
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

    try {
      // Préparer les données de l'annonce
      final jobData = {
        'Position': _titleCtrl.text.trim(),
        'Category': _category,
        'location': _locationCtrl.text.trim(),
        'salaryMin': _salaryMinCtrl.text.trim(),
        'salaryMax': _salaryMaxCtrl.text.trim(),
        'salary': '${_salaryMinCtrl.text}-${_salaryMaxCtrl.text}€',
        'remote': _remote,
        'type': _remote ? 'Remote' : 'On-site',
        'description': _descriptionCtrl.text.trim(),
        'CompanyName': PrefService.getString(PrefKeys.companyName),
        'EmployerId': PrefService.getString(PrefKeys.userId),
        'Status': 'Active',
        'CreatedAt': FieldValue.serverTimestamp(),
        'Applications': 0,
        'Views': 0,
      };

      // Sauvegarder dans Firebase
      await FirebaseFirestore.instance
          .collection('allPost')
          .add(jobData);

      // Mettre à jour le compteur de posts du manager
      final currentPosts = PrefService.getInt(PrefKeys.totalPost);
      await PrefService.setValue(PrefKeys.totalPost, currentPosts + 1);

      debugPrint('JOB PUBLISHED TO FIREBASE => '
          'title=${_titleCtrl.text}, cat=$_category, loc=${_locationCtrl.text}, '
          'remote=$_remote, salary=${_salaryMinCtrl.text}-${_salaryMaxCtrl.text}€');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Annonce publiée avec succès sur Firebase!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Get.back();
    } catch (e) {
      debugPrint('Erreur publication Firebase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const categories = <String>[
      'Engineering',
      'Product',
      'Design',
      'Data',
      'Marketing',
      'Other'
    ];

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
                DropdownButtonFormField<String>(
                  decoration: _dec('Category'),
                  value: _category,
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v),
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
                    icon: const Icon(Icons.publish, color: Colors.white),
                    onPressed: _publish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                    ),
                    label: const Text('Publish', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
