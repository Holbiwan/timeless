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

  /// Gestion des arguments passés à l'écran
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

  /// Extrait l'index de l'onglet depuis différents formats d'arguments
  int? _extractTabIndexFromArguments(dynamic args) {
    if (args is int) {
      return args;
    } else if (args is String) {
      return int.tryParse(args);
    } else if (args is Map<String, dynamic>) {
      // Cherche différentes clés possibles pour l'index
      final dynamic value = args['index'] ?? args['tab'] ?? args['currentTab'];
      
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
    }
    return null;
  }

  /// Change l'onglet actuel et exécute la logique spécifique
  void onBottomBarChange(int index) {
    if (index == currentTab.value) return; // Évite les traitements inutiles
    
    currentTab.value = index;
    _executeTabSpecificLogic(index);
    update(['bottom_bar']);
  }

  /// Exécute la logique spécifique à chaque onglet
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

  /// Méthodes spécifiques à chaque onglet
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

  /// Méthode utilitaire pour obtenir l'index actuel
  int get currentIndex => currentTab.value;

  /// Méthode pour forcer le rafraîchissement de la bottom bar
  void refreshBottomBar() {
    update(['bottom_bar']);
  }
}