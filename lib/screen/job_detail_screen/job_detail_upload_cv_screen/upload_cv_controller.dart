import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:timeless/utils/pref_keys.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart'; // Package removed

FirebaseFirestore firestore = FirebaseFirestore.instance;
List<Map<String, dynamic>> companyList = [];
bool abc = false;

class JobDetailsUploadCvController extends GetxController {
  // RefreshController refreshController = RefreshController(); // Package removed

  init() async {
    companyList = [];
    try {
      final value = await firestore.collection("Apply").get();

      for (final element in value.docs) {
        if (element['uid'] == PreferencesService.getString(PrefKeys.userId)) {
          final list = element['companyName'];
          if (list is List) {
            for (int y = 0; y < list.length; y++) {
              final item = list[y];
              if (item is Map) {
                companyList.add({
                  "companyname": item["companyname"],
                  "position": item["position"],
                });
              }
            }
          }
        }
      }
    } on FirebaseException catch (e) {
      // Ne pas crasher si les règles Firestore bloquent (permission-denied)
      if (e.code == 'permission-denied') {
        if (kDebugMode) {
          debugPrint('Firestore read blocked (Apply): permission-denied — skipping init list for demo.');
        }
      } else {
        rethrow; // autres erreurs : on laisse remonter
      }
    } catch (e) {
      // Par sécurité : ne pas crasher sur un format inattendu
      if (kDebugMode) debugPrint('Unexpected error reading Apply: $e');
    }

    if (kDebugMode) {
      print(companyList);
    }
    // refreshController.refreshCompleted(); // Package removed
    update(["searchChat"]);
  }

  String? pdfUrl;
  double filesize = 0;

  onTapApply({var args}) async {
    abc = false;
    for (int i = 0; i < companyList.length; i++) {
      // ✅ correction de la typo: companyname
      if (companyList[i]['companyname'] == args['CompanyName'] &&
          companyList[i]['position'] == args['Position']) {
        abc = true;
        break;
      }
    }

    if (!abc) {
      companyList.add({
        "companyname": args['CompanyName'],
        "position": args['Position'],
      });
    }

    final List<Map<String, dynamic>> companyNameList = List.generate(
      companyList.length,
      (index) => companyList[index],
    );

    if (kDebugMode) {
      print(companyNameList.runtimeType);
    }

    firestore.collection("Apply").doc(FirebaseAuth.instance.currentUser!.uid).set({
      'apply': true,
      'companyName': companyNameList,
      'userName': PreferencesService.getString(PrefKeys.fullName),
      'email': PreferencesService.getString(PrefKeys.email),
      'phone': PreferencesService.getString(PrefKeys.phoneNumber),
      'city': PreferencesService.getString(PrefKeys.city),
      'state': PreferencesService.getString(PrefKeys.state),
      'country': PreferencesService.getString(PrefKeys.country),
      'Occupation': PreferencesService.getString(PrefKeys.occupation),
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'resumeUrl': pdfUrl,
      'fileName': filepath.value,
      'fileSize': filesize,
      'salary': args['salary'],
      'location': args['location'],
      'type': args['type'],
      'motivationLetter': motivationController.text.trim(), // Lettre de motivation
      "deviceToken": PreferencesService.getString(PrefKeys.deviceToken),
    });

    // Send application confirmation email
    await _sendApplicationConfirmationEmail(args);

    // Add notification for application submission
    await _addApplicationNotification(args);

    // Success message will be shown via popup in the UI
    
    Get.toNamed(AppRes.jobDetailSuccessOrFailed, arguments: [
      {"doc": args},
      {"error": false, "filename": filepath},
    ]);

    filepath.value = "";
    motivationController.clear(); // Reset lettre de motivation
  }

  RxString filepath = "".obs;
  RxInt? fileSize;
  RxBool isPdfUploadError = false.obs;
  bool uploadingMedia = false;

  // Controller pour la lettre de motivation
  TextEditingController motivationController = TextEditingController();

