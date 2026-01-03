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
  
  // Statistics
  int activeJobsCount = 0;
  int totalApplicationsCount = 0;
  bool statsLoading = false;

  @override
  Future<void> onInit() async {
    token = await NotificationService.getFcmToken();
    getCompanyName();
    getUserData();
    getStatistics();
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

  // Get statistics for active jobs and total applications
  Future<void> getStatistics() async {
    try {
      statsLoading = true;
      update(['stats']);

      final companyNamePref = PreferencesService.getString(PrefKeys.companyName);
      
      // Get active jobs count
      final jobsQuery = await FirebaseFirestore.instance
          .collection("allPost")
          .where('CompanyName', isEqualTo: companyNamePref)
          .where('Status', isEqualTo: 'Active')
          .get();
      
      activeJobsCount = jobsQuery.docs.length;

      // Get total applications count for this company's jobs
      int totalApps = 0;
      for (var jobDoc in jobsQuery.docs) {
        final applicationsQuery = await FirebaseFirestore.instance
            .collection("applications")
            .where('jobId', isEqualTo: jobDoc.id)
            .get();
        totalApps += applicationsQuery.docs.length;
      }
      
      // Also check the old Apply collection format
      final applyData = await FirebaseFirestore.instance.collection("Apply").get();
      int applyCount = 0;
      for (var doc in applyData.docs) {
        final companyNameData = doc['companyName'];
        if (companyNameData is List) {
          for (var element in companyNameData) {
            if (element['companyname'].toString().toLowerCase() == companyNamePref.toLowerCase()) {
              applyCount++;
              break;
            }
          }
        } else if (companyNameData is String) {
          if (companyNameData.toLowerCase() == companyNamePref.toLowerCase()) {
            applyCount++;
          }
        }
      }
      
      totalApplicationsCount = totalApps + applyCount;

      if (kDebugMode) {
        print('📊 Stats loaded: $activeJobsCount active jobs, $totalApplicationsCount applications');
      }
      
      statsLoading = false;
      update(['stats']);
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading statistics: $e');
      }
      statsLoading = false;
      update(['stats']);
    }
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
      await getStatistics();

      // Update all relevant UI sections
      update(['userdata']);
      update(['userDataSeeAll']);
      update(['dashboard']);
      update(['stats']);

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
