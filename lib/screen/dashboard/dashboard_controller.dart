import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/utils/app_res.dart';

class DashBoardController extends GetxController{
  int currentTab = 0;
  void onBottomBarChange(int index) {
    debugPrint("onBottomBarChange called with index: $index");
    
    if (index == 0) {
      // Home tab - forcer le retour sur Home
      currentTab = 0;
      debugPrint("Home tab selected - currentTab set to 0");
      
      // Si on est sur une autre page, revenir à Home
      if (Get.currentRoute != '/dashboard') {
        Get.offAllNamed('/dashboard');
        debugPrint("Navigating to dashboard");
      }
    } else if (index == 1) {
      // Jobs tab - aller vers les offres d'emploi
      currentTab = 1;
      debugPrint("Jobs tab selected");
      Get.toNamed(AppRes.jobRecommendationScreen);
    }
    
    debugPrint("Final currentTab: $currentTab");
    update(['bottom_bar']);
  }
}