  // Méthode pour créer un CV de démo rapidement
  void createDemoCV() {
    try {
      filepath.value = "demo_cv.pdf";
      pdfUrl = "https://demo.timeless.com/cv/demo_user_cv.pdf";
      filesize = 0.5; // 0.5 MB
      fileSize?.value = 500; // 500 KB
      isPdfUploadError.value = false;
      
      Get.snackbar(
        'Demo CV Created',
        'Demo CV configured successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      if (kDebugMode) print('Erreur création CV démo: $e');
    }
  }

  // Liste des CV stockés
  RxList<Map<String, dynamic>> storedCVs = <Map<String, dynamic>>[].obs;

  // Méthode pour charger les CV stockés depuis Firestore
  void loadStoredCVs() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Récupérer les CV stockés depuis la collection "UserCVs"
      final cvDocs = await firestore
          .collection("UserCVs")
          .doc(userId)
          .collection("CVs")
          .get();

      storedCVs.clear();
      for (final doc in cvDocs.docs) {
        storedCVs.add({
          'id': doc.id,
          'fileName': doc.data()['fileName'] ?? 'CV sans nom',
          'url': doc.data()['url'] ?? '',
          'uploadDate': doc.data()['uploadDate'] ?? '',
          'fileSize': doc.data()['fileSize'] ?? 0,
        });
      }

      if (storedCVs.isNotEmpty) {
        _showStoredCVsDialog();
      } else {
        Get.snackbar(
          'Aucun CV stocké',
          'Vous n\'avez pas encore de CV sauvegardé',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (kDebugMode) print('Erreur chargement CV stockés: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de charger vos CV stockés',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Afficher la boîte de dialogue avec les CV stockés
  void _showStoredCVsDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mes CV stockés',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: storedCVs.length,
                  itemBuilder: (context, index) {
                    final cv = storedCVs[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE9ECEF)),
                      ),
                      child: InkWell(
                        onTap: () => _selectStoredCV(cv),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.picture_as_pdf,
                              color: Color(0xFF4A90E2),
                              size: 30,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cv['fileName'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${(cv['fileSize'] / 1024).toStringAsFixed(1)} KB',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Color(0xFF4A90E2),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Sélectionner un CV stocké
  void _selectStoredCV(Map<String, dynamic> cv) {
    filepath.value = cv['fileName'];
    pdfUrl = cv['url'];
    filesize = cv['fileSize'] / (1024 * 1024); // Convert to MB
    isPdfUploadError.value = false;
    
    Get.back(); // Fermer la boîte de dialogue
    
    Get.snackbar(
      'CV sélectionné',
      'CV "${cv['fileName']}" prêt pour la candidature',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  applyResume() async {
    try {
      // Simplifier : essayer directement sans permissions complexes
      Get.snackbar(
        'Selecting File...',
        'Please select your CV (PDF)',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['pdf'],
        withData: false, // Améliore les performances
        withReadStream: false, // Améliore les performances
      );

      if (result != null && result.files.isNotEmpty) {
        final PlatformFile file = result.files.first;

        // Vérifier la taille du fichier (max 5MB pour être plus rapide)
        if (file.size > 5 * 1024 * 1024) {
          Get.snackbar(
            'File Too Large',
            'File must be less than 5MB for fast upload',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          return;
        }

        filepath.value = file.name;
        final kb = file.size / 1024;
        filesize = kb / 1024; // MB
        fileSize?.value = kb.ceil().toInt();

        if (kDebugMode) {
          print("Fichier: ${file.name}, Taille: ${filesize}MB");
        }

        // Afficher indicateur de chargement
        Get.snackbar(
          'Uploading CV...',
          'Please wait while we upload your CV',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );

        if (file.path != null) {
          final File fileForFirebase = File(file.path!);
          final url = await uploadImage(file: fileForFirebase, path: "cv/${file.name}");
          
          if (url != null) {
            Get.snackbar(
              '✅ Success!',
              'Your CV has been uploaded successfully! You can now apply for this job.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
            );
            isPdfUploadError.value = false;
          } else {
            throw Exception('URL de téléchargement nulle');
          }
        } else {
          throw Exception('Chemin du fichier non accessible');
        }
      } else {
        // User canceled
        Get.snackbar(
          'Cancelled',
          'File selection cancelled',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        isPdfUploadError.value = true;
      }
    } catch (e) {
      if (kDebugMode) print('Erreur upload CV: $e');
      Get.snackbar(
        'Upload Error',
        'Problem during upload: ${e.toString().split(': ').last}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      isPdfUploadError.value = true;
    }
  }

  Future<String?> uploadImage({File? file, String? path}) async {
    if (file == null || path == null) {
      if (kDebugMode) print('No file or path provided');
      return null;
    }

    try {
      // Pour la démo, simuler un upload rapide si utilisateur démo
      final userId = PreferencesService.getString(PrefKeys.userId);
      if (userId == "demo_user_12345") {
        // Simuler un délai d'upload court pour la démo
        await Future.delayed(const Duration(seconds: 1));
        final fakeUrl = "https://demo.timeless.com/cv/demo_${DateTime.now().millisecondsSinceEpoch}.pdf";
        pdfUrl = fakeUrl;
        if (kDebugMode) print("Demo CV URL: $fakeUrl");
        return fakeUrl;
      }

      // Vérifier que l'utilisateur est connecté
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Créer un nom de fichier unique et simple
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${user.uid}_$timestamp.pdf';
      final ref = FirebaseStorage.instance.ref().child('cv/$fileName');
      
      if (kDebugMode) print('Début upload: $fileName');
      
      // Upload optimisé avec timeout
      final uploadTask = ref.putFile(file);
      
      // Timeout de 30 secondes max
      final snapshot = await uploadTask.timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Upload timeout - fichier trop volumineux ou connexion lente'),
      );
      
      final url = await snapshot.ref.getDownloadURL();
      pdfUrl = url;

      if (kDebugMode) print("Upload réussi: $url");
      return url;
      
    } catch (e) {
      if (kDebugMode) print('Upload error: $e');
      
      // Messages d'erreur plus clairs
      String errorMessage = 'Erreur inconnue';
      if (e.toString().contains('timeout')) {
        errorMessage = 'Upload too slow - try a smaller file';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Permission problem - check your authorization';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Internet connection problem';
      } else {
        errorMessage = 'Upload error: ${e.toString().split(': ').last}';
      }
      
      Get.snackbar(
        'Upload Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return null;
    }
  }

  // Send application confirmation email
  Future<void> _sendApplicationConfirmationEmail(Map<String, dynamic> jobData) async {
    try {
      final userEmail = PreferencesService.getString(PrefKeys.email);
      final userName = PreferencesService.getString(PrefKeys.fullName);
      
      if (userEmail.isEmpty) return;

      // Check if this is an English job posting
      final isEnglishJob = _isEnglishJobPosting(jobData);
      
      final emailHTML = _generateApplicationConfirmationEmail(
        userName: userName,
        jobTitle: jobData['Position'] ?? 'Position',
        companyName: jobData['CompanyName'] ?? 'Company',
        salary: jobData['salary'] ?? 'Not specified',
        location: jobData['location'] ?? 'Not specified',
        type: jobData['type'] ?? 'Not specified',
        isEnglish: isEnglishJob,
      );

      final subject = isEnglishJob 
          ? "✅ Application Confirmed - ${jobData['Position']} at ${jobData['CompanyName']}"
          : "✅ Candidature confirmée - ${jobData['Position']} chez ${jobData['CompanyName']}";
          
      final textMessage = isEnglishJob
          ? "Your application for ${jobData['Position']} at ${jobData['CompanyName']} has been successfully submitted."
          : "Votre candidature pour ${jobData['Position']} chez ${jobData['CompanyName']} a été soumise avec succès.";

      // Send via Firebase Extensions
      final mailDoc = await FirebaseFirestore.instance.collection("mail").add({
        "to": [userEmail],
        "message": {
          "subject": subject,
          "html": emailHTML,
          "text": textMessage
        }
      });

      // Log the application email
      await FirebaseFirestore.instance.collection("applicationEmails").add({
        "to": userEmail,
        "userName": userName,
        "jobTitle": jobData['Position'],
        "companyName": jobData['CompanyName'],
        "applicationDate": FieldValue.serverTimestamp(),
        "status": "sent",
        "mailDocId": mailDoc.id,
        "userId": PreferencesService.getString(PrefKeys.userId),
        "language": isEnglishJob ? "english" : "french",
      });

      if (kDebugMode) print('✅ Application confirmation email sent to $userEmail (${isEnglishJob ? "English" : "French"})');
    } catch (e) {
      if (kDebugMode) print('❌ Error sending application confirmation email: $e');
    }
  }

  // Add application notification to user's notifications
  Future<void> _addApplicationNotification(Map<String, dynamic> jobData) async {
    try {
      final userId = PreferencesService.getString(PrefKeys.userId);
      if (userId.isEmpty) return;

      // Check if this is an English job posting
      final isEnglishJob = _isEnglishJobPosting(jobData);
      
      final title = isEnglishJob ? "Application Submitted" : "Candidature soumise";
      final message = isEnglishJob 
          ? "Your application for ${jobData['Position']} at ${jobData['CompanyName']} has been submitted successfully."
          : "Votre candidature pour ${jobData['Position']} chez ${jobData['CompanyName']} a été soumise avec succès.";

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("notifications")
          .add({
        "type": "application_submitted",
        "title": title,
        "message": message,
        "jobTitle": jobData['Position'],
        "companyName": jobData['CompanyName'],
        "read": false,
        "createdAt": FieldValue.serverTimestamp(),
        "icon": "check_circle",
        "priority": "medium",
        "language": isEnglishJob ? "english" : "french",
      });

      if (kDebugMode) print('✅ Application notification added (${isEnglishJob ? "English" : "French"})');
    } catch (e) {
      if (kDebugMode) print('❌ Error adding application notification: $e');
    }
  }

  // Helper method to check if a job posting is in English
  bool _isEnglishJobPosting(Map<String, dynamic> jobData) {
    // Check if keywords contain 'english' or 'international'
    final keywords = jobData['keywords'] as List<dynamic>?;
    if (keywords != null) {
      final keywordStrings = keywords.whereType<String>().map((k) => k.toLowerCase()).toList();
      if (keywordStrings.contains('english') || keywordStrings.contains('international')) {
        return true;
      }
    }
    
    // Check if company name contains our English demo companies
    final companyName = jobData['CompanyName'] as String?;
    if (companyName != null) {
      final englishCompanies = [
        'DataMaster Strasbourg',
        'ShieldIT Nice', 
        'UserFirst Rennes',
        'AI-Driven Grenoble'
      ];
      if (englishCompanies.contains(companyName)) {
        return true;
      }
    }
    
    return false;
  }

  String _generateApplicationConfirmationEmail({
    required String userName,
    required String jobTitle,
    required String companyName,
    required String salary,
    required String location,
    required String type,
    bool isEnglish = false,
  }) {
    if (isEnglish) {
      // English email template
      return """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Application Confirmed - $jobTitle</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f5f5; margin: 0; padding: 20px; }
        .container { max-width: 600px; margin: 0 auto; background-color: white; border-radius: 12px; overflow: hidden; box-shadow: 0 8px 32px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, #28a745 0%, #20c997 100%); color: white; text-align: center; padding: 30px 20px; }
        .header h1 { margin: 0; font-size: 26px; font-weight: 700; }
        .content { padding: 30px; }
        .job-details { background: #f8f9fa; padding: 20px; border-radius: 10px; margin: 20px 0; border-left: 4px solid #28a745; }
        .detail-row { display: flex; justify-content: space-between; margin: 8px 0; }
        .detail-label { font-weight: 600; color: #495057; }
        .detail-value { color: #28a745; font-weight: 600; }
        .next-steps { background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0; border-left: 4px solid #2196f3; }
        .footer { background-color: #f8f9fa; text-align: center; padding: 20px; border-top: 1px solid #eee; }
        .success-icon { font-size: 48px; margin-bottom: 10px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="success-icon">✅</div>
            <h1>Application Submitted!</h1>
            <p>Your job application has been successfully received</p>
        </div>
        
        <div class="content">
            <h2>Hello $userName,</h2>
            
            <p>Great news! Your application has been successfully submitted and is now being reviewed by the hiring team.</p>
            
            <div class="job-details">
                <h3 style="margin-top: 0; color: #333;">📋 Application Details</h3>
                <div class="detail-row">
                    <span class="detail-label">Position:</span>
                    <span class="detail-value">$jobTitle</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Company:</span>
                    <span class="detail-value">$companyName</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Location:</span>
                    <span class="detail-value">$location</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Job Type:</span>
                    <span class="detail-value">$type</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Salary:</span>
                    <span class="detail-value">€$salary</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Application Date:</span>
                    <span class="detail-value">${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}</span>
                </div>
            </div>
            
            <div class="next-steps">
                <h3 style="margin-top: 0; color: #333;">🚀 What happens next?</h3>
                <p style="margin: 0;">
                    • The hiring team will review your application<br>
                    • You'll receive updates on your application status<br>
                    • Keep an eye on your email for any communication<br>
                    • Check your Timeless dashboard for updates
                </p>
            </div>
            
            <p style="color: #666;">Thank you for using Timeless for your job search. We wish you the best of luck with your application!</p>
        </div>
        
        <div class="footer">
            <h3>🌟 The Timeless Team</h3>
            <p>Connecting talent with opportunity worldwide</p>
            <p style="font-size: 12px; color: #999;">
                This is an automated confirmation email.
            </p>
        </div>
    </div>
</body>
</html>
      """;
    } else {
      // French email template  
      return """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Candidature confirmée - $jobTitle</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f5f5; margin: 0; padding: 20px; }
        .container { max-width: 600px; margin: 0 auto; background-color: white; border-radius: 12px; overflow: hidden; box-shadow: 0 8px 32px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, #28a745 0%, #20c997 100%); color: white; text-align: center; padding: 30px 20px; }
        .header h1 { margin: 0; font-size: 26px; font-weight: 700; }
        .content { padding: 30px; }
        .job-details { background: #f8f9fa; padding: 20px; border-radius: 10px; margin: 20px 0; border-left: 4px solid #28a745; }
        .detail-row { display: flex; justify-content: space-between; margin: 8px 0; }
        .detail-label { font-weight: 600; color: #495057; }
        .detail-value { color: #28a745; font-weight: 600; }
        .next-steps { background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0; border-left: 4px solid #2196f3; }
        .footer { background-color: #f8f9fa; text-align: center; padding: 20px; border-top: 1px solid #eee; }
        .success-icon { font-size: 48px; margin-bottom: 10px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="success-icon">✅</div>
            <h1>Candidature soumise !</h1>
            <p>Votre candidature a été reçue avec succès</p>
        </div>
        
        <div class="content">
            <h2>Bonjour $userName,</h2>
            
            <p>Excellente nouvelle ! Votre candidature a été soumise avec succès et est maintenant en cours d'examen par l'équipe de recrutement.</p>
            
            <div class="job-details">
                <h3 style="margin-top: 0; color: #333;">📋 Détails de la candidature</h3>
                <div class="detail-row">
                    <span class="detail-label">Poste :</span>
                    <span class="detail-value">$jobTitle</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Entreprise :</span>
                    <span class="detail-value">$companyName</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Localisation :</span>
                    <span class="detail-value">$location</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Type de contrat :</span>
                    <span class="detail-value">$type</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Salaire :</span>
                    <span class="detail-value">$salary €</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Date de candidature :</span>
                    <span class="detail-value">${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}</span>
                </div>
            </div>
            
            <div class="next-steps">
                <h3 style="margin-top: 0; color: #333;">🚀 Prochaines étapes</h3>
                <p style="margin: 0;">
                    • L'équipe de recrutement va examiner votre candidature<br>
                    • Vous recevrez des mises à jour sur le statut de votre candidature<br>
                    • Surveillez votre email pour toute communication<br>
                    • Consultez votre tableau de bord Timeless pour les mises à jour
                </p>
            </div>
            
            <p style="color: #666;">Merci d'utiliser Timeless pour votre recherche d'emploi. Nous vous souhaitons bonne chance pour votre candidature !</p>
        </div>
        
        <div class="footer">
            <h3>🌟 L'équipe Timeless</h3>
            <p>Connecter les talents aux opportunités</p>
            <p style="font-size: 12px; color: #999;">
                Ceci est un email de confirmation automatique.
            </p>
        </div>
    </div>
</body>
</html>
      """;
    }
  }
}
