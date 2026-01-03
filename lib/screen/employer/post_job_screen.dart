// ignore_for_file: deprecated_member_use, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/services/employer_service.dart';
import 'package:timeless/services/job_email_service.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/pref_keys.dart';

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
  String? _jobType = 'Full-time';
  bool _remote = true;
  Map<String, dynamic>? _employerData;
  bool _isLoadingEmployerData = true;
  String? _employerError;

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
      if (user == null) {
        if (mounted) {
          setState(() {
            _isLoadingEmployerData = false;
            _employerError = 'User not authenticated';
          });
        }
        return;
      }

      // Check if employer can access dashboard
      final canAccess = await EmployerService.canAccessEmployerDashboard();
      if (!canAccess) {
        if (mounted) {
          setState(() {
            _isLoadingEmployerData = false;
            _employerError = 'Your employer account is not active or verified. Please contact support.';
          });
        }
        return;
      }

      // Load employer data
      final data = await EmployerService.getCurrentEmployerData();
      if (mounted) {
        setState(() {
          _employerData = data;
          _isLoadingEmployerData = false;
          _employerError = data == null ? 'Failed to load employer data' : null;
        });
      }
    } catch (e) {
      debugPrint('Error loading employer data: $e');
      if (mounted) {
        setState(() {
          _isLoadingEmployerData = false;
          _employerError = 'Error loading employer data: ${e.toString()}';
        });
      }
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
          content: Text('❌ Employer data not loaded'),
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

      // Verify employer is still active before posting
      final canPost = await EmployerService.canAccessEmployerDashboard();
      if (!canPost) {
        throw Exception('Employer account is not active or verified');
      }

      // Prepare job posting data with real employer data
      final jobData = {
        'Position': _titleCtrl.text.trim(),
        'category': _category, // Correspond aux filtres existants
        'location': _locationCtrl.text.trim(),
        'salaryMin': _salaryMinCtrl.text.trim(),
        'salaryMax': _salaryMaxCtrl.text.trim(),
        'salary': '${_salaryMinCtrl.text}-${_salaryMaxCtrl.text}',
        'jobType': _jobType, // CDI, CDD, Internship, etc.
        'remote': _remote,
        'workMode': _remote ? 'Remote' : 'On-site',
        'description': _descriptionCtrl.text.trim(),
        // Données de l'employeur depuis Firestore
        'CompanyName': _employerData!['companyName'],
        'EmployerId': user.uid,
        'employerEmail': _employerData!['email'],
        'siretCode': _employerData!['siretCode'],
        'apeCode': _employerData!['apeCode'],
        'companyInfo': _employerData!['companyInfo'],
        // Métadonnées
        'isActive': true,
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
        'timestamp': FieldValue.serverTimestamp(),
        'applicationsCount': 0,
        'viewsCount': 0,
        'logoUrl': _employerData!['logoUrl'] ?? 'https://i.imgur.com/bdlYq1p.png',
        // Verification status - CRITICAL for filtering
        'isFromVerifiedEmployer': true,
        'employerVerifiedAt': FieldValue.serverTimestamp(),
      };

      // Save to Firebase
      final docRef = await FirebaseFirestore.instance.collection('allPost').add(jobData);
      
      // Additional validation through service
      await EmployerService.validateAndMarkJob(docRef.id, user.uid);

      // Send job posting confirmation email
      try {
        await JobEmailService.sendJobPostedConfirmation(
          jobTitle: _titleCtrl.text.trim(),
          companyName: _employerData!['companyName'],
          location: _locationCtrl.text.trim(),
          jobType: _jobType!,
          salary: '${_salaryMinCtrl.text}-${_salaryMaxCtrl.text}€',
          jobId: docRef.id,
        );
      } catch (e) {
        debugPrint('❌ Job posting email failed: $e');
      }

      debugPrint(
          '✅ JOB PUBLISHED TO FIREBASE: ${_titleCtrl.text} by ${_employerData!['companyName']}');

      // Show modern confirmation popup
      await _showSuccessDialog();

      Get.back();
    } catch (e) {
      debugPrint('❌ Firebase publication error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
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
            const Text('🎉 Job Posted!'),
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
                  Text('📋 Position: ${_titleCtrl.text}',
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('🏢 Company: ${_employerData!['companyName']}',
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('📍 Location: ${_locationCtrl.text}',
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(
                      '💰 Salary: ${_salaryMinCtrl.text}-${_salaryMaxCtrl.text}€',
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('Your job offer is now visible to all candidates!',
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
            child: const Text('Perfect!'),
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

    const jobTypes = <String>[
      'Full-time',
      'Contract',
      'Internship',
      'Freelance',
      'Temporary'
    ];

    // Show loading state
    if (_isLoadingEmployerData) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Create Job Posting'),
          backgroundColor: const Color(0xFF000647),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading your employer information...'),
            ],
          ),
        ),
      );
    }

    // Show error state
    if (_employerError != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Create Job Posting'),
          backgroundColor: const Color(0xFF000647),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red[700],
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Access Denied',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _employerError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoadingEmployerData = true;
                      _employerError = null;
                    });
                    _loadEmployerData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000647),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: Get.back,
                    ),
                    Expanded(
                      child: Text(
                        'Post a job',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 0, 6, 71),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                        decoration: _dec('Category'),
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
                        decoration: _dec('Contract Type'),
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
                Container(
                  height: 48,
                  child: SwitchListTile.adaptive(
                    title: const Text(
                      'Remote friendly',
                      style: TextStyle(fontSize: 14),
                    ),
                    value: _remote,
                    onChanged: (v) => setState(() => _remote = v),
                    activeColor: const Color.fromARGB(255, 0, 6, 71),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
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
                      _isLoading ? 'Posting Job...' : 'Post Job', // Direct literal strings
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
