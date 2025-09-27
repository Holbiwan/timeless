import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/screen/dashboard/home/home_controller.dart';

class DashBoardController extends GetxController{
  int currentTab = 0;
  void onBottomBarChange(int index) {
    currentTab = index;
    if (index == 0) {
      debugPrint("Jobs tab selected");
      Get.put(HomeController());
    } else {
      debugPrint("Profile tab selected");
    }
    update(['bottom_bar']);
  }
}