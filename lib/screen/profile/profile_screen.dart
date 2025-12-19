import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:timeless/screen/manager_section/profile/manager_profile_controller.dart';

class ManagerDashBoardScreenController extends GetxController
    implements GetxService {
  final RxInt currentTab = 0.obs;

  @override
  void onInit() {
    _handleInitialArguments();
    super.onInit();
  }

  void _handleInitialArguments() {
    try {
      final args = Get.arguments;
      if (args != null) {
        final tabIndex = _extractTabIndexFromArguments(args);
        if (tabIndex != null) {
          currentTab.value = tabIndex;
          // NE PAS appeler _executeTabSpecificLogic ici
        }
      }
    } catch (e) {
      debugPrint('Error handling initial arguments: $e');
    }
  }

  int? _extractTabIndexFromArguments(dynamic args) {
    if (args is int) {
      return args;
    } else if (args is String) {
      return int.tryParse(args);
    } else if (args is Map<String, dynamic>) {
      final dynamic value = args['index'] ?? args['tab'] ?? args['currentTab'];

      if (value is int) return value;
      if (value is String) return int.tryParse(value);
    }
    return null;
  }

  void onBottomBarChange(int index) {
    if (index == currentTab.value) return;

    currentTab.value = index;
    _executeTabSpecificLogic(index);
    update(['bottom_bar']);
  }

  void _executeTabSpecificLogic(int index) {
    debugPrint("INDEX IS $index");

    switch (index) {
      case 0:
        _initHomeTab();
        break;
      case 1:
        _initSearchTab();
        break;
      case 2:
        _initMessageTab();
        break;
      case 3:
        _initProfileTab();
        break;
      default:
        debugPrint("Unknown tab index: $index");
    }
  }

  void _initHomeTab() {
    debugPrint("Initializing Home Tab");
  }

  void _initSearchTab() {
    debugPrint("Initializing Search Tab");
  }

  void _initMessageTab() {
    debugPrint("Initializing Message Tab");
  }

  void _initProfileTab() {
    try {
      debugPrint("Initializing Manager Profile Tab");

      // UTILISEZ ManagerProfileController au lieu de ProfileController
      if (Get.isRegistered<ManagerProfileController>()) {
        final profileController = Get.find<ManagerProfileController>();
        profileController.init();
      } else {
        final profileController = Get.put(ManagerProfileController());
        profileController.init();
      }
    } catch (e) {
      debugPrint('Error initializing manager profile tab: $e');
    }
  }

  int get currentIndex => currentTab.value;

  void refreshBottomBar() {
    update(['bottom_bar']);
  }
}
