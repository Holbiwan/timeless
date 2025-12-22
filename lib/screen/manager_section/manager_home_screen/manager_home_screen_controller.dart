import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:timeless/screen/manager_section/Notification/notification_services.dart';
import 'package:timeless/services/preferences_service.dart';
import 'package:timeless/utils/pref_keys.dart';

class ManagerHomeScreenController extends GetxController
    implements GetxService {
  String? companyName;
  List userData = [];
  bool loader = false;
  String? token;

  @override
  Future<void> onInit() async {
    token = await NotificationService.getFcmToken();
    getCompanyName();
    getUserData();
    if (kDebugMode) {
      print(token);
    }
    super.onInit();
  }

  getCompanyName() async {
    companyName = PreferencesService.getString(PrefKeys.companyName);
  }

  getUserData() async {
    loader = true;
    update(['userdata']);

    var data = await FirebaseFirestore.instance.collection("Apply").get();
    userData = data.docs;

    loader = false;
    update(['userdata']);
    update(['userDataSeeAll']);
  }

  // Refresh all dashboard data
  Future<void> refreshData() async {
    try {
      if (kDebugMode) {
        print('🔄 Refreshing Manager Home dashboard...');
      }

      // Refresh company name and user data
      await getCompanyName();
      await getUserData();

      // Update all relevant UI sections
      update(['userdata']);
      update(['userDataSeeAll']);
      update(['dashboard']);

      if (kDebugMode) {
        print('✅ Manager Home dashboard refreshed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refreshing Manager Home dashboard: $e');
      }
    }
  }
}
