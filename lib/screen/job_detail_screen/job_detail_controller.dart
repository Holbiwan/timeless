import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/pref_keys.dart';
import 'package:get/get.dart';

class JobDetailsController extends GetxController {
  RxList requirements = [
    "Experienced in Figma or Sketch.",
    "Able to work in large or small team.",
    "At least 1 year of working experience in agency freelance, or start-up.",
    "Able to keep up with the latest trends.",
    "Have relevant experience for at least 3 years."
  ].obs;

  RxBool hasApplied = false.obs;

  Future<void> checkApplicationStatus(String jobId) async {
    final candidateId = PreferencesService.getString(PrefKeys.userId);
    if (candidateId == null) {
      hasApplied.value = false;
      return;
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .where('candidateId', isEqualTo: candidateId)
        .get();

    hasApplied.value = querySnapshot.docs.isNotEmpty;
  }
}
