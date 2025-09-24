import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:timeless/service/notification_service.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
List<Map<String, dynamic>> companyList = [];
bool abc = false;

class JobDetailsUploadCvController extends GetxController {
  RefreshController refreshController = RefreshController();

  init() async {
    companyList = [];
    try {
      final value = await firestore.collection("Apply").get();

      for (final element in value.docs) {
        if (element['uid'] == PrefService.getString(PrefKeys.userId)) {
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
    refreshController.refreshCompleted();
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
      'userName': PrefService.getString(PrefKeys.fullName),
      'email': PrefService.getString(PrefKeys.email),
      'phone': PrefService.getString(PrefKeys.phoneNumber),
      'city': PrefService.getString(PrefKeys.city),
      'state': PrefService.getString(PrefKeys.state),
      'country': PrefService.getString(PrefKeys.country),
      'Occupation': PrefService.getString(PrefKeys.occupation),
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'resumeUrl': pdfUrl,
      'fileName': filepath.value,
      'fileSize': filesize,
      'salary': args['salary'],
      'location': args['location'],
      'type': args['type'],
      "deviceToken": PrefService.getString(PrefKeys.deviceToken),
    });

    // Add notification for application submission
    try {
      final notificationService = Get.find<NotificationService>();
      await notificationService.addApplicationNotification(
        jobTitle: args['Position'] ?? 'Unknown Position',
        companyName: args['CompanyName'] ?? 'Unknown Company',
        jobId: args['id'] ?? 'unknown_id',
      );
    } catch (e) {
      if (kDebugMode) print('Error adding notification: $e');
    }

    // Show success message before navigation
    Get.snackbar(
      '🎉 Application Submitted!',
      'Your job application has been successfully submitted to ${args['CompanyName']}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
    
    Get.toNamed(AppRes.jobDetailSuccessOrFailed, arguments: [
      {"doc": args},
      {"error": false, "filename": filepath},
    ]);

    filepath.value = "";
  }

  RxString filepath = "".obs;
  RxInt? fileSize;
  RxBool isPdfUploadError = false.obs;
  bool uploadingMedia = false;

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
      final userId = PrefService.getString(PrefKeys.userId);
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
}
