// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  
  StreamSubscription? _appsSubscription;

  @override
  Future<void> onInit() async {
    token = await NotificationService.getFcmToken();
    getCompanyName();
    getUserData();
    // Initialize real-time statistics
    initStatisticsListener();
    if (kDebugMode) {
      print(token);
    }
    super.onInit();
  }
  
  @override
  void onClose() {
    _appsSubscription?.cancel();
    super.onClose();
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

  // Get statistics with real-time updates
  void initStatisticsListener() async {
    try {
      statsLoading = true;
      update(['stats']);

      final uid = FirebaseAuth.instance.currentUser?.uid ?? 
                 PreferencesService.getString(PrefKeys.userId);
                 
      if (uid == null) {
        if (kDebugMode) print('❌ No User ID found for statistics');
        statsLoading = false;
        update(['stats']);
        return;
      }

      final companyNamePref = PreferencesService.getString(PrefKeys.companyName);
      
      // Get active jobs count (Keep as one-time fetch for now, or could be streamed too)
      final jobsQuery = await FirebaseFirestore.instance
          .collection("allPost")
          .where('CompanyName', isEqualTo: companyNamePref)
          .where('Status', isEqualTo: 'Active')
          .get();
      
      activeJobsCount = jobsQuery.docs.length;

      // Calculate Legacy Applications Count (One-time fetch)
      int legacyApplyCount = 0;
      try {
        final applyData = await FirebaseFirestore.instance.collection("Apply").get();
        for (var doc in applyData.docs) {
          final companyNameData = doc['companyName'];
          if (companyNameData is List) {
            for (var element in companyNameData) {
              if (element['companyname'].toString().toLowerCase() == companyNamePref.toLowerCase()) {
                legacyApplyCount++;
                break;
              }
            }
          } else if (companyNameData is String) {
            if (companyNameData.toLowerCase() == companyNamePref.toLowerCase()) {
              legacyApplyCount++;
            }
          }
        }
      } catch (e) {
        if (kDebugMode) print('⚠️ Error counting legacy applications: $e');
      }

      // Listen to Modern Applications Collection (Real-time)
      _appsSubscription?.cancel();
      _appsSubscription = FirebaseFirestore.instance
          .collection("applications")
          .where('employerId', isEqualTo: uid)
          .snapshots()
          .listen((snapshot) {
        
        final modernAppsCount = snapshot.docs.length;
        totalApplicationsCount = modernAppsCount + legacyApplyCount;

        if (kDebugMode) {
          print('📊 Real-time Stats: $activeJobsCount active jobs, $totalApplicationsCount total apps ($modernAppsCount modern + $legacyApplyCount legacy)');
        }
        
        statsLoading = false;
        update(['stats']);
        update(['dashboard']); // Update dashboard widget if it listens to this
      }, onError: (e) {
        if (kDebugMode) print('❌ Error in applications stream: $e');
        statsLoading = false;
        update(['stats']);
      });
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing statistics: $e');
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
      
      // Re-init listener to refresh static parts (active jobs, legacy apps)
      initStatisticsListener();

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
