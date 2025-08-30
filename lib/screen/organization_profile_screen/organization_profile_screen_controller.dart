import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:timeless/screen/manager_section/dashboard/manager_dashboard_screen.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/pref_keys.dart';

class OrganizationProfileScreenController extends GetxController
    implements GetxService {
  // --- Controllers champs ---
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController companyEmailController = TextEditingController();
  final TextEditingController companyAddressController =
      TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController statusController = TextEditingController();

  // --- Etats de validation ---
  final RxBool isNameValidate = false.obs;
  final RxBool isEmailValidate = false.obs;
  final RxBool isAddressValidate = false.obs;
  final RxBool isCountryValidate = false.obs;
  final RxBool isDateValidate = false.obs;
  final RxBool isPositionValidate = false.obs;
  final RxBool isSalaryValidate = false.obs;
  final RxBool isLocationValidate = false.obs;
  final RxBool isTypeValidate = false.obs;
  final RxBool isStatusValidate = false.obs;

  // --- UI/chargements ---
  final RxBool isLod = false.obs; // loader image
  final RxBool conLoader = false.obs; // loader bouton "Confirmer"
  final RxString fbImageUrlM = "".obs;

  // --- Divers ---
  DateTime? startTime;
  final ImagePicker picker = ImagePicker();
  File? image;
  static final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  String url = "";
  String dropDownValue = 'India';

  final List<String> items = const [
    'India',
    'United States',
    'Europe',
    'china',
    'United Kingdom',
    'Cuba',
    'Havana',
    'Cyprus',
    'Nicosia',
    'Czech Republic',
    'Prague',
  ];

  // ============= UI =============
  void onChanged(String value) {
    update(["colorChange"]);
    update(["Organization"]);
  }

  void changeDropdwon({required String val}) {
    dropDownValue = val;
    countryController.text = dropDownValue;
    update(["dropdown"]);
  }

  // ============= Validation =============
  void validate() {
    isNameValidate.value = companyNameController.text.trim().isEmpty;

    final email = companyEmailController.text.trim();
    final emailOk =
        RegExp(r"^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$")
            .hasMatch(email);
    isEmailValidate.value = email.isEmpty || !emailOk;

    isAddressValidate.value = companyAddressController.text.trim().isEmpty;
    isCountryValidate.value = countryController.text.trim().isEmpty;
    isDateValidate.value = dateController.text.trim().isEmpty;
  }

  // ============= DatePicker =============
  Future<void> onDatePickerTap(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData(primarySwatch: Colors.blue),
          child: child!,
        );
      },
    );

    if (picked == null) {
      // utilisateur a annulé
      return;
    }

    startTime = picked;
    // Pas d'appel à toLocal() sur une valeur nulle
    final d = picked.toLocal();
    dateController.text = "${d.month}/${d.day}/${d.year}";
    update();
  }

  // ============= Upload / Storage =============
  /// Upload depuis [image] (déjà choisie) et met à jour [url]
  Future<void> getUrl() async {
    if (image == null) return;

    final storage = FirebaseStorage.instance;
    final ref =
        storage.ref().child("image_${DateTime.now().millisecondsSinceEpoch}");
    try {
      isLod.value = true;
      final task = await ref.putFile(image!);
      url = await task.ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) print("Erreur upload image: $e");
      url = "";
      Get.snackbar("Image", "Échec de l'upload de l'image",
          snackPosition: SnackPosition.BOTTOM,
          colorText: const Color(0xffDA1414));
    } finally {
      isLod.value = false;
      update();
    }
  }

  /// Upload générique d'un fichier [flow] sur un chemin [path] et renvoie l'URL
  Future<String?> uploadImage({File? flow, required String path}) async {
    if (flow == null) return '';

    // Permissions selon plate-forme
    if (Platform.isAndroid) {
      // Sur Android 13+, ce sont READ_MEDIA_IMAGES, ci-dessous Permission.photos géré par le plugin
      await Permission.photos.request();
      final granted = await Permission.photos.isGranted ||
          await Permission.storage.isGranted;
      if (!granted) {
        if (kDebugMode) {
          print('Permission storage/photos refusée');
        }
        return '';
      }
    } else if (Platform.isIOS || Platform.isMacOS) {
      await Permission.photos.request();
      if (!await Permission.photos.isGranted) return '';
    }

    try {
      final snapshot = await FirebaseStorage.instance.ref(path).putFile(flow);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      if (kDebugMode) print("Image uploadée: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) print("Erreur upload: $e");
      return '';
    }
  }

  /// Upload d’une image intégrée aux assets vers un dossier Firestore/Storage
  Future<void> addImg({required String img}) async {
    try {
      final storage = FirebaseStorage.instance;

      final imageName =
          img.substring(img.lastIndexOf("/") + 1, img.lastIndexOf("."));
      final path = img.substring(img.indexOf("/") + 1, img.lastIndexOf("/"));

      final Directory systemTempDir = Directory.systemTemp;
      final byteData = await rootBundle.load(img);
      final file = File('${systemTempDir.path}/$imageName.jpg');
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

      final taskSnapshot = await storage.ref('$path/$imageName').putFile(file);
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection(path)
          .add({"url": downloadUrl, "name": imageName});
    } catch (e) {
      if (kDebugMode) print("addImg error: $e");
    }
  }

  // ============= Sélection image =============
  Future<void> onTapGallery1() async {
    try {
      final XFile? gallery =
          await picker.pickImage(source: ImageSource.gallery);
      if (gallery == null) return;
      image = File(gallery.path);
      update(['image']);

      // Upload vers Storage → url
      await getUrl();

      // Optionnel : upload vers un chemin spécifique via uploadImage()
      // await uploadImage(flow: image, path: 'organizations/${DateTime.now().millisecondsSinceEpoch}.jpg');
    } catch (e) {
      if (kDebugMode) print("pickImage error: $e");
      Get.snackbar("Image", "Erreur lors du choix de l'image",
          snackPosition: SnackPosition.BOTTOM,
          colorText: const Color(0xffDA1414));
    }
  }

  // ============= Sauvegarde =============
  Future<void> onConfirmTap() async {
    conLoader.value = true;
    try {
      validate();

      // Si erreurs, on stoppe là.
      if (isNameValidate.value ||
          isEmailValidate.value ||
          isAddressValidate.value ||
          isCountryValidate.value ||
          isDateValidate.value) {
        conLoader.value = false;
        update();
        return;
      }

      final String uid = PrefService.getString(PrefKeys.userId);
      final Map<String, dynamic> map = {
        "email": companyEmailController.text.trim(),
        "name": companyNameController.text.trim(),
        "date": dateController.text.trim(),
        "country": countryController.text.trim(),
        "address": companyAddressController.text.trim(),
        "imageUrl": url,
        "deviceToken": PrefService.getString(PrefKeys.deviceToken),
      };

      // Sauvegarde de l’URL image côté prefs
      PrefService.setValue(PrefKeys.imageManager, url);
      PrefService.setValue(PrefKeys.companyName, companyNameController.text);

      // Marque "company" = true sur le profil Manager, puis écrit les détails
      await fireStore
          .collection("Auth")
          .doc("Manager")
          .collection("register")
          .doc(uid)
          .update({"company": true});

      PrefService.setValue(PrefKeys.company, true);

      await fireStore
          .collection("Auth")
          .doc("Manager")
          .collection("register")
          .doc(uid)
          .collection("company")
          .doc("details")
          .set(map, SetOptions(merge: true));

      Get.off(() => ManagerDashBoardScreen());
    } catch (e) {
      if (kDebugMode) print("onConfirmTap error: $e");
      Get.snackbar("Erreur", "Échec de l’enregistrement",
          snackPosition: SnackPosition.BOTTOM,
          colorText: const Color(0xffDA1414));
    } finally {
      conLoader.value = false;
    }
  }
}
