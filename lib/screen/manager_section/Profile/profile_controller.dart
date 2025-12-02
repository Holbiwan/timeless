import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/pref_keys.dart';


class ProfileUserController extends GetxController implements GetxService {
  // Champs utilisateur
  final TextEditingController fullNameController   = TextEditingController();
  final TextEditingController emailController      = TextEditingController();
  final TextEditingController addressController    = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();

  // Etats simples
  final RxBool isLod = false.obs;

  // Image
  final ImagePicker picker = ImagePicker();
  File? image;                 // image locale
  String url = "";             // si tu fais un upload plus tard

  // Firestore
  static final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  DateTime? startTime;

  @override
  void onInit() {
    super.onInit();
    // Préremplissage depuis PreferencesService
    fullNameController.text   = PreferencesService.getString(PrefKeys.fullName);
    emailController.text      = PreferencesService.getString(PrefKeys.email);
    occupationController.text = PreferencesService.getString(PrefKeys.occupation);
    dateOfBirthController.text= PreferencesService.getString(PrefKeys.dateOfBirth);
    addressController.text    = PreferencesService.getString(PrefKeys.address);

    final path = PreferencesService.getString(PrefKeys.imageId);
    if (path.isNotEmpty) image = File(path);

    update();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    addressController.dispose();
    occupationController.dispose();
    dateOfBirthController.dispose();
    super.onClose();
  }

  void onChanged(String value) => update(["colorChange"]);

  Future<void> onDatePickerTap(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) =>
          Theme(data: ThemeData(primarySwatch: Colors.blue), child: child!),
    );
    startTime = picked;
    if (picked != null) {
      dateOfBirthController.text =
          "${picked.month}/${picked.day}/${picked.year}";
      PreferencesService.setValue(PrefKeys.dateOfBirth, dateOfBirthController.text);
    }
    update();
  }

  // === Caméra
  Future<void> onTap() async {
    try {
      final XFile? img = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (img == null) return;
      image = File(img.path);
      await PreferencesService.setValue(PrefKeys.imageId, image!.path);
      imagePicker();
    } catch (e) {
      if (kDebugMode) print(e);
      Get.snackbar("Camera", "Failed to capture image",
          colorText: const Color(0xffDA1414));
    }
  }

  // === Galerie
  Future<void> onTapGallery() async {
    try {
      final XFile? gal = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (gal == null) return;
      image = File(gal.path);
      await PreferencesService.setValue(PrefKeys.imageId, image!.path);
      imagePicker();
    } catch (e) {
      if (kDebugMode) print(e);
      Get.snackbar("Gallery", "Failed to pick image",
          colorText: const Color(0xffDA1414));
    }
  }

  // === Save dans Firestore
  Future<void> editTap() async {
    try {
      isLod.value = true;
      final uid = PreferencesService.getString(PrefKeys.userId);

      final map = <String, dynamic>{
        "fullName": fullNameController.text.trim(),
        "Email": emailController.text.trim(),
        "Address": addressController.text.trim(),
        "Occupation": occupationController.text.trim(),
        "DateOfBirth": dateOfBirthController.text.trim(),
        "imageUrl": url,
        "updatedAt": FieldValue.serverTimestamp(),
      };

      await fireStore
          .collection("Auth")
          .doc("User")
          .collection("register")
          .doc(uid)
          .set(map, SetOptions(merge: true));

      // Mets à jour les Prefs locales
      await PreferencesService.setValue(PrefKeys.fullName, fullNameController.text.trim());
      await PreferencesService.setValue(PrefKeys.email, emailController.text.trim());
      await PreferencesService.setValue(PrefKeys.address, addressController.text.trim());
      await PreferencesService.setValue(PrefKeys.occupation, occupationController.text.trim());

      Get.snackbar("Profile", "Updated successfully");
    } catch (e) {
      if (kDebugMode) print(e);
      Get.snackbar("Error", "Profile update failed",
          colorText: const Color(0xffDA1414));
    } finally {
      isLod.value = false;
      update();
    }
  }

  void imagePicker() {
    update(['gallery']);
    update(['onTap']);
    update(['image']);
    update();
  }

  // === ALIASES demandés par l’UI existante ===
  Future<void> ontap() => onTap();
  Future<void> ontapGallery() => onTapGallery();
  Future<void> EditTap() => editTap();
}
