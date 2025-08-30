import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

// ⚠️ Dossier 'Profile' avec P majuscule
import 'package:timeless/screen/manager_section/Profile/manager_profile_controller.dart';

class ManagerDashBoardScreenController extends GetxController
    implements GetxService {
  final RxInt currentTab = 0.obs;

  @override
  void onInit() {
    _handleInitialArguments();
    super.onInit();
  }

  // Lit Get.arguments de façon robuste
  void _handleInitialArguments() {
    try {
      final args = Get.arguments;
      if (args != null) {
        final tabIndex = _extractTabIndexFromArguments(args);
        if (tabIndex != null) {
          currentTab.value = tabIndex;
        }
      }
    } catch (e) {
      debugPrint('Error handling initial arguments: $e');
    }
  }

  int? _extractTabIndexFromArguments(dynamic args) {
    if (args is int) return args;
    if (args is String) return int.tryParse(args);
    if (args is Map) {
      final v = args['index'] ?? args['tab'] ?? args['currentTab'];
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
    }
    return null;
  }

  // Changement d’onglet + logique
  void onBottomBarChange(int index) {
    if (index == currentTab.value) return;
    currentTab.value = index;
    _executeTabSpecificLogic(index);
    update(['bottom_bar']);
  }

  void _executeTabSpecificLogic(int index) {
    debugPrint("INDEX IS $index");
    switch (index) {
      case 0: _initHomeTab();    break;
      case 1: _initSearchTab();  break;
      case 2: _initMessageTab(); break;
      case 3: _initProfileTab(); break;
      default:
        debugPrint("Unknown tab index: $index");
    }
  }

  void _initHomeTab()    => debugPrint("Initializing Home Tab");
  void _initSearchTab()  => debugPrint("Initializing Search Tab");
  void _initMessageTab() => debugPrint("Initializing Message Tab");

  void _initProfileTab() {
    try {
      debugPrint("Initializing Manager Profile Tab");
      final ctrl = Get.isRegistered<ManagerProfileController>()
          ? Get.find<ManagerProfileController>()
          : Get.put(ManagerProfileController());
      ctrl.init(); // doit exister dans ManagerProfileController
    } catch (e) {
      debugPrint('Error initializing manager profile tab: $e');
    }
  }

  int get currentIndex => currentTab.value;
  void refreshBottomBar() => update(['bottom_bar']);
}
