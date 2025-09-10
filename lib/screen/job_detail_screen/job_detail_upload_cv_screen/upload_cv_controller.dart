import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/app_res.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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

  onTapApply({var args}) {
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

  applyResume() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      final PlatformFile file = result.files.first;

      filepath.value = file.name.toString();

      final kb = file.size / 1024;
      final kbVal = kb.ceil().toInt();
      final mb = kb / 1024;
      fileSize?.value = kbVal;
      filesize = mb;

      if (kDebugMode) {
        print(filesize);
        debugPrint("filepath $filepath FileSize ${fileSize?.value}  $kbVal");
      }

      final File fileForFirebase = File(file.path!);
      await uploadImage(file: fileForFirebase, path: "files/${file.name}");
    } else {
      // User canceled the picker
      isPdfUploadError.value = true;
    }
  }

  Future<String?> uploadImage({File? file, String? path}) async {
    if (file == null || path == null) {
      if (kDebugMode) {
        print('No file or path provided');
      }
      return null;
    }

    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      pdfUrl = url;

      if (kDebugMode) {
        print("Download URL: $url");
      }
      return url;
    } catch (e) {
      if (kDebugMode) {
        print('Upload error: $e');
      }
      return null;
    }
  }
}
